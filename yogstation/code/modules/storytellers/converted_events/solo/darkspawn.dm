/datum/round_event_control/antagonist/solo/darkspawn
	name = "Darkspawns"
	tags = list(TAG_SPOOKY, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_MAGICAL)
	antag_flag = ROLE_DARKSPAWN
	antag_datum = /datum/antagonist/darkspawn
	typepath = /datum/round_event/antagonist/solo/darkspawn
	shared_occurence_type = SHARED_HIGH_THREAT
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
	required_enemies = 3
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	base_antags = 2
	maximum_antags = 4
	min_players = 25
	roundstart = TRUE
	title_icon = "darkspawn"
	earliest_start = 0 SECONDS
	denominator = 30 //slightly more people for additional darkspawns
	weight = 8
	max_occurrences = 1

/datum/round_event/antagonist/solo/darkspawn
	excute_round_end_reports = TRUE
	end_when = 60000
	var/static/datum/team/darkspawn/dark_team

/datum/round_event/antagonist/solo/darkspawn/setup()
	. = ..()
	if(!dark_team)
		dark_team = new()
		dark_team.update_objectives()
	GLOB.thrallnet.name = "Thrall net"

/datum/round_event/antagonist/solo/darkspawn/start()
	. = ..()
	dark_team.update_objectives()
