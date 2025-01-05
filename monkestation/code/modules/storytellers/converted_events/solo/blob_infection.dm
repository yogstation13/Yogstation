/datum/round_event_control/antagonist/solo/blob_infection
	name = "Blob Infection"
	weight = 6
	antag_flag = ROLE_BLOB_INFECTION
	antag_datum = /datum/antagonist/blob/infection
	min_players = 35
	maximum_antags = 1
	max_occurrences = 1
	earliest_start = 80 MINUTES
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_BLUESHIELD,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	description = "Infects a crewmember with the blob overmind."
