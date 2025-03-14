SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	/// List of all jobs.
	var/list/occupations = list()
	/// List of jobs that can be joined through the starting menu.
	var/list/datum/job/joinable_occupations = list()
	/// Dictionary of all jobs, keys are titles.
	var/list/name_occupations = list()
	/// Dictionary of all jobs EVEN DISABLED, keys are types.
	var/list/name_occupations_all = list()
	var/list/type_occupations = list()	//Dict of all jobs, keys are types
	/// List of all departments with joinable jobs.
	var/list/datum/job_department/joinable_departments = list()
	/// List of all joinable departments indexed by their typepath, sorted by their own display order.
	var/list/datum/job_department/joinable_departments_by_type = list()
	var/list/unassigned = list()		//Players who need jobs
	var/initial_players_to_assign = 0 	//used for checking against population caps

	var/list/prioritized_jobs = list()
	var/list/latejoin_trackers = list()	//Don't read this list, use GetLateJoinTurfs() instead

	var/overflow_role = "Assistant"

	var/list/level_order = list(JP_HIGH,JP_MEDIUM,JP_LOW)

/datum/controller/subsystem/job/Initialize(timeofday)
	if(!length(occupations))
		SetupOccupations()
	if(CONFIG_GET(flag/load_jobs_from_txt))
		LoadJobs()
	set_overflow_role(CONFIG_GET(string/overflow_job))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/job/proc/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = GetJob(new_overflow_role)
	var/cap = CONFIG_GET(number/overflow_cap)

	new_overflow.spawn_positions = cap
	new_overflow.total_positions = cap

	if(new_overflow_role != overflow_role)
		var/datum/job/old_overflow = GetJob(overflow_role)
		old_overflow.spawn_positions = initial(old_overflow.spawn_positions)
		old_overflow.total_positions = initial(old_overflow.total_positions)
		overflow_role = new_overflow_role
		JobDebug("Overflow role set to : [new_overflow_role]")

/datum/controller/subsystem/job/proc/SetupOccupations(faction = "Station")
	occupations = list()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!all_jobs.len)
		to_chat(world, span_boldannounce("Error setting up jobs, no job datums found"))
		return 0
	
	var/list/new_occupations = list()
	var/list/new_joinable_occupations = list()
	var/list/new_joinable_departments = list()
	var/list/new_joinable_departments_by_type = list()

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		if(job.faction != faction)
			continue
		if(!job.config_check())
			continue

		name_occupations_all[job.title] = job

		if(SEND_SIGNAL(job, SSmapping.config.internal_name != "" ? SSmapping.config.internal_name : SSmapping.config.map_name))	//Even though we initialize before mapping, this is fine because the config is loaded at new
			testing("Removed [job.type] due to map config")
			continue

		// All jobs are late joinable at the moment

		new_occupations += job
		new_joinable_occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job

		if(!LAZYLEN(job.departments_list))
			var/datum/job_department/department = new_joinable_departments_by_type[/datum/job_department/undefined]
			if(!department)
				department = new /datum/job_department/undefined()
				new_joinable_departments_by_type[/datum/job_department/undefined] = department
			department.add_job(job)
			continue
		for(var/department_type in job.departments_list)
			var/datum/job_department/department = new_joinable_departments_by_type[department_type]
			if(!department)
				department = new department_type()
				new_joinable_departments_by_type[department_type] = department
			department.add_job(job)

	sortTim(new_occupations, /proc/cmp_job_display_asc)

	sortTim(new_joinable_departments_by_type, /proc/cmp_department_display_asc, associative = TRUE)
	for(var/department_type in new_joinable_departments_by_type)
		var/datum/job_department/department = new_joinable_departments_by_type[department_type]
		sortTim(department.department_jobs, /proc/cmp_job_display_asc)
		new_joinable_departments += department

	occupations = new_occupations
	joinable_occupations = sortTim(new_joinable_occupations, /proc/cmp_job_display_asc)
	joinable_departments = new_joinable_departments
	joinable_departments_by_type = new_joinable_departments_by_type

	return TRUE


/datum/controller/subsystem/job/proc/GetJob(rank)
	RETURN_TYPE(/datum/job)
	if(!length(occupations))
		SetupOccupations()
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	RETURN_TYPE(/datum/job)
	if(!length(occupations))
		SetupOccupations()
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/get_department_type(department_type)
	RETURN_TYPE(/datum/job_department)
	if(!length(occupations))
		SetupOccupations()
	return joinable_departments_by_type[department_type]

/datum/controller/subsystem/job/proc/GetPlayerAltTitle(mob/dead/new_player/player, rank)
	return player.client.prefs.GetPlayerAltTitle(GetJob(rank))

// Attempts to Assign player to Role
/datum/controller/subsystem/job/proc/AssignRole(mob/dead/new_player/player, rank, latejoin = FALSE)
	JobDebug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)
			return FALSE
		if(QDELETED(player) || is_banned_from(player.ckey, rank))
			return FALSE
		if(!job.player_old_enough(player.client))
			return FALSE
		if(job.required_playtime_remaining(player.client))
			return FALSE
		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		JobDebug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
		player.mind.assigned_role = rank
		player.mind.role_alt_title = GetPlayerAltTitle(player, rank)
		unassigned -= player
		job.current_positions++
		return TRUE
	JobDebug("AR has failed, Player: [player], Rank: [rank]")
	return FALSE

/datum/controller/subsystem/job/proc/FreeRole(rank)
	if(!rank)
		return
	JobDebug("Freeing role: [rank]")
	var/datum/job/job = GetJob(rank)
	if(!job)
		return FALSE
	job.current_positions = max(0, job.current_positions - 1)

/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, flag)
	JobDebug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(is_banned_from(player.ckey, job.title) || QDELETED(player))
			JobDebug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			JobDebug("FOC player not old enough, Player: [player]")
			continue
		if(job.required_playtime_remaining(player.client))
			JobDebug("FOC player not enough xp, Player: [player]")
			continue
		if(flag && (!(flag in player.client.prefs.be_special)))
			JobDebug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.mind && (job.title in player.mind.restricted_roles))
			JobDebug("FOC incompatible with antagonist role, Player: [player]")
			continue
		// yogs start - Donor features, quiet round
		if(((job.title in GLOB.command_positions) || (job.title in GLOB.nonhuman_positions)) && (player.client.prefs.read_preference(/datum/preference/toggle/quiet_mode)))
			JobDebug("FOC quiet check failed, Player: [player]")
			continue
		// yogs end
		if(player.client.prefs.job_preferences[job.title] == level)
			JobDebug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

// Fetch a random job that a specific player can use
/datum/controller/subsystem/job/proc/GetRandomJob(mob/dead/new_player/player)
	. = FALSE
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(istype(job, GetJob(SSjob.overflow_role))) // We don't want to give him assistant, that's boring!
			continue

		if(job.title in GLOB.command_positions) //If you want a command position, select it!
			continue

		if(is_banned_from(player.ckey, job.title) || QDELETED(player))
			if(QDELETED(player))
				JobDebug("GRJ isbanned failed, Player deleted")
				break
			JobDebug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			JobDebug("GRJ player not old enough, Player: [player]")
			continue

		if(job.required_playtime_remaining(player.client))
			JobDebug("GRJ player not enough xp, Player: [player]")
			continue

		if(player.mind && (job.title in player.mind.restricted_roles))
			JobDebug("GRJ incompatible with antagonist role, Player: [player], Job: [job.title]")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			JobDebug("GRJ Random job can give, Player: [player], Job: [job]")
			return job

// Assign a random job to a specific player
/datum/controller/subsystem/job/proc/GiveRandomJob(mob/dead/new_player/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	var/datum/job/job = GetRandomJob(player)
	if(job != FALSE && AssignRole(player, job.title))
		JobDebug("GRJ Random job given, Player: [player], Job: [job]")
		return TRUE

/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
			SSpersistence.antag_rep_change[player.ckey] = 0
	SetupOccupations()
	unassigned = list()
	return


//This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until
//it locates a head or runs out of levels to check
//This is basically to ensure that there's atleast a few heads in the round
/datum/controller/subsystem/job/proc/FillHeadPosition()
	for(var/level in level_order)
		for(var/command_position in GLOB.original_command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)
				continue
			if((job.current_positions >= job.total_positions) && job.total_positions != -1)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue
			var/mob/dead/new_player/candidate = PickCommander(candidates,command_position) // Yogs -- makes command jobs weighted towards players of greater experience
			if(AssignRole(candidate, command_position))
				return 1
	return 0


//This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
//This is also to ensure we get as many heads as possible
/datum/controller/subsystem/job/proc/CheckHeadPositions(level)
	for(var/command_position in GLOB.original_command_positions)
		var/datum/job/job = GetJob(command_position)
		if(!job)
			continue
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/dead/new_player/candidate = PickCommander(candidates,command_position) // Yogs -- makes command jobs weighted towards players of greater experience
		AssignRole(candidate, command_position)

/datum/controller/subsystem/job/proc/FillAIPosition()
	var/ai_selected = FALSE
	var/datum/job/job = GetJob("AI")
	if(!job)
		return FALSE
	for(var/i = job.total_positions, i > 0, i--)
		if(job.current_positions >= job.total_positions) //in case any AIs are assigned before this proc (like with the malf gamemode)
			return TRUE
		for(var/level in level_order)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/dead/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
	if(ai_selected)
		return TRUE
	return FALSE

/datum/controller/subsystem/job/proc/FillNetminPosition()
	var/datum/job/job = GetJob("Network Admin")
	if(!job)
		return
	for(var/i = job.total_positions, i > 0, i--)
		if(job.current_positions >= job.total_positions) //If we assign a netmin before this proc is run, (malf rework?)
			return TRUE
		for(var/level in level_order)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/dead/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "Network Admin"))
					break

/// Rolls a number of security based on the roundstart population
/datum/controller/subsystem/job/proc/FillSecurityPositions()
	var/coeff = CONFIG_GET(number/min_security_scaling_coeff)
	if(!coeff)
		return
	var/target_count = initial_players_to_assign / coeff
	var/current_count = 0

	for(var/level in level_order)
		for(var/security_position in GLOB.original_security_positions)
			var/datum/job/job = GetJob(security_position)
			if(!job)
				continue
			if((job.current_positions >= job.total_positions) && job.total_positions != -1)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue
			var/mob/dead/new_player/candidate = pick(candidates) // Yogs -- makes command jobs weighted towards players of greater experience
			if(AssignRole(candidate, security_position))
				current_count++
				if(current_count >= target_count)
					return TRUE
	return FALSE

/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	JobDebug("Running DO")

	//Holder for Triumvirate is stored in the SSticker, this just processes it
	if(SSticker.triai)
		for(var/datum/job/ai/A in occupations)
			A.spawn_positions = 3

	//Get the players who are ready
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences() && player.mind && !player.mind.assigned_role)
			unassigned += player

	initial_players_to_assign = unassigned.len

	JobDebug("DO, Len: [unassigned.len]")
	GLOB.event_role_manager.setup_event_positions()
	if(unassigned.len == 0)
		return TRUE

	//Scale number of open security officer slots to population
	setup_officer_positions()

	//Jobs will have fewer access permissions if the number of players exceeds the threshold defined in game_options.txt
	var/mat = CONFIG_GET(number/minimal_access_threshold)
	if(mat)
		if(mat > unassigned.len)
			CONFIG_SET(flag/jobs_have_minimal_access, FALSE)
		else
			CONFIG_SET(flag/jobs_have_minimal_access, TRUE)

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	//People who wants to be the overflow role, sure, go on.
	JobDebug("DO, Running Overflow Check 1")
	var/datum/job/overflow = GetJob(SSjob.overflow_role)
	var/list/overflow_candidates = FindOccupationCandidates(overflow, 3)
	JobDebug("AC1, Candidates: [overflow_candidates.len]")
	for(var/mob/dead/new_player/player in overflow_candidates)
		JobDebug("AC1 pass, Player: [player]")
		AssignRole(player, SSjob.overflow_role)
		overflow_candidates -= player
	JobDebug("DO, AC1 end")

	//Select one head
	JobDebug("DO, Running Head Check")
	FillHeadPosition()
	JobDebug("DO, Head Check end")

	//Check for an AI
	JobDebug("DO, Running AI Check")
	if(FillAIPosition())
		FillNetminPosition()
	JobDebug("DO, AI Check end")

	//Check for Security
	JobDebug("DO, Running Security Check")
	FillSecurityPositions()
	JobDebug("DO, Security Check end")

	//Other jobs are now checked
	JobDebug("DO, Running Standard Check")


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level in level_order)
		//Check the head jobs first each level
		CheckHeadPositions(level)

		// Loop through all unassigned players
		for(var/mob/dead/new_player/player in unassigned)
			if(PopcapReached())
				RejectPlayer(player)

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(is_banned_from(player.ckey, job.title))
					JobDebug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(QDELETED(player))
					JobDebug("DO player deleted during job ban check")
					break

				if(!job.player_old_enough(player.client))
					JobDebug("DO player not old enough, Player: [player], Job:[job.title]")
					continue

				if(job.required_playtime_remaining(player.client))
					JobDebug("DO player not enough xp, Player: [player], Job:[job.title]")
					continue

				if(player.mind && (job.title in player.mind.restricted_roles))
					JobDebug("DO incompatible with antagonist role, Player: [player], Job:[job.title]")
					continue

				// If the player wants that job on this level, then try give it to him.
				if(player.client.prefs.job_preferences[job.title] == level)
					// If the job isn't filled
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						JobDebug("DO pass, Player: [player], Level:[level], Job:[job.title]")
						AssignRole(player, job.title)
						unassigned -= player
						break


	JobDebug("DO, Handling unassigned.")
	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/dead/new_player/player in unassigned)
		HandleUnassigned(player)

	JobDebug("DO, Handling unrejectable unassigned")
	//Mop up people who can't leave.
	for(var/mob/dead/new_player/player in unassigned) //Players that wanted to back out but couldn't because they're antags (can you feel the edge case?)
		if(!GiveRandomJob(player))
			if(!AssignRole(player, SSjob.overflow_role)) //If everything is already filled, make them an assistant
				return FALSE //Living on the edge, the forced antagonist couldn't be assigned to overflow role (bans, client age) - just reroll

	return TRUE

//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/dead/new_player/player)
	var/jobless_role = player.client.prefs.read_preference(/datum/preference/choiced/jobless_role)

	if(PopcapReached())
		RejectPlayer(player)
		return
	
	switch (jobless_role)
		if (BEOVERFLOW)
			var/allowed_to_be_a_loser = !is_banned_from(player.ckey, SSjob.overflow_role)
			if(QDELETED(player) || !allowed_to_be_a_loser)
				RejectPlayer(player)
			else
				if(!AssignRole(player, SSjob.overflow_role))
					RejectPlayer(player)
		if (BERANDOMJOB)
			if(!GiveRandomJob(player))
				RejectPlayer(player)
		if (RETURNTOLOBBY)
			RejectPlayer(player)
		else //Something gone wrong if we got here.
			var/message = "DO: [player] fell through handling unassigned"
			JobDebug(message)
			log_game(message)
			message_admins(message)
			RejectPlayer(player)

//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/living/M, rank, joined_late = FALSE)
	var/mob/dead/new_player/newplayer
	var/mob/living/living_mob
	if(!joined_late)
		newplayer = M
		living_mob = newplayer.new_character
	else
		living_mob = M

	var/datum/job/job = GetJob(rank)

	living_mob.job = rank

	//If we joined at roundstart we should be positioned at our workstation 
	if(!joined_late)
		var/spawning_handled = FALSE
		var/obj/S = null
		if(HAS_TRAIT(SSstation, STATION_TRAIT_RANDOM_ARRIVALS))
			spawning_handled = DropLandAtRandomHallwayPoint(living_mob)
		if(length(GLOB.jobspawn_overrides[rank]) && !spawning_handled)
			S = pick(GLOB.jobspawn_overrides[rank])
		else if(!spawning_handled)
			for(var/obj/effect/landmark/start/sloc in GLOB.start_landmarks_list)
				if(sloc.name != rank)
					S = sloc //so we can revert to spawning them on top of eachother if something goes wrong
					continue
				if(locate(/mob/living) in sloc.loc)
					continue
				S = sloc
				sloc.used = TRUE
				break
		if(S)
			S.JoinPlayerHere(living_mob, FALSE)
		if(!S && !spawning_handled) //if there isn't a spawnpoint send them to latejoin, if there's no latejoin go yell at your mapper
			log_mapping("Job [job.title] ([job.type]) couldn't find a round start spawn point.")
			SendToLateJoin(living_mob)

	var/alt_title = null
	if(living_mob.mind)
		living_mob.mind.assigned_role = rank
		alt_title = living_mob.mind.role_alt_title
	to_chat(M, "<b>You are the [alt_title ? alt_title : rank].</b>")
	if(job)
		var/new_mob = job.equip(living_mob, null, null, joined_late , null, M.client)
		if(ismob(new_mob))
			living_mob = new_mob
			if(!joined_late)
				newplayer.new_character = living_mob
			else
				M = living_mob
			
		SSpersistence.antag_rep_change[M.client.ckey] += job.GetAntagRep()

		if(M.client.holder)
			if(CONFIG_GET(flag/auto_deadmin_players) || (M.client.prefs?.toggles & DEADMIN_ALWAYS))
				M.client.holder.auto_deadmin()
			else
				handle_auto_deadmin_roles(M.client, rank)
		to_chat(M, "<b>As the [alt_title ? alt_title : rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")
		job.radio_help_message(M)
		if((GLOB.admin_event && GLOB.admin_event.greet_role(M, job.type)) || job.req_admin_notify)
			to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
		//YOGS start
		if(job.space_law_notify)
			to_chat(M, "<FONT color='red'><b>Space Law has been updated! </font><a href='https://wiki.yogstation.net/wiki/Space_Law'>Click here to view the updates.</a></b>")
		//YOGS end
		if(CONFIG_GET(number/minimal_access_threshold))
			to_chat(M, span_notice("<B>As this station was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "full crew, only your job's necessities" : "skeleton crew, additional access may"] have been added to your ID card.</B>"))
	var/related_policy = get_policy(rank)
	if(related_policy)
		to_chat(M,related_policy)
	if(ishuman(living_mob))
		var/mob/living/carbon/human/wageslave = living_mob
		living_mob.add_memory("Your account ID is [wageslave.account_id].")
	if(job && living_mob)
		job.after_spawn(living_mob, M, joined_late) // note: this happens before the mob has a key! M will always have a client, H might not.

	job.give_donor_stuff(living_mob, M) // yogs - Donor Features
	job.give_cape(living_mob, M)
	job.give_map_flare(living_mob, M)
	var/obj/item/modular_computer/RPDA = locate(/obj/item/modular_computer/tablet) in living_mob.get_all_contents()
	if(istype(RPDA))
		RPDA.device_theme = GLOB.pda_themes[M.client?.prefs.read_preference(/datum/preference/choiced/pda_theme)]
		var/obj/item/computer_hardware/hard_drive/hard_drive = RPDA.all_components[MC_HDD]
		var/datum/computer_file/program/pdamessager/msgr = locate(/datum/computer_file/program/pdamessager) in hard_drive.stored_files
		if(msgr)
			msgr.username = "[living_mob.real_name] ([alt_title ? alt_title : rank])"
			msgr.receiving = TRUE
	if(SSgamemode.holidays && SSgamemode.holidays["St. Patrick's Day"])
		irish_override() // Assuming direct control.
	else if(living_mob.job == "Clerk")
		job.give_clerk_choice(living_mob, M)
	else if(living_mob.job == "Chaplain")
		job.give_chapel_choice(living_mob, M)
	log_game("[living_mob.real_name]/[M.client.ckey] joined the round as [living_mob.job].") //yogs - Job logging

	return living_mob

/datum/controller/subsystem/job/proc/irish_override()
	var/datum/map_template/template = SSmapping.station_room_templates["Bar Irish"]

	for(var/obj/effect/landmark/stationroom/box/bar/B in GLOB.landmarks_list)
		template.load(B.loc, centered = FALSE)
		qdel(B)

/datum/controller/subsystem/job/proc/random_chapel_init()
	try
		var/list/player_box = list()
		for(var/mob/H in GLOB.player_list)
			if(H.client && H.client.prefs) // Prefs was null once and there was no CHAPEL
				player_box += H.client.prefs.read_preference(/datum/preference/choiced/chapel_choice)

		var/choice
		if(player_box.len == 0)
			choice = "Random"
		else
			choice = pick(player_box)

		if(choice != "Random")
			var/chapel_sanitize = FALSE
			for(var/A in GLOB.potential_box_chapels)
				if(choice == A)
					chapel_sanitize = TRUE
					break

			if(!chapel_sanitize)
				choice = "Random"

		if(choice == "Random")
			choice = pick(GLOB.potential_box_chapels)

		var/datum/map_template/template = SSmapping.station_room_templates[choice]

		if(isnull(template))
			message_admins("WARNING: CHAPEL TEMPLATE [choice] FAILED TO LOAD! ATTEMPTING TO LOAD BACKUP")
			log_game("WARNING: CHAPEL TEMPLATE [choice] FAILED TO LOAD! ATTEMPTING TO LOAD BACKUP")
			for(var/backup_chapel in GLOB.potential_box_chapels)
				template = SSmapping.station_room_templates[backup_chapel]
				if(!isnull(template))
					break
				message_admins("WARNING: CHAPEL TEMPLATE [backup_chapel] FAILED TO LOAD! ATTEMPTING TO LOAD BACKUP")
				log_game("WARNING: CHAPEL TEMPLATE [backup_chapel] FAILED TO LOAD! ATTEMPTING TO LOAD BACKUP")

		if(isnull(template))
			message_admins("WARNING: CHAPEL RECOVERY FAILED! THERE WILL BE NO CHAPEL FOR THIS ROUND!")
			log_game("WARNING: CHAPEL RECOVERY FAILED! THERE WILL BE NO CHAPEL FOR THIS ROUND!")
			return

		for(var/obj/effect/landmark/stationroom/box/chapel/B in GLOB.landmarks_list)
			template.load(B.loc, centered = FALSE)
			qdel(B)
	catch(var/exception/e)
		message_admins("RUNTIME IN RANDOM_CHAPEL_INIT")
		spawn_chapel()
		throw e

/proc/spawn_chapel()
	var/datum/map_template/template
	for(var/backup_chapel in GLOB.potential_box_chapels)
		template = SSmapping.station_room_templates[backup_chapel]
		if(!isnull(template))
			break
	if(isnull(template))
		message_admins("UNABLE TO SPAWN CHAPEL")

	for(var/obj/effect/landmark/stationroom/box/chapel/B in GLOB.landmarks_list)
		template.load(B.loc, centered = FALSE)
		qdel(B)

/datum/controller/subsystem/job/proc/random_clerk_init()
	try
		var/list/player_box = list()
		for(var/mob/H in GLOB.player_list)
			if(H.client && H.client.prefs) // Prefs was null once and there was no clerk
				player_box += H.client.prefs.read_preference(/datum/preference/choiced/clerk_choice)

		var/choice
		if(player_box.len == 0)
			choice = "Random"
		else
			choice = pick(player_box)

		if(choice != "Random")
			var/clerk_sanitize = FALSE
			for(var/A in GLOB.potential_box_clerk)
				if(choice == A)
					clerk_sanitize = TRUE
					break
		
			if(!clerk_sanitize)
				choice = "Random"
		
		if(choice == "Random")
			choice = pick(GLOB.potential_box_clerk)

		var/datum/map_template/template = SSmapping.station_room_templates[choice]

		if(isnull(template))
			message_admins("WARNING: CLERK TEMPLATE [choice] FAILED TO LOAD! ATTEMPTING TO LOAD BACKUP")
			log_game("WARNING: CLERK TEMPLATE [choice] FAILED TO LOAD! ATTEMPTING TO LOAD BACKUP")
			for(var/backup_clerk in GLOB.potential_box_clerk)
				template = SSmapping.station_room_templates[backup_clerk]
				if(!isnull(template))
					break
				message_admins("WARNING: CLERK TEMPLATE [backup_clerk] FAILED TO LOAD! ATTEMPTING TO LOAD BACKUP")
				log_game("WARNING: CLERK TEMPLATE [backup_clerk] FAILED TO LOAD! ATTEMPTING TO LOAD BACKUP")

		if(isnull(template))
			message_admins("WARNING: CLERK RECOVERY FAILED! THERE WILL BE NO CLERK SHOP FOR THIS ROUND!")
			log_game("WARNING: CLERK RECOVERY FAILED! THERE WILL BE NO CLERK SHOP FOR THIS ROUND!")
			return

		for(var/obj/effect/landmark/stationroom/box/clerk/B in GLOB.landmarks_list)
			template.load(B.loc, centered = FALSE)
			qdel(B)
	catch(var/exception/e)
		message_admins("RUNTIME IN RANDOM_CLERK_INIT")
		spawn_clerk()
		throw e

/proc/spawn_clerk()
	var/datum/map_template/template
	for(var/backup_clerk in GLOB.potential_box_clerk)
		template = SSmapping.station_room_templates[backup_clerk]
		if(!isnull(template))
			break
	if(isnull(template))
		message_admins("UNABLE TO SPAWN CLERK")
	
	for(var/obj/effect/landmark/stationroom/box/clerk/B in GLOB.landmarks_list)
		template.load(B.loc, centered = FALSE)
		qdel(B)

/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, rank)
	if(!C?.holder)
		return TRUE
	var/datum/job/job = GetJob(rank)
	if(!job)
		return
	if((job.auto_deadmin_role_flags & DEADMIN_POSITION_CRITICAL) && (CONFIG_GET(flag/auto_deadmin_critical) || (C.prefs?.toggles & DEADMIN_POSITION_CRITICAL)))
		return C.holder.auto_deadmin()
	if((job.auto_deadmin_role_flags & DEADMIN_POSITION_HEAD) && (CONFIG_GET(flag/auto_deadmin_heads) || (C.prefs?.toggles & DEADMIN_POSITION_HEAD)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SECURITY) && (CONFIG_GET(flag/auto_deadmin_security) || (C.prefs?.toggles & DEADMIN_POSITION_SECURITY)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SILICON) && (CONFIG_GET(flag/auto_deadmin_silicons) || (C.prefs?.toggles & DEADMIN_POSITION_SILICON))) //in the event there's ever psuedo-silicon roles added, ie synths.
		return C.holder.auto_deadmin()

/datum/controller/subsystem/job/proc/setup_officer_positions()
	var/datum/job/J = SSjob.GetJob("Security Officer")
	if(!J)
		CRASH("setup_officer_positions(): Security officer job is missing")

	var/ssc = CONFIG_GET(number/security_scaling_coeff)
	if(ssc > 0)
		if(J.spawn_positions > 0)
			var/officer_positions = min(12, max(J.spawn_positions, round(unassigned.len / ssc))) //Scale between configured minimum and 12 officers
			JobDebug("Setting open security officer positions to [officer_positions]")
			J.total_positions = officer_positions
			J.spawn_positions = officer_positions

	//Spawn some extra eqipment lockers if we have more than 5 officers
	var/equip_needed = J.total_positions
	if(equip_needed < 0) // -1: infinite available slots
		equip_needed = 12
	for(var/i=equip_needed-5, i>0, i--)
		if(GLOB.secequipment.len)
			var/spawnloc = GLOB.secequipment[1]
			new /obj/structure/closet/secure_closet/security/sec(spawnloc)
			GLOB.secequipment -= spawnloc
		else //We ran out of spare locker spawns!
			break


/datum/controller/subsystem/job/proc/LoadJobs()
	var/jobstext = file2text("[global.config.directory]/jobs.txt")
	for(var/datum/job/J in occupations)
		var/regex/jobs = new("[J.title]=(-1|\\d+),(-1|\\d+)")
		jobs.Find(jobstext)
		J.total_positions = text2num(jobs.group[1])
		J.spawn_positions = text2num(jobs.group[2])

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)
		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		for(var/mob/dead/new_player/player in GLOB.player_list)
			if(!(player.ready == PLAYER_READY_TO_PLAY && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(is_banned_from(player.ckey, job.title) || QDELETED(player))
				banned++
				continue
			if(!job.player_old_enough(player.client))
				young++
				continue
			if(job.required_playtime_remaining(player.client))
				young++
				continue
			switch(player.client.prefs.job_preferences[job.title])
				if(JP_HIGH)
					high++
				if(JP_MEDIUM)
					medium++
				if(JP_LOW)
					low++
				else
					never++
		SSblackbox.record_feedback("nested tally", "job_preferences", high, list("[job.title]", "high"))
		SSblackbox.record_feedback("nested tally", "job_preferences", medium, list("[job.title]", "medium"))
		SSblackbox.record_feedback("nested tally", "job_preferences", low, list("[job.title]", "low"))
		SSblackbox.record_feedback("nested tally", "job_preferences", never, list("[job.title]", "never"))
		SSblackbox.record_feedback("nested tally", "job_preferences", banned, list("[job.title]", "banned"))
		SSblackbox.record_feedback("nested tally", "job_preferences", young, list("[job.title]", "young"))

/datum/controller/subsystem/job/proc/PopcapReached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0

/datum/controller/subsystem/job/proc/RejectPlayer(mob/dead/new_player/player)
	if(player.mind && player.mind.special_role)
		return
	if(PopcapReached())
		JobDebug("Popcap overflow Check observer located, Player: [player]")
	JobDebug("Player rejected :[player]")
	to_chat(player, "<b>You have failed to qualify for any job you desired.</b>")
	unassigned -= player
	player.ready = PLAYER_NOT_READY


/datum/controller/subsystem/job/Recover()
	set waitfor = FALSE
	var/oldjobs = SSjob.occupations
	sleep(2 SECONDS)
	for (var/datum/job/J in oldjobs)
		INVOKE_ASYNC(src, PROC_REF(RecoverJob), J)

/datum/controller/subsystem/job/proc/RecoverJob(datum/job/J)
	var/datum/job/newjob = GetJob(J.title)
	if (!istype(newjob))
		return
	newjob.total_positions = J.total_positions
	newjob.spawn_positions = J.spawn_positions
	newjob.current_positions = J.current_positions

/atom/proc/JoinPlayerHere(mob/M, buckle)
	// By default, just place the mob on the same turf as the marker or whatever.
	M.forceMove(get_turf(src))

/obj/structure/chair/JoinPlayerHere(mob/M, buckle)
	. = ..()
	// Placing a mob in a chair will attempt to buckle it, or else fall back to default.
	if (buckle && isliving(M) && buckle_mob(M, FALSE, FALSE))
		return

/obj/machinery/cryopod/JoinPlayerHere(mob/M, buckle)
	. = ..()
	open_machine()
	if(iscarbon(M))
		apply_effects_to_mob(M)

/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	var/atom/destination
	if(M?.mind?.assigned_role && length(GLOB.jobspawn_overrides[M.mind.assigned_role])) //We're doing something special today.
		destination = pick(GLOB.jobspawn_overrides[M.mind.assigned_role])
		destination.JoinPlayerHere(M, FALSE)
		return

	if(latejoin_trackers.len)
		destination = pick(latejoin_trackers)
		destination.JoinPlayerHere(M, buckle)
		return

	//bad mojo
	if(SSmapping.config.cryo_spawn)
		destination = get_cryo_spawn_points()
	else
		destination = get_last_resort_spawn_points()
	
	destination.JoinPlayerHere(M, buckle)

/datum/controller/subsystem/job/proc/get_cryo_spawn_points()
	var/area/shuttle/arrival/cryo_spawn_area = GLOB.areas_by_type[/area/crew_quarters/cryopods]
	if(!isnull(cryo_spawn_area))
		var/list/turf/available_turfs = list()
		for (var/list/zlevel_turfs as anything in cryo_spawn_area.get_zlevel_turf_lists())
			for (var/turf/arrivals_turf as anything in zlevel_turfs)
				var/obj/machinery/cryopod/spawn_pod = locate() in arrivals_turf
				if(!isnull(spawn_pod))
					return spawn_pod
				if(arrivals_turf.is_blocked_turf(TRUE))
					continue
				available_turfs += arrivals_turf

		if(length(available_turfs))
			return pick(available_turfs)

	stack_trace("Unable to find cryo spawn point.")
	return GET_ERROR_ROOM

/datum/controller/subsystem/job/proc/get_last_resort_spawn_points()
	var/area/shuttle/arrival/arrivals_area = GLOB.areas_by_type[/area/shuttle/arrival]
	if(!isnull(arrivals_area))
		var/list/turf/available_turfs = list()
		for (var/list/zlevel_turfs as anything in arrivals_area.get_zlevel_turf_lists())
			for (var/turf/arrivals_turf as anything in zlevel_turfs)
				var/obj/structure/chair/shuttle_chair = locate() in arrivals_turf
				if(!isnull(shuttle_chair))
					return shuttle_chair
				if(arrivals_turf.is_blocked_turf(TRUE))
					continue
				available_turfs += arrivals_turf

		if(length(available_turfs))
			return pick(available_turfs)

	stack_trace("Unable to find last resort spawn point.")
	return GET_ERROR_ROOM

///Lands specified mob at a random spot in the hallways
/datum/controller/subsystem/job/proc/DropLandAtRandomHallwayPoint(mob/living/living_mob)
	var/turf/spawn_turf = get_safe_random_station_turf(typesof(/area/hallway) - typesof(/area/hallway/secondary))
	if(!spawn_turf)
		return FALSE
	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()
	living_mob.forceMove(toLaunch)
	new /obj/effect/DPtarget(spawn_turf, toLaunch)
	return TRUE

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_heads()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.alive_mob_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.command_positions))
			. |= player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/controller/subsystem/job/proc/get_all_heads()
	. = list()
	for(var/i in GLOB.mob_list)
		var/mob/player = i
		if(player.mind && (player.mind.assigned_role in GLOB.command_positions))
			. |= player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_sec()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.carbon_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_all_sec()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.carbon_list)
		if(player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind

/datum/controller/subsystem/job/proc/JobDebug(message)
	log_job_debug(message)
