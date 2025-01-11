/**
 * Your new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of non-metalic materials.
 * Can be upgraded with stock parts or through chemical inputs.
 * When upgraded, it can hold more boulders and process more at once.
 *
 * Chemical inputs can be used to boost the refinery's efficiency, but produces industrial waste, which eats through the station and is generally difficult to store.
 */

/obj/machinery/bouldertech/refinery
	name = "boulder refinery"
	desc = "BR for short. Accepts boulders and refines non-metallic ores into sheets using internal chemicals. Can be upgraded with stock parts or through chemical inputs."
	icon_state = "stacker"
	holds_minerals = TRUE
	process_string = "Refined Dust"
	processable_materials = list(
		/datum/material/glass,
		/datum/material/plasma,
		/datum/material/diamond,
		/datum/material/bluespace,
		/datum/material/bananium,
		/datum/material/plastic,
	)
	circuit = /obj/item/circuitboard/machine/refinery
	usage_sound = 'sound/machines/mining/refinery.ogg'
	holds_mining_points = TRUE

/// okay so var that holds mining points to claim
/// add total of pts from minerals mined in parent proc
/// then, little mini UI showing points to collect?

/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()
	var/manipulator_stack = 0
	var/matter_bin_stack = 0
	for(var/datum/stock_part/manipulator/servo in component_parts)
		manipulator_stack += servo.tier - 1
	boulders_processing_max = clamp(manipulator_stack, 1, 6)
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		matter_bin_stack += bin.tier
	boulders_held_max = matter_bin_stack


/obj/machinery/bouldertech/refinery/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/boulder) || check_extras(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Insert boulder or refined dust"
	if(istype(held_item, /obj/item/card/id) && points_held > 0)
		context[SCREENTIP_CONTEXT_LMB] = "Claim mining points"
	context[SCREENTIP_CONTEXT_RMB] = "Remove boulder or refined dust"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/bouldertech/refinery/attackby(obj/item/attacking_item, mob/user, params)
	if(holds_minerals && check_extras(attacking_item)) // Checking for extra items it can refine.
		var/obj/item/processing/refined_dust/my_dust = attacking_item
		update_boulder_count()
		if(!accept_boulder(my_dust))
			balloon_alert_to_viewers("full!")
			return
		balloon_alert_to_viewers("accepted")
		START_PROCESSING(SSmachines, src)
		return TRUE
	return ..()

/**
 * Your other new favorite industrial waste magnet!
 * Accepts boulders and produces sheets of metalic materials.
 * Can be upgraded with stock parts or through chemical inputs.
 * When upgraded, it can hold more boulders and process more at once.
 *
 * Chemical inputs can be used to boost the refinery's efficiency, but produces industrial waste, which eats through the station and is generally difficult to store.
 */
/obj/machinery/bouldertech/refinery/smelter
	name = "boulder smelter"
	desc = "BS for short. Accept boulders and refines metallic ores into sheets. Can be upgraded with stock parts or through gas inputs."
	icon_state = "smelter"
	processable_materials = list(
		/datum/material/iron,
		/datum/material/titanium,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/uranium,
		/datum/material/mythril,
		/datum/material/adamantine,
		/datum/material/runite,
	)
	light_system = OVERLAY_LIGHT
	light_outer_range = 1
	light_power = 2
	light_color = "#ffaf55"
	light_on = FALSE
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'

/obj/machinery/bouldertech/refinery/smelter/RefreshParts()
	. = ..()
	light_power = boulders_processing_max

/obj/machinery/bouldertech/refinery/smelter/accept_boulder(obj/item/boulder/new_boulder)
	. = ..()
	if(.)
		set_light_on(TRUE)
		return TRUE

/obj/machinery/bouldertech/refinery/smelter/process()
	. = ..()
	if(. == PROCESS_KILL)
		set_light_on(FALSE)

/obj/machinery/bouldertech/refinery/process()
	if(!anchored)
		return PROCESS_KILL
	var/stop_processing_check = FALSE
	var/boulders_concurrent = boulders_processing_max ///How many boulders can we touch this process() call
	for(var/obj/item/potential_boulder as anything in boulders_contained)
		if(QDELETED(potential_boulder))
			boulders_contained -= potential_boulder
			break
		if(boulders_concurrent <= 0)
			break //Try again next time

		if(!istype(potential_boulder, /obj/item/boulder) && !istype(potential_boulder, /obj/item/processing/refined_dust))
			potential_boulder.forceMove(drop_location())
			CRASH("\The [src] had a non-boulder in it's boulder container!")

		if(istype(potential_boulder, /obj/item/processing/refined_dust))
			boulders_concurrent-- //We count dust.
			refine_dust(potential_boulder)

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
			breakdown_boulder(boulder) //Crack that bouwlder open!
			continue
	if(!stop_processing_check)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
		return PROCESS_KILL

/obj/machinery/bouldertech/refinery/proc/refine_dust(obj/item/processing/refined_dust/dust)
	use_power(BASE_MACHINE_ACTIVE_CONSUMPTION)
	var/list/processable_ores = list()
	for(var/datum/material/possible_mat as anything in dust.custom_materials)
		if(!is_type_in_list(possible_mat, processable_materials))
			continue
		var/quantity = dust.custom_materials[possible_mat]
		points_held = round((points_held + (quantity * possible_mat.points_per_unit * MINING_POINT_MACHINE_MULTIPLIER))) // put point total here into machine
		processable_ores += possible_mat
		processable_ores[possible_mat] = quantity
		dust.custom_materials -= possible_mat //Remove it from the boulder now that it's tracked

	var/obj/item/boulder/disposable_boulder = new (src)
	disposable_boulder.custom_materials = processable_ores
	silo_materials.mat_container.insert_item(disposable_boulder, refining_efficiency)
	if(length(dust.custom_materials)) // If our dust still has materials we cant process eject it.
		dust.restart_processing_cooldown() //Reset the cooldown so we don't pick it back up by the same machine.
		if(isturf(get_step(src, export_side)))
			dust.forceMove(get_step(src, export_side))
		else
			dust.forceMove(drop_location())
	else
		qdel(dust)

	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()

/obj/machinery/bouldertech/refinery/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(boulders_contained.len >= boulders_held_max)
		return FALSE
	if(check_extras(mover))
		var/obj/item/processing/refined_dust/dust = mover
		return dust.can_get_processed()
	return ..()

/obj/machinery/bouldertech/refinery/return_extras()
	var/list/boulders_contained = list()
	for(var/obj/item/processing/refined_dust/boulder in contents)
		boulders_contained += boulder
	return boulders_contained

/obj/machinery/bouldertech/refinery/check_extras(obj/item/item)
	if(istype(item, /obj/item/processing/refined_dust))
		return TRUE
	return FALSE
