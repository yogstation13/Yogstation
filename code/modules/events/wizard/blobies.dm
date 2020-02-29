/datum/round_event_control/wizard/blobies //avast!
	name = "Mass Zombie Outbreak" //yogs zombie memes
	weight = 3
	typepath = /datum/round_event/wizard/blobies
	max_occurrences = 3

/datum/round_event/wizard/blobies/start()

	for(var/mob/living/carbon/human/H in GLOB.dead_mob_list)
		new /mob/living/simple_animal/hostile/zombie/mostlyinfection(H.loc) //zombie memes