/mob/living/simple_animal/hostile/crawling_shadows
	//appearance variables
	name = "crawling shadows"
	desc = "A formless mass of nothingness with piercing white eyes."
	icon = 'icons/effects/effects.dmi' //Placeholder sprite
	icon_state = "blank_dspawn"
	icon_living = "blank_dspawn"

	//survival variables
	maxHealth = 50
	health = 50
	pressure_resistance = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY

	//movement variables
	movement_type = FLYING
	speed = 0
	ventcrawler = TRUE
	pass_flags = PASSTABLE | PASSMOB | PASSDOOR | PASSMACHINES | PASSMECH | PASSCOMPUTER

	//combat variables
	harm_intent_damage = 5
	melee_damage_lower = 5 //it has a built in stun if you want to kill someone kill them like a man
	melee_damage_upper = 5

	//sight variables
	lighting_alpha = 175 //same as darkspawn eyes
	see_in_dark = 10

	//death variables
	del_on_death = TRUE
	deathmessage = "trembles, form rapidly dispersing."
	deathsound = 'yogstation/sound/magic/devour_will_victim.ogg'

	//attack flavour
	speak_emote = list("whispers")
	attacktext = "assails"
	attack_sound = 'sound/magic/voidblink.ogg'
	response_help = "disturbs"
	response_harm = "flails at"

	var/move_count = 0 //For spooky sound effects
	var/knocking_out = FALSE

/mob/living/simple_animal/hostile/crawling_shadows/Move()
	move_count++
	if(move_count >= 5)
		playsound(src, "crawling_shadows_walk", 25, 0)
		move_count = 0
	..()
	var/turf/T = get_turf(src)
	var/lums = T.get_lumcount()
	if(lums < SHADOW_SPECIES_BRIGHT_LIGHT)
		speed = -1 //Faster, too
		alpha = 0
	else
		speed = 0
		alpha = min(alpha + (lums * 30), 255) //Slowly becomes more visible in brighter light
	update_simplemob_varspeed()

/mob/living/simple_animal/hostile/crawling_shadows/AttackingTarget()
	if(ishuman(target) && !knocking_out)
		var/mob/living/carbon/human/H = target
		if(H.stat)
			return ..()
		knocking_out = TRUE
		visible_message(span_warning("[src] picks up [H] and dangles [H.p_them()] in the air!"), span_notice("You pluck [H] from the ground..."))
		to_chat(H, span_userdanger("[src] grabs you and dangles you in the air!"))
		H.Stun(3 SECONDS)
		H.pixel_y += 4
		if(!do_after(src, 1 SECONDS, target))
			H.pixel_y -= 4
			knocking_out = FALSE
			return
		visible_message(span_warning("[src] gently presses a hand against [H]'s face, and [H.p_they()] falls limp..."), span_notice("You quietly incapacitate [H]."))
		H.pixel_y -= 4
		to_chat(H, span_userdanger("[src] presses a hand to your face, and docility washes over you..."))
		H.Paralyze(6 SECONDS)
		knocking_out = FALSE
		return TRUE
	..()
