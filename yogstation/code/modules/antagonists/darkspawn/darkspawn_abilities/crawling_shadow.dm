/datum/action/cooldown/spell/shapeshift/crawling_shadows
	name = "Crawling Shadows"
	desc = "Assumes a shadowy form for a minute that can crawl through vents and squeeze through the cracks in doors. You can also knock people out by attacking them."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "creep"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 60
	die_with_shapeshifted_form = FALSE
	convert_damage = FALSE
	sound = 'yogstation/sound/magic/devour_will_end.ogg'
	possible_shapes = list(/mob/living/simple_animal/hostile/crawling_shadows)

/datum/action/cooldown/spell/shapeshift/crawling_shadows/can_cast_spell(feedback)
	if(owner.has_status_effect(STATUS_EFFECT_TAGALONG))
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/crawling_shadows
	name = "crawling shadows"
	desc = "A formless mass of blackness with two huge, clawed hands and piercing white eyes."
	icon = 'icons/effects/effects.dmi' //Placeholder sprite
	icon_state = "blank_dspawn"
	icon_living = "blank_dspawn"
	response_help = "backs away from"
	response_disarm = "shoves away"
	response_harm = "flails at"
	speed = 0
	ventcrawler = TRUE
	maxHealth = 125
	health = 125

	harm_intent_damage = 5
	obj_damage = 50
	melee_damage_lower = 5 //it has a built in stun if you want to kill someone kill them like a man
	melee_damage_upper = 5
	attacktext = "claws"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	speak_emote = list("whispers")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY

	movement_type = FLYING
	pressure_resistance = INFINITY
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	gold_core_spawnable = FALSE

	del_on_death = TRUE
	deathmessage = "trembles, form rapidly dispersing."
	deathsound = 'yogstation/sound/magic/devour_will_victim.ogg'

	var/move_count = 0 //For spooky sound effects
	var/knocking_out = FALSE

/mob/living/simple_animal/hostile/crawling_shadows/Move()
	move_count++
	if(move_count >= 5)
		playsound(src, "crawling_shadows_walk", 25, 0)
		move_count = 0
	..()

/mob/living/simple_animal/hostile/crawling_shadows/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	var/turf/T = get_turf(src)
	var/lums = T.get_lumcount()
	if(lums < SHADOW_SPECIES_BRIGHT_LIGHT)
		invisibility = INVISIBILITY_OBSERVER //Invisible in complete darkness
		speed = -1 //Faster, too
		alpha = 255
	else
		invisibility = initial(invisibility)
		speed = 0
		alpha = min(lums * 60, 255) //Slowly becomes more visible in brighter light

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
	else if(istype(target, /obj/machinery/door))
		forceMove(get_turf(target))
		visible_message(span_warning("Shadows creep through [target]..."), span_notice("You slip through [target]."))
		return
	..()
