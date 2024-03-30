/mob/living/simple_animal/hostile/crawling_shadows
	//appearance variables
	name = "crawling shadows"
	desc = "A formless mass of nothingness with piercing white eyes."
	icon = 'yogstation/icons/mob/darkspawn.dmi' //Placeholder sprite
	icon_state = "crawling_shadows"
	icon_living = "crawling_shadows"

	//survival variables
	maxHealth = 10
	health = 10
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
	melee_damage_lower = 5
	melee_damage_upper = 5

	//sight variables
	lighting_cutoff_red = 12
	lighting_cutoff_green = 0
	lighting_cutoff_blue = 50
	lighting_cutoff = LIGHTING_CUTOFF_HIGH

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

/mob/living/simple_animal/hostile/crawling_shadows/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)

/mob/living/simple_animal/hostile/crawling_shadows/Move()
	. = ..()
	update_light_speed()
	move_count++
	if(move_count >= 4)
		playsound(get_turf(src), "crawling_shadows_walk", 25, 0)
		move_count = 0

/mob/living/simple_animal/hostile/crawling_shadows/proc/update_light_speed()
	var/turf/T = get_turf(src)
	var/lums = T.get_lumcount()
	if(lums < SHADOW_SPECIES_BRIGHT_LIGHT)
		speed = -1 //Faster, too
		alpha = max(alpha - ((SHADOW_SPECIES_BRIGHT_LIGHT - lums) * 60), 0) //Rapidly becomes more invisible in the dark
	else
		speed = 0
		alpha = min(alpha + (lums * 30), 255) //Slowly becomes more visible in brighter light
	update_simplemob_varspeed()
