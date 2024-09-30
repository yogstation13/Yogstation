/datum/round_event_control/antagonist/solo/obsessed
	name = "Compulsive Obsession"
	antag_flag = ROLE_OBSESSED
	tags = list(TAG_CREW_ANTAG, TAG_TARGETED)
	antag_datum = /datum/antagonist/obsessed
	typepath = /datum/round_event/antagonist/solo/obsessed
	restricted_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_AI,
		JOB_CYBORG,
		ROLE_POSIBRAIN,
	)
	maximum_antags = 1
	weight = 1
	max_occurrences = 2
	min_players = 5
	prompted_picking = TRUE

/datum/round_event/antagonist/solo/obsessed

/datum/round_event/antagonist/solo/obsessed/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.add_antag_datum(antag_datum)
	var/mob/living/carbon/human/current = antag_mind.current
	current.gain_trauma(/datum/brain_trauma/special/obsessed)
