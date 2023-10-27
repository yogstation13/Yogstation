/datum/round_event_control/felinidrat
	name = "Felinid Rat Obsession"
	typepath = /datum/round_event/felinidrat
	weight = 20
	max_occurrences = 4
	earliest_start = 10 MINUTES
	
/datum/round_event/felinidrat
	fakeable = FALSE

/datum/round_event/felinidrat/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(!iscatperson(H))
			continue
		var/foundAlready = FALSE
		for(var/datum/brain_trauma/hypnosis/A in H.get_traumas())
			foundAlready = TRUE
			break
		if(foundAlready)
			continue
		H.gain_trauma(/datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY, "You feel a need to show how much you appreciate your department head. Bring them a dead rat as a gift!")
		announce_to_ghosts(H)
		break
