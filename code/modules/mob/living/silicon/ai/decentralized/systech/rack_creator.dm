/obj/machinery/rack_creator
	name = "rack creator"
	desc = "Combines RAM modules and CPUs to create a stand-alone rack for usage in artificial intelligence systems."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "circuit_imprinter"
	layer = BELOW_OBJ_LAYER

	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 1000
	active_power_usage = 5000
	
	var/list/inserted_cpus = list()

	var/list/ram_expansions = list() //List containing numbers corresponding to the amount of RAM that stick adds. 


	//circuit = /obj/item/circuitboard/machine/circuit_imprinter



/obj/machinery/rack_creator/proc/get_total_cost()
	var/list/materials = list()
	materials[/datum/material/iron] = inserted_cpus.len * 2000
	materials[/datum/material/glass] = inserted_cpus.len * 1000
	for(var/RAM in ram_expansions)
		for(var/mat in RAM["cost"])
			if(materials[mat])
				materials[mat] += RAM["cost"][mat]
			else
				materials[mat] = RAM["cost"][mat]
	
	return materials

/obj/machinery/rack_creator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiRackCreator", name)
		ui.open()

/obj/machinery/rack_creator/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["cpus"] = list()
	for(var/obj/item/ai_cpu/CPU in inserted_cpus)
		var/cpu_list = list(list("speed" = CPU.speed, "efficiency" = CPU.get_efficiency(), "power_usage" = CPU.get_power_usage()))
		data["cpus"] += cpu_list

	data["ram"] = list()
	for(var/RAM in ram_expansions)
		var/ram_list = list(list("capacity" = RAM["capacity"], "name" = RAM["name"]))
		data["ram"] += ram_list


	data["possible_ram"] = list()
	for(var/ram_d in subtypesof(/datum/design/ram))
		var/datum/design/ram/D = ram_d
		D = SSresearch.techweb_design_by_id(initial(D.id))
		var/materials_string
		for(var/mat in D.materials)
			var/datum/material/M = mat
			if(!materials_string)
				materials_string += "[M.name]: [D.materials[mat]]"
			else
				materials_string += ", [M.name]: [D.materials[mat]]"
		data["possible_ram"] += list(list("name" = D.name, "capacity" = D.capacity, "cost" = materials_string,"id" = D.id, "unlocked" = SSresearch.science_tech.isDesignResearchedID(D.id) ? TRUE : FALSE))

	data["total_cost"] = get_total_cost()

	return data

/obj/machinery/rack_creator/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("insert_cpu")
			if(inserted_cpus.len >= AI_MAX_CPUS_PER_RACK)
				to_chat(usr, span_warning("This rack cannot fit anymore CPUs!"))
				return
			var/atom/I = usr.get_active_held_item()
			if(!I)
				to_chat(usr, span_warning("You're not currently holding a CPU!"))
				return
			if(!istype(I, /obj/item/ai_cpu))
				to_chat(usr, span_warning("You're not currently holding a CPU!"))
				return
			var/obj/item/ai_cpu/cpu = I
			inserted_cpus += cpu
			. = TRUE
		if("remove_cpu")
			var/index = locate(params["cpu_index"])
			if(!index)
				return
			if(index > inserted_cpus.len || index < 1)
				return
			var/obj/item/ai_cpu/cpu = inserted_cpus[index]
			inserted_cpus -= cpu
			cpu.forceMove(get_turf(src))
			. = TRUE
		if("insert_ram")
			if(ram_expansions.len >= AI_MAX_RAM_PER_RACK)
				to_chat(usr, span_warning("This rack cannot fit anymore RAM expansions!"))
				return
			var/ram_type = locate(params["ram_type"])
			if(!ram_type)
				return
			var/datum/design/ram/D = SSresearch.science_tech.isDesignResearchedID(ram_type)
			if(!D)
				return
			var/list/stats = list("name" = D.name,"capacity" = D.capacity, "cost" = D.materials)
			ram_expansions += stats 

			. = TRUE
		if("finalize")

			. = TRUE

