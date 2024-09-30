/datum/round_event_control/antagonist/solo/clockcult
	name = "Clock Cult"
	tags = list(TAG_SPOOKY, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL, TAG_MAGICAL)
	antag_flag = ROLE_SERVANT_OF_RATVAR
	antag_datum = /datum/antagonist/clockcult
	typepath = /datum/round_event/antagonist/solo/clockcult
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	required_enemies = 3
	base_antags = 3
	maximum_antags = 4
	min_players = 25
	roundstart = TRUE
	title_icon = "clockcult"
	earliest_start = 0 SECONDS
	weight = 4
	shared_occurence_type = SHARED_HIGH_THREAT
	max_occurrences = 1

/datum/round_event/antagonist/solo/clockcult
	end_when = 60000

/datum/round_event/antagonist/solo/clockcult/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.special_role = ROLE_SERVANT_OF_RATVAR
	antag_mind.assigned_role = ROLE_SERVANT_OF_RATVAR
	antag_mind.add_antag_datum(antag_datum)
