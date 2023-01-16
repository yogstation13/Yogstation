/datum/preference_middleware/jobs
	action_delegations = list(
		"set_job_preference" = .proc/set_job_preference,
	)

/datum/preference_middleware/jobs/proc/set_job_preference(list/params, mob/user)
	var/job_title = params["job"]
	var/level = params["level"]

	if (level != null && level != JP_LOW && level != JP_MEDIUM && level != JP_HIGH)
		return FALSE

	var/datum/job/job = SSjob.GetJob(job_title)

	if (isnull(job))
		return FALSE

	//if (job.faction != FACTION_STATION)
	//	return FALSE

	if (!preferences.set_job_preference_level(job, level))
		return FALSE

	preferences.character_preview_view?.update_body()

	return TRUE

/datum/preference_middleware/jobs/get_constant_data()
	var/list/data = list()

	var/list/departments = list()
	var/list/jobs = list()

	var/static/list/categories = list()
	categories += list(GLOB.original_engineering_positions)
	categories += list(GLOB.original_supply_positions - "Head of Personnel")
	categories += list(GLOB.original_nonhuman_positions)
	categories += list(GLOB.original_civilian_positions - "Assistant" + "Head of Personnel")
	categories += list(GLOB.original_science_positions)
	categories += list(GLOB.original_security_positions)
	categories += list(GLOB.original_medical_positions)

	// TODO: Port proper department datums and update this shitfest
	for(var/list/category in categories)
		for(var/debug as anything in category)
			WARNING(debug)
		var/department_name = SSjob.name_occupations_all[category[1]].exp_type_department
		var/head_name

		for(var/job_name as anything in category)
			var/datum/job/job = SSjob.name_occupations[job_name]
			if (!job)
				continue

			if (isnull(job.description))
				stack_trace("[job] does not have a description set, yet is a joinable occupation!")
				continue

			if (job_name in GLOB.command_positions)
				head_name = job_name

			if (isnull(jobs[job_name]))
				jobs[job_name] = list(
					"description" = job.description,
					"department" = department_name,
				)

		departments[department_name] = list(
			"head" = head_name,
		)

	// Special department data needed for the UI to work properly
	departments["Silicon"] = list(
		"head" = "AI",
	)

	departments["Supply"] = list(
		"head" = "Quartermaster",
	)

	var/datum/job/captain_job = SSjob.name_occupations["Captain"]
	jobs["Captain"] = list(
		"description" = captain_job.description,
		"department" = "Captain",
	)
	departments["Captain"] = list(
		"head" = "Captain",
	)

	var/datum/job/assistant_job = SSjob.name_occupations["Assistant"]
	jobs["Assistant"] = list(
		"description" = assistant_job.description,
		"department" = "Assistant",
	)
	departments["Assistant"] = list(
		"head" = null,
	)

	data["departments"] = departments
	data["jobs"] = jobs

	return data

/datum/preference_middleware/jobs/get_ui_data(mob/user)
	var/list/data = list()

	data["job_preferences"] = preferences.job_preferences

	return data

/datum/preference_middleware/jobs/get_ui_static_data(mob/user)
	var/list/data = list()

	var/list/required_job_playtime = get_required_job_playtime(user)
	if (!isnull(required_job_playtime))
		data += required_job_playtime

	var/list/job_bans = get_job_bans(user)
	if (job_bans.len)
		data["job_bans"] = job_bans

	return data.len > 0 ? data : null

/datum/preference_middleware/jobs/proc/get_required_job_playtime(mob/user)
	var/list/data = list()

	var/list/job_days_left = list()
	var/list/job_required_experience = list()

	for (var/datum/job/job as anything in SSjob.occupations)
		var/required_playtime_remaining = job.required_playtime_remaining(user.client)
		if (required_playtime_remaining)
			job_required_experience[job.title] = list(
				"experience_type" = job.get_exp_req_type(),
				"required_playtime" = required_playtime_remaining,
			)

			continue

		if (!job.player_old_enough(user.client))
			job_days_left[job.title] = job.available_in_days(user.client)

	if (job_days_left.len)
		data["job_days_left"] = job_days_left

	if (job_required_experience)
		data["job_required_experience"] = job_required_experience

	return data

/datum/preference_middleware/jobs/proc/get_job_bans(mob/user)
	var/list/data = list()

	for (var/datum/job/job as anything in SSjob.occupations)
		if (is_banned_from(user.client?.ckey, job.title))
			data += job.title

	return data
