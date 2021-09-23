/datum/ai_dashboard
	var/mob/living/silicon/ai/owner

	var/available_projects

	var/cpu_usage
	var/ram_usage 

	var/completed_upgrades

	var/running_upgrades

/datum/ai_dashboard/New(mob/living/silicon/ai/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner
	available_projects = list()
	completed_upgrades = list()
	running_upgrades = list()
	cpu_usage = list()
	ram_usage = list()

	for(var/path in subtypesof(/datum/ai_project))
		available_projects += new path()

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
	for(var/datum/ai_project/P as anything in completed_upgrades)
		data["completed_projects"] += list(list("name" = P.name, "description" = P.description, "ram_required" = P.ram_required, "running" = P.running))

	return data

/datum/ai_dashboard/ui_act(action, params)
	if(..())
		return
	if(!is_interactable(usr))
		return

	switch(action)
		if("haha")
			return



/datum/ai_dashboard/proc/has_completed_projects(project_name)
	for(var/datum/ai_project/P as anything in completed_upgrades)
		if(P.name == project_name)
			return TRUE
	return FALSE
