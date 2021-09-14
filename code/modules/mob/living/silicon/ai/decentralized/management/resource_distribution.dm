/obj/machinery/computer/ai_resource_distribution
	name = "\improper AI system resource distribution"
	desc = "Used for distributing processing resources across the current artificial intelligences."
	req_access = list(ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_HEADS)
	circuit = /obj/item/circuitboard/computer/aifixer
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK



/obj/machinery/computer/ai_resource_distribution/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiResources", name)
		ui.open()

/obj/machinery/computer/ai_resource_distribution/ui_data(mob/user)
	var/list/data = list()

	data["total_cpu"] = GLOB.ai_os.total_cpu
	data["total_ram"] = GLOB.ai_os.total_ram

	var/total_assigned_ram = 0
	for(var/A in GLOB.ai_os.ram_assigned)
		total_assigned_ram += GLOB.ai_os.ram_assigned[A]

	var/total_assigned_cpu = 0
	for(var/A in GLOB.ai_os.cpu_assigned)
		total_assigned_cpu += GLOB.ai_os.cpu_assigned[A]

	data["assigned_ram"] = GLOB.ai_os.ram_assigned
	data["assigned_cpu"] = GLOB.ai_os.cpu_assigned
	data["total_assigned_cpu"] = total_assigned_cpu
	data["total_assigned_ram"] = total_assigned_ram

	data["ais"] = list()

	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		data["ais"] += list("name" = A.name, "ref" = REF(A))

	return data

/obj/machinery/computer/ai_resource_distribution/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("add_cpu")
			var/target_ai = params["targetAI"]
			message_admins(target_ai)
			message_admins(GLOB.ai_os.cpu_assigned[locate(target_ai)].type)


		if("remove_cpu")

		if("add_ram")

		if("remove_ram")
		

