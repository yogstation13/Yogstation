/datum/ai_dashboard
	var/mob/living/silicon/ai/owner

	var/available_projects

	//What we're currently using, not what we're being granted by the ai data core
	var/cpu_usage
	var/ram_usage 

	var/completed_projects

	var/running_projects

/datum/ai_dashboard/New(mob/living/silicon/ai/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner
	available_projects = list()
	completed_projects = list()
	running_projects = list()
	cpu_usage = list()
	ram_usage = list()

	for(var/path in subtypesof(/datum/ai_project))
		available_projects += new path(owner, src)


/datum/ai_dashboard/proc/is_interactable(mob/user)
	if(user != owner || owner.incapacitated())
		return FALSE
	if(owner.control_disabled)
		to_chat(user, "<span class='warning'>Wireless control is disabled.</span>")
		return FALSE
	return TRUE

/datum/ai_dashboard/ui_status(mob/user)
	if(is_interactable(user))
		return ..()
	return UI_CLOSE

/datum/ai_dashboard/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_dashboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiDashboard")
		ui.open()

/datum/ai_dashboard/ui_data(mob/user)
	if(!owner || user != owner)
		return
	var/list/data = list()

	data["current_cpu"] = GLOB.ai_os.cpu_assigned[owner] ? GLOB.ai_os.cpu_assigned[owner] : 0
	data["current_ram"] = GLOB.ai_os.ram_assigned[owner] ? GLOB.ai_os.ram_assigned[owner] : 0

	var/total_cpu_used = 0
	for(var/I in cpu_usage)
		total_cpu_used += cpu_usage[I]

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	data["used_cpu"] = total_cpu_used
	data["used_ram"] = total_ram_used

	data["max_cpu"] = GLOB.ai_os.total_cpu
	data["max_ram"] = GLOB.ai_os.total_ram

	data["available_projects"] = list()

	var/turf/current_turf = get_turf(owner)

	data["integrity"] = owner.health

	data["location_name"] = get_area(current_turf)

	data["location_coords"] = "[current_turf.x], [current_turf.y], [current_turf.z]"
	var/datum/gas_mixture/env = current_turf.return_air()
	data["temperature"] = env.return_temperature()

	for(var/datum/ai_project/AP as anything in available_projects)
		data["available_projects"] += list(list("name" = AP.name, "description" = AP.description, "ram_required" = AP.ram_required, "available" = AP.available(), "research_cost" = AP.research_cost, "research_progress" = AP.research_progress, 
		"assigned_cpu" = cpu_usage[AP.name] ? cpu_usage[AP.name] : 0, "research_requirements" = AP.research_requirements))


	data["completed_projects"] = list()
	for(var/datum/ai_project/P as anything in completed_projects)
		data["completed_projects"] += list(list("name" = P.name, "description" = P.description, "ram_required" = P.ram_required, "running" = P.running))

	return data

/datum/ai_dashboard/ui_act(action, params)
	if(..())
		return
	if(!is_interactable(usr))
		return

	switch(action)
		if("add_project_cpu")
			if(!add_project_cpu(params["project_name"]))
				to_chat(owner, "<span class='warning'>Unable to add CPU to [params["project_name"]].</span>")
			. = TRUE
		if("remove_project_cpu")
			remove_project_cpu(params["project_name"]) // Can't fail (hopefully), so no failure check
			. = TRUE
		if("run_project")
			if(!run_project(params["project_name"]))
				to_chat(owner, "<span class='warning'>Unable to run the program '[params["project_name"]].'</span>")
			else
				to_chat(owner, "<span class='notice'>Spinning up instance of [params["project_name"]]...</span>")
				. = TRUE
		if("stop_project")
			stop_project(params["project_name"]) // Can't fail (hopefully), so no failure check
			to_chat(owner, "<span class='notice'>Instance of [params["project_name"]] succesfully ended.</span>")
			. = TRUE
			


/datum/ai_dashboard/proc/add_project_cpu(datum/ai_project/project)
	var/current_cpu = GLOB.ai_os.cpu_assigned[owner] ? GLOB.ai_os.cpu_assigned[owner] : 0
	if(!project.canResearch())
		return FALSE

	if(current_cpu > 0)
		cpu_usage[project.name]++
		return TRUE

/datum/ai_dashboard/proc/remove_project_cpu(datum/ai_project/project)
	if(cpu_usage[project.name])
		cpu_usage[project.name]--
	return TRUE


/datum/ai_dashboard/proc/run_project(datum/ai_project/project)
	var/current_ram = GLOB.ai_os.ram_assigned[owner] ? GLOB.ai_os.ram_assigned[owner] : 0

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	if(current_ram - total_ram_used > project.ram_required && project.canRun())
		project.run_project()
		ram_usage[project.name] += project.ram_required
		return TRUE
	return FALSE

/datum/ai_dashboard/proc/stop_project(datum/ai_project/project)
	project.stop()
	if(ram_usage[project.name])
		ram_usage[project.name] -= project.ram_required

	return TRUE

/datum/ai_dashboard/proc/has_completed_projects(project_name)
	for(var/datum/ai_project/P as anything in completed_projects)
		if(P.name == project_name)
			return TRUE
	return FALSE


/datum/ai_dashboard/proc/finish_project(datum/ai_project/project, notify_user = TRUE)
	available_projects -= project
	completed_projects += project
	cpu_usage[project.name] = 0
	if(notify_user)
		to_chat(owner, "<span class='notice'>[project] has been completed. User input required.</span>")
	

//Stuff is handled in here per tick :)
/datum/ai_dashboard/proc/tick(seconds)
	for(var/project_being_researched in cpu_usage)
		if(!cpu_usage[project_being_researched])
			continue
		var/used_cpu = round(cpu_usage[project_being_researched] * seconds, 1)
		var/datum/ai_project/project = locate(project_being_researched) in completed_projects
		if(!project)
			cpu_usage[project_being_researched] = 0
		project.research_progress += used_cpu
		if(project.research_progress > project.research_cost)
			finish_project(project)

