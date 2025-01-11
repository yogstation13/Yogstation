/obj/machinery/bouldertech/crystalizer
	name = "crystalizer"
	desc = "Uses electro-chemical processes to grow relatively pure ore crystals from clean slurry. Sometimes useless amalgams are made."
	icon_state = "crystalizer"
	allows_boulders = FALSE
	holds_minerals = TRUE
	process_string = "Clean Slurry"
	processable_materials = list(
		/datum/material/iron,
		/datum/material/titanium,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/uranium,
		/datum/material/mythril,
		/datum/material/adamantine,
		/datum/material/runite,
		/datum/material/glass,
		/datum/material/plasma,
		/datum/material/diamond,
		/datum/material/bluespace,
		/datum/material/bananium,
		/datum/material/plastic,
	)
	var/maximum_volume = 50
	var/crystalized_reagent = 50
	var/processes_left = 3
	var/crystal_in_progress = FALSE

/obj/machinery/bouldertech/crystalizer/Initialize(mapload)
	. = ..()
	create_reagents(maximum_volume, TRANSPARENT)
	AddComponent(/datum/component/plumbing/material_crystalizer)

/obj/machinery/bouldertech/crystalizer/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "crystalizer-glass", layer + 0.2, src)

	if(crystal_in_progress)
		. += mutable_appearance(icon, "crystalizer-crystal", layer, src)
		. += mutable_appearance(icon, "crystalizer-[processes_left]")

/obj/machinery/bouldertech/crystalizer/examine(mob/user)
	. = ..()
	var/list/possible_pipes = src.GetComponents(/datum/component/plumbing)
	if(length(possible_pipes))
		var/cur_ang_offset = 180 - dir2angle(src.dir) // Parent machine rotation offsets everything else. 180 is default pointed south offset.
		for(var/datum/component/plumbing/pipes in possible_pipes)
			var/input_pipe = initial(pipes.demand_connects) // Call for the initial position then use turn to get its current direction.
			var/layer_name = (pipes.ducting_layer == THIRD_DUCT_LAYER) ? "Third Layer" : GLOB.plumbing_layer_names["[pipes.ducting_layer]"]
			if(istype(pipes, /datum/component/plumbing/material_crystalizer))
				. += span_nicegreen("Clean Slurry supply connects to the [dir2text(turn(input_pipe, cur_ang_offset))] with RED pipes on the [layer_name]")

/obj/machinery/bouldertech/crystalizer/process()
	if(!anchored)
		return
	if(reagents.total_volume < crystalized_reagent)
		crystal_in_progress = FALSE
		return
	crystal_in_progress = TRUE
	if(processes_left > 0)
		processes_left--
		update_appearance()
		return

	processes_left = 3
	process_slurry()
	reagents.remove_all_type(/datum/reagent/processing/clean_slurry, crystalized_reagent)
	crystal_in_progress = FALSE
	update_appearance()


/obj/machinery/bouldertech/crystalizer/proc/process_slurry()
	for(var/datum/reagent/processing/clean_slurry/slurry as anything in reagents.reagent_list)
		if(!istype(slurry))
			continue
		if(!slurry.data["materials"])
			continue
		for(var/item in slurry.data["materials"])
			var/material = item
			var/quantity = slurry.data["materials"][material]
			var/obj/item/processing/crystals/dust = new(get_turf(src))
			dust.custom_materials = list()
			dust.custom_materials += material
			dust.custom_materials[material] = quantity
			dust.set_colors()
			dust.forceMove(get_step(src, export_side))
	if(prob(15))
		var/obj/item/processing/amalgam/trash = new(get_turf(src))
		trash.forceMove(get_step(src, export_side))

	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()

/datum/component/plumbing/material_crystalizer
	demand_connects = WEST

/datum/component/plumbing/material_crystalizer/send_request(dir)
	var/atom/movable/host = parent
	var/reagents_left = host.reagents.maximum_volume - host.reagents.total_volume
	process_request(amount = reagents_left, reagent = /datum/reagent/processing/clean_slurry, dir = dir)

///check who can give us what we want, and how many each of them will give us
/datum/component/plumbing/material_crystalizer/process_request(amount = MACHINE_REAGENT_TRANSFER, reagent, dir)
	//find the duct to take from
	var/datum/ductnet/net
	if(!ducts.Find(num2text(dir)))
		return
	net = ducts[num2text(dir)]

	var/atom/movable/host = parent

	var/datum/reagent/processing/requested_reagent

	for(var/datum/reagent/listed as anything in host.reagents.reagent_list)
		if(!reagent)
			break
		if(reagent == listed.type)
			requested_reagent = listed
			break

	//find all valid suppliers in the duct
	var/list/valid_suppliers = list()
	for(var/datum/component/plumbing/supplier as anything in net.suppliers)
		var/failed = FALSE
		if(requested_reagent)
			var/atom/movable/supplier_host = supplier.parent
			for(var/datum/reagent/supplier_listed as anything in supplier_host.reagents.reagent_list)
				if(supplier_listed.type != reagent)
					continue
				if(supplier_listed.data["materials"] != requested_reagent.data["materials"])
					failed = TRUE
					break
				var/material = supplier_listed.data["materials"]
				var/quantity = supplier_listed.data["materials"][material]
				if(quantity != requested_reagent.data["materials"][material])
					failed = TRUE
					break
		if(failed)
			continue
		if(supplier.can_give(amount, reagent, net))
			valid_suppliers += supplier
	var/suppliersLeft = valid_suppliers.len
	if(!suppliersLeft)
		return

	//take an equal amount from each supplier
	var/currentRequest
	var/target_volume = reagents.total_volume + amount
	for(var/datum/component/plumbing/give as anything in valid_suppliers)
		currentRequest = (target_volume - reagents.total_volume) / suppliersLeft
		give.transfer_to(src, currentRequest, reagent, net)
		suppliersLeft--
