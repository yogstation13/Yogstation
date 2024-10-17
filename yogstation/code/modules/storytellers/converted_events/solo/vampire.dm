/datum/round_event_control/antagonist/solo/vampire
	antag_flag = ROLE_VAMPIRE
	tags = list(TAG_COMBAT, TAG_MAGICAL, TAG_CREW_ANTAG)
	antag_datum = /datum/antagonist/vampire
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
		JOB_CHAPLAIN
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	min_players = 15
	weight = 10
	maximum_antags = 2

/datum/round_event_control/antagonist/solo/vampire/roundstart
	name = "Vampires"
	roundstart = TRUE
	title_icon = "vampires"
	earliest_start = 0 SECONDS

/datum/round_event_control/antagonist/solo/vampire/midround
	name = "Vampiric Accident"
	max_occurrences = 1
