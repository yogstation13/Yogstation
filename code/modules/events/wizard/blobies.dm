/datum/round_event_control/wizard/blobies //avast!
	name = "Zombie Outbreak"
	weight = 3
	typepath = /datum/round_event/wizard/blobies
	max_occurrences = 3
	description = "Spawns a blob spore on every corpse."
//monkestation edit start
	min_wizard_trigger_potency = 5
	max_wizard_trigger_potency = 7

/datum/round_event/wizard/blobies/start()
	for(var/mob/living/carbon/human/H in GLOB.dead_mob_list)
		if(is_station_level(H.loc))
			new /mob/living/basic/blob_minion/spore/minion(H.loc) // Creates zombies which ghosts can control
//monkestation edit end
