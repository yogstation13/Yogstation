/datum/round_event_control/antagonist/solo/darkspawn
	name = "Darkspawn"
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
		JOB_PRISONER,
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
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	base_antags = 2
	maximum_antags = 4
	min_players = 25
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 4
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

//TEMP REMOVAL FOR TESTING
/*/datum/round_event/antagonist/solo/bloodcult/round_end_report()
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
		return

	SSticker.mode_result = "loss - staff stopped the cult"

	if(main_cult.size_at_maximum == 0)
		CRASH("Cult team existed with a size_at_maximum of 0 at round end!")

	// If more than a certain ratio of our cultists have escaped, give the "cult escape" resport.
	// Otherwise, give the "cult failure" report.
	var/ratio_to_be_considered_escaped = 0.5
	var/escaped_cultists = 0
	for(var/datum/mind/escapee as anything in main_cult.members)
		if(considered_escaped(escapee))
			escaped_cultists++

	SSticker.news_report = (escaped_cultists / main_cult.size_at_maximum) >= ratio_to_be_considered_escaped ? CULT_ESCAPE : CULT_FAILURE*/
