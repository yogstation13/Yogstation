/datum/round_event_control
	///do we check against the antag cap before attempting a spawn?
	var/checks_antag_cap = FALSE
	/// List of enemy roles, will check if x amount of these exist exist
	var/list/enemy_roles
	///required number of enemies in roles to exist
	var/required_enemies = 0

/datum/round_event_control/proc/return_failure_string(players_amt)
	var/string
	if(roundstart && (world.time-SSticker.round_start_time >= 2 MINUTES))
		string += "Roundstart"
	if(occurrences >= max_occurrences)
		if(string)
			string += ",<br>"
		string += "Cap Reached"
	if(earliest_start >= world.time-SSticker.round_start_time)
		if(string)
			string += ",<br>"
		string +="Too Soon"
	if(players_amt < min_players)
		if(string)
			string += ",<br>"
		string += "Lack of players"
	if(holidayID && !check_holidays(holidayID))
		if(string)
			string += ",<br>"
		string += "Holiday Event"
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		if(string)
			string += ",<br>"
		string += "Round End"
	if(checks_antag_cap)
		if(!roundstart && !SSgamemode.can_inject_antags())
			if(string)
				string += ",<br>"
			string += "Too Many Antags"
	return string

/datum/round_event_control/antagonist/return_failure_string(players_amt)
	. =..()
	if(!check_enemies())
		if(.)
			. += ",<br>"
		. += "No Enemies"
	if(!check_required())
		if(.)
			. += ",<br>"
		. += "No Required"
	return .

/datum/round_event_control/antagonist/solo/return_failure_string(players_amt)
	. =..()

	var/antag_amt = get_antag_amount()
	var/list/candidates = get_candidates() //we should optimize this
	if(length(candidates) < antag_amt)
		if(.)
			. += ",<br>"
		. += "Not Enough Candidates!"

	return .

/datum/round_event_control/antagonist
	checks_antag_cap = TRUE
	track = EVENT_TRACK_ROLESET
	///list of required roles, needed for this to form
	var/list/exclusive_roles
	/// Protected roles from the antag roll. People will not get those roles if a config is enabled
	var/list/protected_roles
	/// Restricted roles from the antag roll
	var/list/restricted_roles

/datum/round_event_control/antagonist/proc/check_required()
	if(!length(exclusive_roles))
		return TRUE
	for (var/mob/M in SSgamemode.current_players[CURRENT_LIVING_PLAYERS])
		if (M.stat == DEAD)
			continue // Dead players cannot count as passing requirements
		if(M.mind && (M.mind.assigned_role in exclusive_roles))
			return TRUE

/datum/round_event_control/antagonist/proc/trim_candidates(list/candidates)
	for(var/mob/living/player in candidates)
		if(player?.mind?.quiet_round) //yogs change, quiet mode
			candidates -= player
			continue

		if(!player?.mind?.assigned_role) //don't antag ghost roles that don't have an assigned role
			candidates -= player
			continue

		if(!(player.mind.assigned_role in GLOB.crew_positions)) //don't antag non crewmembers
			candidates -= player
			continue

	return candidates

/// Check if our enemy_roles requirement is met, if return_players is set then we will return the list of enemy players instead
/datum/round_event_control/proc/check_enemies(return_players = FALSE)
	if(!length(enemy_roles))
		return return_players ? list() : TRUE

	var/job_check = 0
	var/list/enemy_players = list()
	// if(roundstart)
	// 	for(var/enemy in enemy_roles)
	// 		var/datum/job/enemy_job = SSjob.GetJob(enemy)
	// 		if(enemy_job && SSjob.assigned_players_by_job[enemy_job.type])
	// 			job_check += length(SSjob.assigned_players_by_job[enemy_job.type])
	// 			enemy_players += SSjob.assigned_players_by_job[enemy_job.type]

	if (!roundstart)
		for(var/mob/M in SSgamemode.current_players[CURRENT_LIVING_PLAYERS])
			if (M.stat == DEAD)
				continue // Dead players cannot count as opponents
			if (M.mind && (M.mind.assigned_role in enemy_roles))
				job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that
				enemy_players += M

	if(job_check >= required_enemies)
		return return_players ? enemy_players : TRUE
	return return_players ? enemy_players : FALSE

/datum/round_event_control/antagonist/New()
	. = ..()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_roles |= protected_roles

/datum/round_event_control/antagonist/canSpawnEvent(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!check_required())
		return FALSE

	if(!EMERGENCY_IDLE_OR_RECALLED) //no spawning antags if the rounds about to end, don't wanna take antag rep only to give them like 10 minutes at best
		return FALSE

	if(!.)
		return

/datum/round_event_control/antagonist/solo
	typepath = /datum/round_event/antagonist/solo
	/// How many baseline antags do we spawn
	var/base_antags = 1
	/// How many maximum antags can we spawn
	var/maximum_antags = 3
	/// For this many players we'll add 1 up to the maximum antag amount
	var/denominator = 25
	/// The antag flag to be used
	var/antag_flag
	/// The antag datum to be applied
	var/antag_datum
	/// Prompt players for consent to turn them into antags before doing so. Dont allow this for roundstart.
	var/prompted_picking = FALSE
	/// A list of extra events to force whenever this one is chosen by the storyteller.
	/// Can either be normal list or a weighted list.
	var/list/extra_spawned_events

/datum/round_event_control/antagonist/solo/from_ghosts
	prompted_picking = TRUE // We literally HAVE to prompt pick the antag, otherwise it'll pick random ghosts, which we don't want

/datum/round_event_control/antagonist/solo/from_ghosts/get_candidates()
	var/round_started = SSticker.HasRoundStarted()
	var/midround_antag_pref_arg = round_started ? FALSE : TRUE

	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, observers = TRUE, midround_antag_pref = midround_antag_pref_arg, restricted_roles = restricted_roles)
	candidates = trim_candidates(candidates)
	return candidates

/datum/round_event_control/antagonist/solo/canSpawnEvent(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!.)
		return
	var/antag_amt = get_antag_amount()
	var/list/candidates = get_candidates()
	if(length(candidates) < antag_amt)
		return FALSE

/datum/round_event_control/antagonist/solo/proc/get_antag_amount()
	var/people = SSgamemode.get_correct_popcount()
	var/amount = base_antags + FLOOR(people / denominator, 1)
	return min(amount, maximum_antags)

/datum/round_event_control/antagonist/solo/proc/get_candidates()
	var/round_started = SSticker.HasRoundStarted()
	var/new_players_arg = round_started ? FALSE : TRUE
	var/living_players_arg = round_started ? TRUE : FALSE
	var/midround_antag_pref_arg = round_started ? FALSE : TRUE

	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, FALSE, new_players_arg, living_players_arg, midround_antag_pref = midround_antag_pref_arg, restricted_roles = restricted_roles, required_roles = exclusive_roles)
	candidates = trim_candidates(candidates)
	return candidates

/datum/round_event
	var/excute_round_end_reports = FALSE

/datum/round_event/proc/round_end_report()
	return

/datum/round_event/setup()
	. = ..()
	if(excute_round_end_reports)
		SSgamemode.round_end_data |= src

/datum/round_event/antagonist
	fakeable = FALSE
	end_when = 6000 //This is so prompted picking events have time to run //TODO: refactor events so they can be the masters of themselves, instead of relying on some weirdly timed vars

/datum/round_event/antagonist/solo
	// ALL of those variables are internal. Check the control event to change them
	/// The antag flag passed from control
	var/antag_flag
	/// The antag datum passed from control
	var/antag_datum
	/// The antag count passed from control
	var/antag_count
	/// The restricted roles (jobs) passed from control
	var/list/restricted_roles
	/// The minds we've setup in setup() and need to finalize in start()
	var/list/setup_minds = list()
	/// Whether we prompt the players before picking them.
	var/prompted_picking = FALSE //TODO: Implement this
	/// DO NOT SET THIS MANUALLY, THIS IS INHERITED FROM THE EVENT CONTROLLER ON NEW
	var/list/extra_spawned_events

/datum/round_event/antagonist/solo/New(my_processing, datum/round_event_control/event_controller)
	. = ..()
	if(istype(event_controller, /datum/round_event_control/antagonist/solo))
		var/datum/round_event_control/antagonist/solo/antag_event_controller = event_controller
		if(antag_event_controller?.extra_spawned_events)
			extra_spawned_events = fill_with_ones(antag_event_controller.extra_spawned_events)

/datum/round_event/antagonist/solo/setup()
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/possible_candidates = cast_control.get_candidates()
	var/list/candidates = list()
	if(cast_control == SSgamemode.current_roundstart_event && length(SSgamemode.roundstart_antag_minds))
		log_storyteller("Running roundstart antagonist assignment, event: [src], roundstart_antag_minds: [english_list(SSgamemode.roundstart_antag_minds)]")
		for(var/datum/mind/antag_mind in SSgamemode.roundstart_antag_minds)
			if(!antag_mind.current)
				log_storyteller("Roundstart antagonist setup error: antag_mind([antag_mind]) in roundstart_antag_minds without a set mob")
				continue
			candidates += antag_mind.current
			SSgamemode.roundstart_antag_minds -= antag_mind
			log_storyteller("Roundstart antag_mind, [antag_mind]")

	//guh
	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in possible_candidates)
		cliented_list += mob.client

	var/list/weighted_candidates = return_antag_rep_weight(cliented_list)

	while(length(weighted_candidates) && length(candidates) < antag_count) //we pick_n_take from weighted_candidates so this should be fine
		var/client/picked_client = pick_n_take_weighted(weighted_candidates)

		if(!picked_client || QDELETED(picked_client) || !istype(picked_client)) //sanity check
			continue

		var/mob/picked_mob = picked_client.mob
		
		if(!picked_mob || QDELETED(picked_mob) || !istype(picked_mob)) //if the mob has somehow died or disappeared while we were prompting a previous player
			continue

		log_storyteller("[prompted_picking ? "Prompted" : "Picked"] antag event ckey: [picked_mob.ckey], antag: [antag_flag], current special role: [picked_mob.mind?.special_role ? picked_mob.mind.special_role : "none"]")
		if(prompted_picking)
			candidates |= pollCandidates(
				Question = "Would you like to be a [cast_control.name]?",
				jobbanType = antag_flag,
				be_special_flag = antag_flag,
				poll_time = 20 SECONDS,
				group = list(picked_mob)
			)
		else
			candidates |= picked_mob


	for(var/i in 1 to antag_count)
		if(!length(candidates))
			message_admins("A roleset event got fewer antags than its antag_count and may not function correctly.")
			log_storyteller("A roleset event got fewer antags than its antag_count and may not function correctly.")
			break

		var/mob/candidate

		if(GLOB.antag_token_users.len >= 1) //Antag token users get first priority, no matter their preferences
			var/client/C = pick_n_take(GLOB.antag_token_users)
			candidate = C.mob
			if((candidate in candidates) && !is_banned_from(C.ckey, list(antag_flag, ROLE_ANTAG)) && !QDELETED(candidate))
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(antag_token_used), C.ckey, C), 5 MINUTES + 10 SECONDS)
		else
			candidate = pick_n_take(candidates)

		if(!candidate || QDELETED(candidate) || !istype(candidate)) //if the mob has somehow died or disappeared while we were prompting a previous player
			i-- //don't count this as an antag that was picked
			continue

		log_storyteller("Antag event spawned ckey: [candidate.ckey], antag: [antag_flag], current special role: [candidate.mind?.special_role ? candidate.mind.special_role : "none"]")

		if(candidate.client) //I hate this
			SSpersistence.antag_rep -= candidate.client.ckey

		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)

		setup_minds += candidate.mind
		candidate.mind.special_role = antag_flag
		candidate.mind.restricted_roles = restricted_roles

	setup = TRUE
	if(LAZYLEN(extra_spawned_events))
		var/event_type = pick_weight(extra_spawned_events)
		if(!event_type)
			return
		var/datum/round_event_control/triggered_event = locate(event_type) in SSgamemode.control
		addtimer(CALLBACK(triggered_event, TYPE_PROC_REF(/datum/round_event_control, runEvent), FALSE, null, FALSE, "storyteller"), 1 SECONDS) // wait a second to avoid any potential omnitraitor bs

/datum/round_event/antagonist/solo/proc/spawn_extra_events()
	if(!LAZYLEN(extra_spawned_events))
		return
	var/datum/round_event_control/event = pick_weight(extra_spawned_events)
	event?.runEvent(random = FALSE, event_cause = "storyteller")


/datum/round_event/antagonist/solo/ghost/setup()
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()

	//guh
	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in candidates)
		cliented_list += mob.client

	if(prompted_picking)
		candidates = pollCandidates(
				Question = "Would you like to be a [cast_control.name]?",
				jobbanType = antag_flag,
				be_special_flag = antag_flag,
				poll_time = 20 SECONDS,
				group = candidates
				)

	var/list/weighted_candidates = return_antag_rep_weight(candidates)

	for(var/i in 1 to antag_count)
		if(!length(weighted_candidates))
			break

		var/client/mob_client = pick_n_take_weighted(weighted_candidates)
		var/mob/candidate = mob_client.mob

		if(candidate.client) //I hate this
			SSpersistence.antag_rep -= candidate.client.ckey

		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)

		var/mob/living/carbon/human/new_human = makeBody(candidate)
		new_human.mind.special_role = antag_flag
		new_human.mind.restricted_roles = restricted_roles
		setup_minds += new_human.mind
	setup = TRUE


/datum/round_event/antagonist/solo/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		add_datum_to_mind(antag_mind, antag_mind.current)

/datum/round_event/antagonist/solo/proc/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.add_antag_datum(antag_datum)

/datum/round_event/antagonist/solo/ghost/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		add_datum_to_mind(antag_mind)

