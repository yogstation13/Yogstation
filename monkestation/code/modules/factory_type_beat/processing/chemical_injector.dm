/obj/machinery/bouldertech/chemical_injector
	name = "chemical injector"
	desc = "Crushes shards, and boulders when infused with brine. Amalgams will slow down the injector."
	icon_state = "chemical_injection"
	allows_boulders = TRUE
	holds_minerals = TRUE
	process_string = "Brine, Ore Crystals, Ore Amalgams"
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
	var/brine_per_use = 25
	var/crystal_inside = FALSE

/obj/machinery/bouldertech/chemical_injector/update_icon_state()
	. = ..()
	if(crystal_inside)
		icon_state = "chemical_injection-inject"
	else
		icon_state = "chemical_injection"

/obj/machinery/bouldertech/chemical_injector/update_overlays()
	. = ..()
	if(crystal_inside)
		. += mutable_appearance(icon, "chemical_injection-crystal")

/obj/machinery/bouldertech/chemical_injector/attackby(obj/item/attacking_item, mob/user, params)
	if(holds_minerals && check_extras(attacking_item)) // Checking for extra items it can refine.
		var/obj/item/processing/my_dust = attacking_item
		update_boulder_count()
		if(!accept_boulder(my_dust))
			balloon_alert_to_viewers("full!")
			return
		balloon_alert_to_viewers("accepted")
		START_PROCESSING(SSmachines, src)
		return TRUE
	return ..()

/obj/machinery/bouldertech/chemical_injector/Initialize(mapload)
	. = ..()
	create_reagents(maximum_volume, TRANSPARENT)
	AddComponent(/datum/component/plumbing/chemical_injector_brine)

/obj/machinery/bouldertech/chemical_injector/process()
	if(!anchored)
		return PROCESS_KILL

	if(next_allowed_process > world.time)
		return

	if(reagents.total_volume < brine_per_use)
		return

	if(crystal_inside)
		return

	var/stop_processing_check = FALSE
	var/boulders_concurrent = boulders_processing_max ///How many boulders can we touch this process() call
	for(var/obj/item/potential_boulder as anything in boulders_contained)

		if(istype(potential_boulder, /obj/item/processing/amalgam))
			next_allowed_process = world.time + 30 SECONDS
			playsound(src.loc, 'sound/machines/scanbuzz.ogg', 50, FALSE)
			visible_message(span_danger("The machine gets clogged with [potential_boulder]! Disabling it for 30 Seconds."))
			boulders_contained -= potential_boulder
			stop_processing_check = TRUE
			qdel(potential_boulder)
			break //Force the process to skip boulders and ultimately start again. Allows cooldown to take effect.

		if(QDELETED(potential_boulder))
			boulders_contained -= potential_boulder
			break
		if(boulders_concurrent <= 0)
			break //Try again next time

		if(!istype(potential_boulder, /obj/item/boulder))
			crystal_inside = TRUE
			update_appearance()
			addtimer(CALLBACK(src, PROC_REF(process_crystal), potential_boulder), 2.6 SECONDS)
			continue

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
			export_shard(boulder) //Crack that bouwlder open!
			continue
	if(!stop_processing_check)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
		return PROCESS_KILL

/obj/machinery/bouldertech/chemical_injector/examine(mob/user)
	. = ..()
	var/list/possible_pipes = src.GetComponents(/datum/component/plumbing)
	if(length(possible_pipes))
		var/cur_ang_offset = 180 - dir2angle(src.dir) // Parent machine rotation offsets everything else. 180 is default pointed south offset.
		for(var/datum/component/plumbing/pipes in possible_pipes)
			var/input_pipe = initial(pipes.demand_connects) // Call for the initial position then use turn to get its current direction.
			var/layer_name = (pipes.ducting_layer == THIRD_DUCT_LAYER) ? "Third Layer" : GLOB.plumbing_layer_names["[pipes.ducting_layer]"]
			if(istype(pipes, /datum/component/plumbing/chemical_injector_brine))
				. += span_nicegreen("Brine supply connects to the [dir2text(turn(input_pipe, cur_ang_offset))] with YELLOW pipes on the [layer_name]")

/obj/machinery/bouldertech/chemical_injector/proc/process_crystal(obj/item/processing/crystals/clump)
	for(var/datum/material/material as anything in clump.custom_materials)
		var/quantity = clump.custom_materials[material]
		var/obj/item/processing/shards/dust = new(get_turf(src))
		dust.custom_materials = list()
		dust.custom_materials += material
		dust.custom_materials[material] = quantity
		dust.set_colors()
		dust.forceMove(get_step(src, export_side))

	crystal_inside = FALSE
	reagents.remove_all(brine_per_use)
	qdel(clump)
	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()

/obj/machinery/bouldertech/chemical_injector/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(boulders_contained.len >= boulders_held_max)
		return FALSE
	if(istype(mover, /obj/item/processing/crystals))
		return TRUE
	if(istype(mover, /obj/item/processing/amalgam))
		return TRUE
	return ..()

/obj/machinery/bouldertech/chemical_injector/accept_boulder(obj/item/boulder/new_boulder) // Should allow processing amalgams and their cooldown debuff.
	if(isnull(new_boulder))
		return FALSE
	if(boulders_contained.len >= boulders_held_max) //Full already
		return FALSE
	if(!istype(new_boulder) && !check_extras(new_boulder)) //Can't be processed
		return FALSE
	if(!istype(new_boulder, /obj/item/processing/amalgam) && !new_boulder.custom_materials) //Shouldn't happen, but just in case.
		qdel(new_boulder)
		playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return FALSE
	new_boulder.forceMove(src)
	boulders_contained += new_boulder
	SSore_generation.available_boulders -= new_boulder
	START_PROCESSING(SSmachines, src) //Starts processing if we aren't already.
	return TRUE

/obj/machinery/bouldertech/chemical_injector/return_extras()
	var/list/boulders_contained = list()
	for(var/obj/item/processing/crystals/boulder in contents)
		boulders_contained += boulder
	for(var/obj/item/processing/amalgam/amalgam in contents)
		boulders_contained += amalgam
	return boulders_contained

/obj/machinery/bouldertech/chemical_injector/check_extras(obj/item/item)
	if(istype(item, /obj/item/processing/crystals))
		return TRUE
	if(istype(item, /obj/item/processing/amalgam))
		return TRUE
	return FALSE

/obj/machinery/bouldertech/chemical_injector/proc/export_shard(obj/item/boulder/boulder)
	for(var/datum/material/material as anything in boulder.custom_materials)
		var/quantity = boulder.custom_materials[material]
		for(var/i = 1 to 4)
			var/obj/item/processing/shards/dust = new(get_turf(src))
			dust.custom_materials = list()
			dust.custom_materials += material
			dust.custom_materials[material] = quantity
			dust.set_colors()
			dust.forceMove(get_step(src, export_side))

	reagents.remove_all(brine_per_use)
	if(istype(boulder, /obj/item/boulder/artifact)) // If we are breaking an artifact boulder drop the artifact before deletion.
		var/obj/item/boulder/artifact/artboulder = boulder
		if(artboulder.artifact_inside)
			artboulder.artifact_inside.forceMove(drop_location())
			artboulder.artifact_inside = null

	qdel(boulder)
	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()


/datum/component/plumbing/chemical_injector_brine
	demand_connects = SOUTH
	demand_color = COLOR_YELLOW

	ducting_layer = SECOND_DUCT_LAYER

/datum/component/plumbing/chemical_injector_brine/send_request(dir)
	process_request(amount = MACHINE_REAGENT_TRANSFER, reagent = /datum/reagent/brine, dir = dir)
