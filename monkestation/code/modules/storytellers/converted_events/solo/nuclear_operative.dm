/datum/round_event_control/antagonist/solo/nuclear_operative
	name = "Roundstart Nuclear Operative"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL)
	antag_flag = ROLE_OPERATIVE
	antag_datum = /datum/antagonist/nukeop
	typepath = /datum/round_event/antagonist/solo/nuclear_operative
	shared_occurence_type = SHARED_HIGH_THREAT
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_BLUESHIELD,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	base_antags = 3
	maximum_antags = 5
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
	)
	required_enemies = 5
	// I give up, just there should be enough heads with 35 players...
	min_players = 35
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 4
	max_occurrences = 3
	event_icon_state = "nukeops"

/datum/round_event/antagonist/solo/nuclear_operative
	excute_round_end_reports = TRUE
	var/required_role = ROLE_NUCLEAR_OPERATIVE
	var/job_type = /datum/job/nuclear_operative
	var/antag_type = /datum/antagonist/nukeop
	var/leader_antag_type = /datum/antagonist/nukeop/leader
	var/datum/team/nuclear/nuke_team

/datum/round_event/antagonist/solo/nuclear_operative/start()
	var/datum/mind/most_experienced = get_most_experienced(setup_minds, required_role) || setup_minds[1]
	prepare(most_experienced)
	var/datum/antagonist/nukeop/leader/leader = most_experienced.add_antag_datum(leader_antag_type)
	nuke_team = leader.nuke_team
	for(var/datum/mind/antag_mind as anything in setup_minds - most_experienced)
		prepare(antag_mind)
		var/datum/antagonist/nukeop/op = new antag_type
		op.nuke_team = nuke_team
		antag_mind.add_antag_datum(op)

/// Frees the target mind's job slot, clears and deletes all their items, creates a fresh body for them, and sets
/datum/round_event/antagonist/solo/nuclear_operative/proc/prepare(datum/mind/antag_mind)
	var/mob/living/current_mob = antag_mind.current
	SSjob.FreeRole(antag_mind.assigned_role.title)
	current_mob.clear_inventory()
	create_human_mob_copy(get_turf(current_mob), current_mob)
	antag_mind.set_assigned_role(SSjob.GetJobType(job_type))
	antag_mind.special_role = required_role

/datum/round_event/antagonist/solo/nuclear_operative/add_datum_to_mind(datum/mind/antag_mind)
	CRASH("this should not be called")

/datum/round_event/antagonist/solo/nuclear_operative/round_end_report()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH
