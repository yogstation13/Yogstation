/obj/machinery/bouldertech/enricher
	name = "enrichment chamber"
	desc = "Enriches boulders and dirty dust into dust which can then de smelted at a smelter for double the materials."
	icon_state = "enricher"
	holds_minerals = TRUE
	process_string = "Dirty Dust"
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

/obj/machinery/bouldertech/enricher/process()
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

		if(!istype(potential_boulder, /obj/item/boulder))
			process_dirty_dust(potential_boulder)
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
			export_dust(boulder) //Crack that bouwlder open!
			continue
	if(!stop_processing_check)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
		return PROCESS_KILL

/obj/machinery/bouldertech/enricher/proc/export_dust(obj/item/boulder/boulder)
	for(var/datum/material/material as anything in boulder.custom_materials)
		var/quantity = boulder.custom_materials[material]
		for(var/i = 1 to 2)
			var/obj/item/processing/refined_dust/dust = new(get_turf(src))
			dust.custom_materials = list()
			dust.custom_materials += material
			dust.custom_materials[material] = quantity
			dust.set_colors()
			dust.forceMove(get_step(src, export_side))

	if(istype(boulder, /obj/item/boulder/artifact)) // If we are breaking an artifact boulder drop the artifact before deletion.
		var/obj/item/boulder/artifact/artboulder = boulder
		if(artboulder.artifact_inside)
			artboulder.artifact_inside.forceMove(drop_location())
			artboulder.artifact_inside = null

	qdel(boulder)
	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()

/obj/machinery/bouldertech/enricher/proc/process_dirty_dust(obj/item/processing/dirty_dust/dirty_dust)
	for(var/datum/material/material as anything in dirty_dust.custom_materials)
		var/quantity = dirty_dust.custom_materials[material]
		var/obj/item/processing/refined_dust/dust  = new(get_turf(src))
		dust.custom_materials = list()
		dust.custom_materials += material
		dust.custom_materials[material] = quantity
		dust.set_colors()
		dust.forceMove(get_step(src, export_side))
	qdel(dirty_dust)
	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()

/obj/machinery/bouldertech/enricher/attackby(obj/item/attacking_item, mob/user, params)
	if(holds_minerals && check_extras(attacking_item)) // Checking for extra items it can refine.
		var/obj/item/processing/dirty_dust/dirty_dust = attacking_item
		update_boulder_count()
		if(!accept_boulder(dirty_dust))
			balloon_alert_to_viewers("full!")
			return
		balloon_alert_to_viewers("accepted")
		START_PROCESSING(SSmachines, src)
		return TRUE
	return ..()

/obj/machinery/bouldertech/enricher/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(boulders_contained.len >= boulders_held_max)
		return FALSE
	if(check_extras(mover))
		return TRUE
	return ..()

/obj/machinery/bouldertech/enricher/return_extras()
	var/list/boulders_contained = list()
	for(var/obj/item/processing/dirty_dust/boulder in contents)
		boulders_contained += boulder
	return boulders_contained

/obj/machinery/bouldertech/enricher/check_extras(obj/item/item)
	if(istype(item, /obj/item/processing/dirty_dust))
		return TRUE
	return FALSE
