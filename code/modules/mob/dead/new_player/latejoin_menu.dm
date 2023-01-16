#define JOB_CHOICE_YES "Yes"
#define JOB_CHOICE_REROLL "Reroll"
#define JOB_CHOICE_CANCEL "Cancel"

GLOBAL_DATUM_INIT(latejoin_menu, /datum/latejoin_menu, new)

/// Makes a list of jobs and pushes them to a DM list selector. Just in case someone did a special kind of fucky-wucky with TGUI.
/datum/latejoin_menu/proc/fallback_ui(mob/dead/new_player/user)
	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjob.occupations)
		jobs += job.title

	var/input_contents = input(user, "Pick a job to join as:", "Latejoin Job Selection") as null|anything in jobs

	if(!input_contents)
		return

	user.AttemptLateSpawn(input_contents)

/datum/latejoin_menu/ui_close(mob/dead/new_player/user)
	. = ..()
	if(istype(user))
		user.jobs_menu_mounted = TRUE // Don't flood a user's chat if they open and close the UI.

/datum/latejoin_menu/ui_interact(mob/dead/new_player/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// In case they reopen the GUI
		// FIXME: this can cause a runtime since user can be a living mob
		if(istype(user))
			user.jobs_menu_mounted = FALSE
			addtimer(CALLBACK(src, PROC_REF(scream_at_player), user), 5 SECONDS)

		ui = new(user, src, "JobSelection", "Latejoin Menu")
		ui.open()

/datum/latejoin_menu/proc/scream_at_player(mob/dead/new_player/player)
	if(!player.jobs_menu_mounted)
		to_chat(player, span_notice("If the late join menu isn't showing, hold CTRL while clicking the join button!"))

/datum/latejoin_menu/ui_data(mob/user)
	var/mob/dead/new_player/owner = user
	var/list/departments = list()
	var/list/data = list(
		"disable_jobs_for_non_observers" = SSticker.late_join_disabled,
		"round_duration" = DisplayTimeText(world.time - SSticker.round_start_time, round_seconds_to = 1),
		"departments" = departments,
	)
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				data["shuttle_status"] = "The station has been evacuated."
			if(SHUTTLE_CALL, SHUTTLE_DOCKED, SHUTTLE_IGNITING, SHUTTLE_ESCAPE)
				if(!SSshuttle.canRecall())
					data["shuttle_status"] = "The station is currently undergoing evacuation procedures."

	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"jobs" = department_jobs,
			"open_slots" = 0,
		)
		departments[department.department_name] = department_data

		for(var/datum/job/job_datum as anything in department.department_jobs)
			var/job_availability = owner.IsJobUnavailable(job_datum.title, latejoin = TRUE)

			var/list/job_data = list(
				"prioritized" = (job_datum in SSjob.prioritized_jobs),
				"used_slots" = job_datum.current_positions,
				"open_slots" = job_datum.total_positions < 0 ? "∞" : job_datum.total_positions,
			)

			if(job_availability != JOB_AVAILABLE)
				job_data["unavailable_reason"] = get_job_unavailable_error_message(job_availability, job_datum.title)

			if(job_datum.total_positions < 0)
				department_data["open_slots"] = "∞"

			if(department_data["open_slots"] != "∞")
				if(job_datum.total_positions - job_datum.current_positions > 0)
					department_data["open_slots"] += job_datum.total_positions - job_datum.current_positions

			department_jobs[job_datum.title] = job_data

	return data

/datum/latejoin_menu/ui_static_data(mob/user)
	var/list/departments = list()

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"jobs" = department_jobs,
			"color" = department.ui_color,
		)
		departments[department.department_name] = department_data

		for(var/datum/job/job_datum as anything in department.department_jobs)
			var/list/job_data = list(
				"command" = !!(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND),
				"description" = job_datum.description,
				"icon" = job_datum.orbit_icon,
			)

			department_jobs[job_datum.title] = job_data

	return list("departments_static" = departments)

// we can't use GLOB.new_player_state here since it also allows any admin to see the ui, which will cause runtimes
/datum/latejoin_menu/ui_status(mob/user)
	return isnewplayer(user) ? UI_INTERACTIVE : UI_CLOSE

/datum/latejoin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(!ui.user.client || !isnewplayer(ui.user))
		return TRUE

	var/mob/dead/new_player/owner = ui.user

	switch(action)
		if("ui_mounted_with_no_bluescreen")
			owner.jobs_menu_mounted = TRUE
		if("select_job")
			if(params["job"] == "Random")
				var/job = get_random_job(owner)
				if(!job)
					tgui_alert(owner, "There is no randomly assignable job at this time. Please manually choose one of the other possible options.")
					return TRUE

				params["job"] = job

			if(!SSticker?.IsRoundInProgress())
				tgui_alert(owner, "The round is either not ready, or has already finished...", "Oh No!")
				return TRUE

			if(!GLOB.enter_allowed || SSticker.late_join_disabled)
				tgui_alert(owner, "There is an administrative lock on entering the game for non-observers!", "Oh No!")
				return TRUE

			//Determines Relevent Population Cap
			var/relevant_cap
			var/hard_popcap = CONFIG_GET(number/hard_popcap)
			var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
			if(hard_popcap && extreme_popcap)
				relevant_cap = min(hard_popcap, extreme_popcap)
			else
				relevant_cap = max(hard_popcap, extreme_popcap)

			if(SSticker.queued_players.len)
				if((living_player_count() >= relevant_cap) || (owner != SSticker.queued_players[1]))
					tgui_alert(owner, "The server is full!", "Oh No!")
					return TRUE

			// SAFETY: AttemptLateSpawn has it's own sanity checks. This is perfectly safe.
			owner.AttemptLateSpawn(params["job"])

			return TRUE

/// Gives the user a random job that they can join as, and prompts them if they'd actually like to keep it, rerolling if not. Cancellable by the user.
/// WARNING: BLOCKS THREAD!
/datum/latejoin_menu/proc/get_random_job(mob/dead/new_player/owner)
	var/attempts = 0
	while(TRUE)
		if (attempts > 10)
			// Give it a few attempts before giving up
			return

		var/datum/job/random_job = SSjob.GetRandomJob(owner)
		if (!random_job)
			return

		if (owner.IsJobUnavailable(random_job.title, latejoin = TRUE) != JOB_AVAILABLE)
			attempts++
			continue

		attempts = 0

		var/list/random_job_options = list(JOB_CHOICE_YES, JOB_CHOICE_REROLL, JOB_CHOICE_CANCEL)
		var/choice = tgui_alert(owner, "Do you want to play as \a [random_job.title]?", "Random Job", random_job_options)

		if(choice == JOB_CHOICE_CANCEL)
			return
		if(choice == JOB_CHOICE_YES)
			return random_job.title

#undef JOB_CHOICE_YES
#undef JOB_CHOICE_REROLL
#undef JOB_CHOICE_CANCEL
