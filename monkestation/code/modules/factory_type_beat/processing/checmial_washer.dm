/obj/machinery/bouldertech/chemical_washer
	name = "chemical washer"
	desc = "Uses water to flush out non-dissolvable materials leaving a clean slurry solution."
	icon_state = "washer"
	allows_boulders = FALSE
	holds_minerals = TRUE
	process_string = "Water, Dirty Slurry"
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
	var/maximum_volume = 1000
	var/water_per_use = 100

/obj/machinery/bouldertech/chemical_washer/Initialize(mapload)
	. = ..()
	create_reagents(maximum_volume, TRANSPARENT)
	AddComponent(/datum/component/plumbing/chemical_washer)
	AddComponent(/datum/component/plumbing/chemical_washer_water)

/obj/machinery/bouldertech/chemical_washer/examine(mob/user)
	. = ..()
	var/list/possible_pipes = src.GetComponents(/datum/component/plumbing)
	if(length(possible_pipes))
		var/cur_ang_offset = 180 - dir2angle(src.dir) // Parent machine rotation offsets everything else. 180 is default pointed south offset.
		for(var/datum/component/plumbing/pipes in possible_pipes)
			var/input_pipe = initial(pipes.demand_connects) // Call for the initial position then use turn to get its current direction.
			var/output_pipe = initial(pipes.supply_connects)
			var/layer_name = (pipes.ducting_layer == THIRD_DUCT_LAYER) ? "Third Layer" : GLOB.plumbing_layer_names["[pipes.ducting_layer]"]
			if(istype(pipes, /datum/component/plumbing/chemical_washer))
				. += span_nicegreen("Dirty Slurry supply connects to the [dir2text(turn(input_pipe, cur_ang_offset))] with RED pipes on the [layer_name]")
				. += span_nicegreen("Clean Slurry export connects to the [dir2text(turn(output_pipe, cur_ang_offset))] with BLUE pipes on the [layer_name]")
			if(istype(pipes, /datum/component/plumbing/chemical_washer_water))
				. += span_nicegreen("Water supply connects to the [dir2text(turn(input_pipe, cur_ang_offset))] with BLUE pipes on the [layer_name]")

/obj/machinery/bouldertech/chemical_washer/process()
	if(!anchored)
		return
	if(reagents.total_volume < water_per_use)
		return
	process_slurry()


/obj/machinery/bouldertech/chemical_washer/proc/process_slurry()
	var/processed = FALSE
	for(var/datum/reagent/processing/dirty_slurry/slurry as anything in reagents.reagent_list)
		if(!istype(slurry))
			continue

		if(!slurry.data["materials"])
			continue
		var/list/slurry_data = slurry.data
		var/slurry_volume = slurry.volume

		reagents.remove_all_type(slurry.type, slurry.volume)
		reagents.add_reagent(/datum/reagent/processing/clean_slurry, slurry_volume, slurry_data)
		processed = TRUE


	if(processed)
		reagents.remove_all_type(/datum/reagent/water, water_per_use)

		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		update_boulder_count()

/datum/component/plumbing/chemical_washer
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/chemical_washer/send_request(dir)
	var/atom/movable/host = parent

	var/slurry_amount = host.reagents.get_reagent_amount(/datum/reagent/processing/dirty_slurry)
	process_request(amount = max(500 - slurry_amount, 0), reagent = /datum/reagent/processing/dirty_slurry, dir = dir)

///check who can give us what we want, and how many each of them will give us
/datum/component/plumbing/chemical_washer/process_request(amount = MACHINE_REAGENT_TRANSFER, reagent, dir)
	//find the duct to take from
	var/datum/ductnet/net
	if(!ducts.Find(num2text(dir)))
		return
	net = ducts[num2text(dir)]

	var/atom/movable/host = parent

	var/datum/reagent/processing/requested_reagent

	for(var/datum/reagent/listed as anything in host.reagents.reagent_list)
		if(istype(reagent, /datum/reagent/processing/clean_slurry))
			return

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

/datum/component/plumbing/chemical_washer_water
	demand_connects = SOUTH
	demand_color = COLOR_BLUE

	ducting_layer = SECOND_DUCT_LAYER

/datum/component/plumbing/chemical_washer_water/send_request(dir)
	var/atom/movable/host = parent
	var/water_amount = host.reagents.get_reagent_amount(/datum/reagent/water)
	process_request(amount = max(500 - water_amount, 0), reagent = /datum/reagent/water, dir = dir)
