////////////////////
/////BODYPARTS/////
////////////////////
/obj/item/bodypart
	var/should_draw_yogs = FALSE
	
/mob/living/carbon/proc/draw_yogs_parts(do_it)
	for(var/O in bodyparts)
		var/obj/item/bodypart/B = O
		B.should_draw_yogs = do_it

/datum/species
	var/yogs_draw_robot_hair = FALSE //DAMN ROBOTS STEALING OUR HAIR AND AIR
	var/yogs_virus_infect_chance = 100
	var/virus_resistance_boost = 0
	var/virus_stealth_boost = 0
	var/virus_stage_rate_boost = 0
	var/virus_transmittable_boost = 0

/datum/species/proc/spec_AltClickOn(atom/A,mob/living/carbon/human/H)
	return 0