/datum/ai_dashboard
	var/mob/living/silicon/ai/owner

	var/available_projects 

	var/completed_upgrades

	var/running_upgrades

/datum/ai_dashboard/New(mob/living/silicon/ai/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner
	completed_upgrades = list()
	running_upgrades = list()

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

	data["current_cpu"] = GLOB.ai_os.cpu_assigned[owner]
	data["current_ram"] = GLOB.ai_os.ram_assigned[owner]

	data["max_cpu"] = GLOB.ai_os.total_cpu
	data["max_ram"] = GLOB.ai_os.total_ram

	data["available_projects"] = list()

	for(var/datum/ai_project/AP as anything in available_projects)
		data["available_projects"] += list(list("name" = AP.name, "description" = AP.description, "ram_required" = AP.ram_required, "available" = AP.available(), "research_requirements" = AP.research_requirements))


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
		
