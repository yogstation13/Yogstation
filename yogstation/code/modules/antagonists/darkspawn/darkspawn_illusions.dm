//////////Darkspawn specific illusions//////////////
/mob/living/simple_animal/hostile/illusion/darkspawn //simulacrum version
	desc = "They have a weird shimmering to them."
	maxHealth = 100
	health = 100
	pressure_resistance = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY

	speed = -1
	pass_flags = PASSTABLE | PASSMOB | PASSDOOR | PASSMACHINES | PASSMECH | PASSCOMPUTER | PASSGRILLE | PASSGLASS
	ventcrawler = TRUE

	attack_sound = 'sound/magic/voidblink.ogg'
	deathsound = 'yogstation/sound/magic/devour_will_victim.ogg'
	attacktext = "gores"
	bubble_icon = BUBBLE_DARKSPAWN

	lighting_cutoff_red = 12
	lighting_cutoff_green = 0
	lighting_cutoff_blue = 50
	lighting_cutoff = LIGHTING_CUTOFF_HIGH
	faction = list(ROLE_DARKSPAWN)
	
/mob/living/simple_animal/hostile/illusion/darkspawn/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)
	grant_language(/datum/language/darkspawn)

/mob/living/simple_animal/hostile/illusion/darkspawn/Life(seconds_per_tick, times_fired)
	. = ..()
	var/turf/T = get_turf(src)
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			adjustHealth(-2)

/mob/living/simple_animal/hostile/illusion/darkspawn/psyche //sentient version

/mob/living/simple_animal/hostile/illusion/darkspawn/psyche/Copy_Parent(mob/living/original, life, hp, damage, replicate)
	. = ..()
	life_span = INFINITY //doesn't actually despawn

/mob/living/simple_animal/hostile/illusion/darkspawn/psyche/Login()
	. = ..()
	if(mind	&& !ispsyche(src))
		mind.add_antag_datum(/datum/antagonist/psyche)

///special antagonist used to give an internal camera and antag hud to non-thrall darkspawn teammates
/datum/antagonist/psyche
	name = "Darkspawn Psyche"
	job_rank = ROLE_DARKSPAWN
	antag_hud_name = "thrall"
	roundend_category = "thralls"
	antagpanel_category = "Darkspawn"
	antag_moodlet = /datum/mood_event/thrall

/datum/antagonist/psyche/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	add_team_hud(current_mob, /datum/antagonist/darkspawn)

	current_mob.grant_language(/datum/language/darkspawn)
	current_mob.faction |= ROLE_DARKSPAWN

	current_mob.AddComponent(/datum/component/internal_cam, list(ROLE_DARKSPAWN))
	var/datum/component/internal_cam/cam = current_mob.GetComponent(/datum/component/internal_cam)
	if(cam)
		cam.change_cameranet(GLOB.thrallnet)

/datum/antagonist/psyche/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	current_mob.remove_language(/datum/language/darkspawn)
	current_mob.faction -= ROLE_DARKSPAWN
	qdel(current_mob.GetComponent(/datum/component/internal_cam))

/datum/antagonist/psyche/add_team_hud(mob/target, antag_to_check)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
		antag_to_check || type,
	))

	// Add HUDs that they couldn't see before
	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if (is_team_darkspawn(owner.current)) //needs to change this line so both the darkspawn and thrall sees it
			antag_hud.show_to(owner.current)
