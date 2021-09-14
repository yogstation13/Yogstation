/obj/machinery/computer/ai_resource_distribution
	name = "\improper AI system resource distribution"
	desc = "Used for distributing processing resources across the current artificial intelligences."
	req_access = list(ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_HEADS)
	circuit = /obj/item/circuitboard/computer/aifixer
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	authenticated = FALSE


/obj/machinery/computer/ai_resource_distribution/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiResources", name)
		ui.open()

/obj/machinery/computer/ai_resource_distribution/ui_data(mob/user)
	var/list/data = list()

	data["authenticated"] = authenticated;
	if(!authenticated)
		return data

	data["total_cpu"] = GLOB.ai_os.total_cpu
	data["total_ram"] = GLOB.ai_os.total_ram

	data["assigned_cpu"] = GLOB.ai_os.cpu_assigned
	data["assigned_ram"] = GLOB.ai_os.ram_assigned
	

	data["total_assigned_cpu"] = GLOB.ai_os.total_cpu_assigned()
	data["total_assigned_ram"] = GLOB.ai_os.total_ram_assigned()

	for(var/AI in data["assigned_cpu"])
		data["assigned_cpu"][AI].name = REF(AI)
	for(var/AI in data["assigned_ram"])
		data["assigned_ram"][AI].name = REF(AI)

	data["ais"] = list()

	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		data["ais"] += list(list("name" = A.name, "ref" = REF(A)))

	return data

/obj/machinery/computer/ai_resource_distribution/ui_act(action, params)
	if(..())
		return

	if(!authenticated)
		return

	switch(action)
		if("clear_ai_resources")
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"])
			if(!istype(target_ai))
				return

			GLOB.ai_os.clear_ai_resources(target_ai)
			. = TRUE

		if("add_cpu")
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"])
			if(!istype(target_ai))
				return

			if(GLOB.ai_os.total_cpu_assigned() >= GLOB.ai_os.total_cpu)
				return
			GLOB.ai_os.add_cpu(target_ai, 1)
			. = TRUE

		if("remove_cpu")
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"])
			if(!istype(target_ai))
				return

			var/current_cpu = GLOB.ai_os.cpu_assigned[target_ai]

			if(current_cpu <= 0)
				return
			GLOB.ai_os.remove_cpu(target_ai, 1)
			. = TRUE

		if("add_ram")
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"])
			if(!istype(target_ai))
				return

			if(GLOB.ai_os.total_ram_assigned() >= GLOB.ai_os.total_ram)
				return
			GLOB.ai_os.add_ram(target_ai, 1)
			. = TRUE

		if("remove_ram")
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"])
			if(!istype(target_ai))
				return

			var/current_ram = GLOB.ai_os.ram_assigned[target_ai]

			if(current_ram <= 0)
				return
			GLOB.ai_os.remove_ram(target_ai, 1)
			. = TRUE
		

