/obj/machinery/bouldertech/chemical_injector
	name = "chemical injector"
	desc = "Crushes shards when infused with brine."
	icon_state = "chemical_injection"
	allows_boulders = FALSE
	holds_minerals = TRUE
	process_string = "Brine"
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
			visible_message(span_danger("The machine gets clogged with [potential_boulder]! Disabling it for 30 Seconds."))

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
	qdel(boulder)
	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()


/datum/component/plumbing/chemical_injector_brine
	demand_connects = SOUTH
	demand_color = COLOR_YELLOW

	ducting_layer = SECOND_DUCT_LAYER

/datum/component/plumbing/chemical_injector_brine/send_request(dir)
	process_request(amount = MACHINE_REAGENT_TRANSFER, reagent = /datum/reagent/brine, dir = dir)
