#define REQUIRED_OXYGEN_MOLES 25
/obj/machinery/bouldertech/purification_chamber
	name = "purification chamber"
	desc = "Uses a large amount of oxygen to purify ore boulders and shards into ore clumps. The high temperature oxygen rich process burns away impurities."
	icon_state = "purification_chamber"
	holds_minerals = TRUE
	process_string = "Ore Shards, Oxygen"
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

	var/oxygen_moles = 0
	var/obj/machinery/portable_atmospherics/purification_input/oxygen_input

/obj/machinery/bouldertech/purification_chamber/AltClick(mob/user)
	. = ..()
	if(oxygen_input)
		oxygen_input.disconnect()
		QDEL_NULL(oxygen_input)

	var/side = tgui_input_list(user, "Choose a side to try and deploy the tank on", "[name]", list("North", "South"))
	if(!side)
		return

	var/direction = NORTH
	if(side == "South")
		direction = SOUTH

	if(!(locate(/obj/machinery/atmospherics/components/unary/portables_connector) in get_step(src, direction)))
		return

	oxygen_input = new(get_step(src, direction))
	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in oxygen_input.loc
	if(!oxygen_input.connect(possible_port))
		QDEL_NULL(oxygen_input)

/obj/machinery/bouldertech/purification_chamber/process()
	if(!anchored)
		return PROCESS_KILL

	if(oxygen_input)
		oxygen_input.air_contents.assert_gas(/datum/gas/oxygen, oxygen_input.air_contents)
		oxygen_moles = oxygen_input.air_contents.gases[/datum/gas/oxygen][MOLES]

	if(oxygen_moles < REQUIRED_OXYGEN_MOLES)
		return

	var/stop_processing_check = FALSE
	var/boulders_concurrent = boulders_processing_max ///How many boulders can we touch this process() call
	for(var/obj/item/potential_boulder as anything in boulders_contained)
		if(oxygen_input)
			oxygen_input.air_contents.remove_specific(/datum/gas/oxygen, REQUIRED_OXYGEN_MOLES)

		if(QDELETED(potential_boulder))
			boulders_contained -= potential_boulder
			break
		if(boulders_concurrent <= 0)
			break //Try again next time

		if(!istype(potential_boulder, /obj/item/boulder))
			process_shard(potential_boulder)
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
			export_clump(boulder) //Crack that bouwlder open!
			continue
	if(!stop_processing_check)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE)
		return PROCESS_KILL


/obj/machinery/bouldertech/purification_chamber/proc/process_shard(obj/item/processing/shards/shard)
	for(var/datum/material/material as anything in shard.custom_materials)
		var/quantity = shard.custom_materials[material]
		var/obj/item/processing/clumps/dust = new(get_turf(src))
		dust.custom_materials = list()
		dust.custom_materials += material
		dust.custom_materials[material] = quantity
		dust.set_colors()
		dust.forceMove(get_step(src, export_side))

	qdel(shard)
	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()

/obj/machinery/bouldertech/purification_chamber/proc/export_clump(obj/item/boulder/boulder)
	for(var/datum/material/material as anything in boulder.custom_materials)
		var/quantity = boulder.custom_materials[material]
		for(var/i = 1 to 3)
			var/obj/item/processing/clumps/dust = new(get_turf(src))
			dust.custom_materials = list()
			dust.custom_materials += material
			dust.custom_materials[material] = quantity
			dust.set_colors()
			dust.forceMove(get_step(src, export_side))

	if(istype(boulder, /obj/item/boulder/artifact)) // If we are breaking an artifact boulder, drop the artifact before deletion.
		var/obj/item/boulder/artifact/artboulder = boulder
		if(artboulder.artifact_inside)
			artboulder.artifact_inside.forceMove(drop_location())
			artboulder.artifact_inside = null

	qdel(boulder)
	playsound(loc, 'sound/weapons/drill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	update_boulder_count()

/obj/machinery/bouldertech/purification_chamber/attackby(obj/item/attacking_item, mob/user, params)
	if(holds_minerals && check_extras(attacking_item)) // Checking for extra items it can refine.
		var/obj/item/processing/shards/my_dust = attacking_item
		update_boulder_count()
		if(!accept_boulder(my_dust))
			balloon_alert_to_viewers("full!")
			return
		balloon_alert_to_viewers("accepted")
		START_PROCESSING(SSmachines, src)
		return TRUE
	return ..()

/obj/machinery/bouldertech/purification_chamber/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(boulders_contained.len >= boulders_held_max)
		return FALSE
	if(check_extras(mover))
		return TRUE
	return ..()

/obj/machinery/bouldertech/purification_chamber/return_extras()
	var/list/boulders_contained = list()
	for(var/obj/item/processing/shards/boulder in contents)
		boulders_contained += boulder
	return boulders_contained

/obj/machinery/bouldertech/purification_chamber/check_extras(obj/item/item)
	if(istype(item, /obj/item/processing/shards))
		return TRUE
	return FALSE

#undef REQUIRED_OXYGEN_MOLES

/obj/machinery/portable_atmospherics/purification_input
	name = "external purification oxygen tank"
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "air_pump"
	pressure_resistance = 7 * ONE_ATMOSPHERE
	volume = 2000
	density = TRUE
	max_integrity = 300
	integrity_failure = 0.4
	armor_type = /datum/armor/portable_atmospherics_canister


/obj/machinery/portable_atmospherics/purification_input/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)
	AddElement(/datum/element/volatile_gas_storage)
	AddComponent(/datum/component/gas_leaker, leak_rate=0.01)

	SSair.start_processing_machine(src)
