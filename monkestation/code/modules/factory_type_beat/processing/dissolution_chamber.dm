/obj/machinery/bouldertech/dissolution_chamber
	name = "dissolution chamber"
	desc = "Breaks down boulders into a dirty slurry using sulfuric acid."
	icon_state = "dissolution"
	holds_minerals = TRUE
	process_string = "Sulfuric Acid"
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
	var/maximum_volume = 3000
	var/acid_per_use = 100

/obj/machinery/bouldertech/dissolution_chamber/Initialize(mapload)
	. = ..()
	create_reagents(maximum_volume, TRANSPARENT)
	AddComponent(/datum/component/plumbing/dissolution_chamber)
	AddComponent(/datum/component/plumbing/dissolution_chamber_output)

/obj/machinery/bouldertech/dissolution_chamber/process()
	if(!anchored)
		return PROCESS_KILL


	if(reagents.total_volume < acid_per_use)
		return

	var/stop_processing_check = FALSE
	var/boulders_concurrent = boulders_processing_max ///How many boulders can we touch this process() call
	for(var/obj/item/potential_boulder as anything in boulders_contained)
		if(QDELETED(potential_boulder))
			boulders_contained -= potential_boulder
			break
		if(boulders_concurrent <= 0)
			break //Try again next time

		var/obj/item/boulder/boulder = potential_boulder
		if(boulder.durability < 0)
			CRASH("\The [src] had a boulder with negative durability!")
		if(!check_for_processable_materials(boulder.custom_materials)) //Checks for any new materials we can process.
			boulders_concurrent-- //We count skipped boulders
			remove_boulder(boulder)
			continue
		boulders_concurrent--
		boulder.durability-- //One less durability to the processed boulder.
		if(COOLDOWN_FINISHED(src, sound_cooldown))
			COOLDOWN_START(src, sound_cooldown, 1.5 SECONDS)
			playsound(loc, usage_sound, 29, FALSE, SHORT_RANGE_SOUND_EXTRARANGE) //This can get annoying. One play per process() call.
		stop_processing_check = TRUE
		if(boulder.durability <= 0)
			export_slurry(boulder) //Crack that bouwlder open!
			reagents.remove_all_type(/datum/reagent/toxin/acid, acid_per_use)
			continue
	if(!stop_processing_check)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
		return PROCESS_KILL

/obj/machinery/bouldertech/dissolution_chamber/proc/export_slurry(obj/item/boulder/boulder)
	for(var/datum/material/material as anything in boulder.custom_materials)
		var/list/data = list()
		data |= material
		data[material] = boulder.custom_materials[material]
		var/list/material_data = list()
		material_data += "materials"
		material_data["materials"] = data
		reagents.add_reagent(/datum/reagent/processing/dirty_slurry, 250, material_data)

	if(istype(boulder, /obj/item/boulder/artifact)) // If we are breaking an artifact boulder drop the artifact before deletion.
		var/obj/item/boulder/artifact/artboulder = boulder
		if(artboulder.artifact_inside)
			artboulder.artifact_inside.forceMove(drop_location())
			artboulder.artifact_inside = null

	qdel(boulder)
	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()

/obj/machinery/bouldertech/dissolution_chamber/examine(mob/user)
	. = ..()
	var/list/possible_pipes = src.GetComponents(/datum/component/plumbing)
	if(length(possible_pipes))
		var/cur_ang_offset = 180 - dir2angle(src.dir) // Parent machine rotation offsets everything else. 180 is default pointed south offset.
		for(var/datum/component/plumbing/pipes in possible_pipes)
			var/input_pipe = initial(pipes.demand_connects) // Call for the initial position then use turn to get its current direction.
			var/output_pipe = initial(pipes.supply_connects)
			var/layer_name = (pipes.ducting_layer == THIRD_DUCT_LAYER) ? "Third Layer" : GLOB.plumbing_layer_names["[pipes.ducting_layer]"]
			if(istype(pipes, /datum/component/plumbing/dissolution_chamber))
				. += span_nicegreen("Sulfuric Acid supply connects to the [dir2text(turn(input_pipe, cur_ang_offset))] with YELLOW pipes on the [layer_name]")
			if(istype(pipes, /datum/component/plumbing/dissolution_chamber_output))
				. += span_nicegreen("Dirty Slurry export connects to the [dir2text(turn(output_pipe, cur_ang_offset))] with BLUE pipes on the [layer_name]")

/datum/component/plumbing/dissolution_chamber
	demand_connects = SOUTH
	demand_color = COLOR_YELLOW

	ducting_layer = SECOND_DUCT_LAYER

/datum/component/plumbing/dissolution_chamber/send_request(dir)
	var/atom/movable/host = parent
	var/reagents_left = host.reagents.get_reagent_amount(/datum/reagent/toxin/acid)
	process_request(amount = max(2500 - reagents_left, 0), reagent = /datum/reagent/toxin/acid, dir = dir)

/datum/component/plumbing/dissolution_chamber_output
	supply_connects = EAST
