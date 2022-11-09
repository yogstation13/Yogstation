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

	circuit = /obj/item/circuitboard/machine/rack_creator

	var/datum/component/remote_materials/rmat
	var/efficiency_coeff = 1


/obj/machinery/rack_creator/Initialize(mapload)
	rmat = AddComponent(/datum/component/remote_materials, "rackcreator", mapload)
	rmat.set_local_size(200000)
	RefreshParts()
	return ..()


/obj/machinery/rack_creator/RefreshParts()
	calculate_efficiency()

/obj/machinery/rack_creator/proc/calculate_efficiency()
	efficiency_coeff = 1
	var/total_rating = 1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating = clamp(total_rating - (M.rating * 0.1), 0, 1)
	if(total_rating == 0)
		efficiency_coeff = INFINITY
	else
		efficiency_coeff = 1/total_rating


/obj/machinery/rack_creator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiRackCreator", name)
		ui.open()

/obj/machinery/rack_creator/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["materials"] = output_available_resources()
	data["can_print"] = check_resources()

	data["cpus"] = list()
	data["total_cpu"] = 0
	data["power_usage"] = 0
	var/power_usage_unweighted = list()
	for(var/obj/item/ai_cpu/CPU in inserted_cpus)
		var/cpu_power_usage = CPU.get_power_usage()
		var/cpu_efficiency = CPU.get_efficiency()
		var/cpu_list = list(list("speed" = CPU.speed, "efficiency" = cpu_efficiency, "power_usage" = cpu_power_usage))
		data["cpus"] += cpu_list
		data["total_cpu"] += CPU.speed
		data["power_usage"] += cpu_power_usage
		power_usage_unweighted += list(list("usage" = cpu_power_usage, "efficiency" = cpu_efficiency))

	var/total_efficiency = 1
	if(data["power_usage"])
		total_efficiency = 0
		for(var/usage in power_usage_unweighted)
			var/weight = usage["usage"] / data["power_usage"]
			total_efficiency += (usage["efficiency"] / 100) * weight

	data["efficiency"] = total_efficiency

	data["ram"] = list()
	data["total_ram"] = 0
	for(var/RAM in ram_expansions)
		var/materials_string
		for(var/mat in RAM["cost"])
			var/datum/material/M = mat
			if(!materials_string)
				materials_string += "[M.name]: [RAM["cost"][mat] / efficiency_coeff]"
			else
				materials_string += ", [M.name]: [RAM["cost"][mat] / efficiency_coeff]"

		var/ram_list = list(list("capacity" = RAM["capacity"], "name" = RAM["name"], "cost" = materials_string))
		data["ram"] += ram_list
		data["total_ram"] += RAM["capacity"]
		

	data["power_usage"] += ram_expansions.len * AI_RAM_POWER_USAGE

	data["possible_ram"] = list()
	for(var/ram_d in subtypesof(/datum/design/ram))
		var/datum/design/ram/D = ram_d
		D = SSresearch.techweb_design_by_id(initial(D.id))
		var/materials_string
		for(var/mat in D.materials)
			var/datum/material/M = mat
			if(!materials_string)
				materials_string += "[M.name]: [D.materials[mat] / efficiency_coeff]"
			else
				materials_string += ", [M.name]: [D.materials[mat] / efficiency_coeff]"
		data["possible_ram"] += list(list("name" = D.name, "capacity" = D.capacity, "cost" = materials_string,"id" = D.id, "unlocked" = SSresearch.science_tech.isDesignResearchedID(D.id) ? TRUE : FALSE))

	data["unlocked_ram"] = 1
	data["unlocked_cpu"] = 1
	for(var/i in 2 to 4)
		if(slotUnlockedRAM(i))
			data["unlocked_ram"] = i
		if(slotUnlockedCPU(i))
			data["unlocked_cpu"] = i


	return data

/obj/machinery/rack_creator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials)
	)

/obj/machinery/rack_creator/proc/check_resources()
	var/list/total_cost = list()
	for(var/RAM in ram_expansions)
		for(var/mat in RAM["cost"])
			var/datum/material/M = mat
			total_cost[M] += RAM["cost"][M] / efficiency_coeff

	if(!total_cost.len)
		return -1

	var/datum/component/material_container/materials = rmat.mat_container
	
	if(materials.has_materials(total_cost))
		return total_cost
	return FALSE	



/obj/machinery/rack_creator/proc/output_available_resources()
	var/datum/component/material_container/materials = rmat.mat_container

	var/list/material_data = list()

	if(materials)
		for(var/mat_id in materials.materials)
			var/datum/material/M = mat_id
			var/list/material_info = list()
			var/amount = materials.materials[mat_id]

			material_info = list(
				"name" = M.name,
				"ref" = REF(M),
				"amount" = amount,
				"sheets" = round(amount / MINERAL_MATERIAL_AMOUNT),
				"removable" = amount >= MINERAL_MATERIAL_AMOUNT
			)

			material_data += list(material_info)

		return material_data

	return null


/obj/machinery/rack_creator/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ai_cpu))
		var/obj/item/ai_cpu/CPU = I
		if(inserted_cpus.len >= AI_MAX_CPUS_PER_RACK)
			to_chat(user, span_warning("This rack cannot fit anymore CPUs!"))
			return ..()
		if(slotUnlockedCPU(inserted_cpus.len + 1))
			inserted_cpus += CPU
			CPU.forceMove(src)
			return FALSE
		else
			to_chat(user, span_warning("This socket has not been researched!"))
			return ..()
		
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), I))
		return
	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/rack_creator/proc/slotUnlockedCPU(slot_number)
	switch(slot_number)
		if(1)
			. = TRUE
		if(2)
			. = SSresearch.science_tech.isNodeResearchedID("ai_cpu_2")
		if(3)
			. = SSresearch.science_tech.isNodeResearchedID("ai_cpu_3")

		if(4)
			. = SSresearch.science_tech.isNodeResearchedID("ai_cpu_4")

/obj/machinery/rack_creator/proc/slotUnlockedRAM(slot_number)
	switch(slot_number)
		if(1)
			. = TRUE
		if(2)
			. = SSresearch.science_tech.isNodeResearchedID("ai_ram_2")
		if(3)
			. = SSresearch.science_tech.isNodeResearchedID("ai_ram_3")
		if(4)
			. = SSresearch.science_tech.isNodeResearchedID("ai_ram_4")


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
			if(slotUnlockedCPU(inserted_cpus.len + 1))
				inserted_cpus += cpu
				cpu.forceMove(src)
			else
				to_chat(usr, span_warning("This socket has not been researched!"))
				return
			. = TRUE
		if("remove_cpu")
			var/index = params["cpu_index"]
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
			var/ram_type = params["ram_type"]
			if(!ram_type)
				return
			var/datum/design/ram/D = SSresearch.science_tech.isDesignResearchedID(ram_type)
			if(!D)
				return
			if(slotUnlockedRAM(ram_expansions.len + 1))
				var/list/stats = list(list("name" = D.name,"capacity" = D.capacity, "cost" = D.materials))
				ram_expansions += stats 
			else
				to_chat(usr, span_warning("This socket has not been researched!"))
				return

			. = TRUE
		if("remove_ram")
			var/index = params["ram_index"]
			if(!index)
				return
			if(index > ram_expansions.len || index < 1)
				return
			ram_expansions.Cut(index, index + 1)
			. = TRUE

		if("finalize")
			if(!ram_expansions.len && !inserted_cpus.len)
				say("No RAM nor CPUs inserted. Process aborted.")
				return
			var/datum/component/material_container/materials = rmat.mat_container
			if (!materials)
				say("No access to material storage, please contact the quartermaster.")
				return FALSE
			if (rmat.on_hold())
				say("Mineral access is on hold, please contact the quartermaster.")
				return FALSE
			var/total_cost = check_resources()
			if(!total_cost)
				say("Not enough resources to finalize.")
				return FALSE
			if(islist(total_cost))
				materials.use_materials(total_cost)
				rmat.silo_log(src, "built", -1, "server rack", total_cost)

			var/obj/item/server_rack/new_rack = new(src)
			for(var/obj/item/ai_cpu/CPU in inserted_cpus)
				CPU.forceMove(new_rack)
				new_rack.contained_cpus += CPU
			inserted_cpus = list()
			

			var/total_ram = 0
			for(var/RAM in ram_expansions)
				for(var/mat in RAM["cost"])
					new_rack.materials[mat] += RAM["cost"][mat]

				total_ram += RAM["capacity"]

			
			new_rack.contained_ram = total_ram
			ram_expansions = list()

			flick("circuit_imprinter_ani", src)
			addtimer(CALLBACK(src, .proc/finalize_post, new_rack), 1.5 SECONDS)
			. = TRUE

/obj/machinery/rack_creator/proc/finalize_post(obj/item/server_rack/rack)
	if(!rack)
		return
	rack.forceMove(get_turf(src))
