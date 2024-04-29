////////////////////
/////BODYPARTS/////
////////////////////
/datum/species
	var/yogs_draw_robot_hair = FALSE //DAMN ROBOTS STEALING OUR HAIR AND AIR
	var/yogs_virus_infect_chance = 100
	var/virus_resistance_boost = 0
	var/virus_stealth_boost = 0
	var/virus_stage_rate_boost = 0
	var/virus_transmittable_boost = 0

/datum/species/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(yogs_draw_robot_hair)
		for(var/obj/item/bodypart/BP in C.bodyparts)
			BP.yogs_draw_robot_hair = TRUE
		
/datum/species/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	for(var/obj/item/bodypart/BP in C.bodyparts)
		BP.yogs_draw_robot_hair = initial(BP.yogs_draw_robot_hair)

/datum/species/proc/spec_AltClickOn(atom/A,mob/living/carbon/human/H)
	return FALSE
