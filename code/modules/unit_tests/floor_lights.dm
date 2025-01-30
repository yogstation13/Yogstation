/// This test ensures that floor lights aren't mapped underneath any sort of solid object that would obscure it.
/datum/unit_test/floor_lights

/datum/unit_test/floor_lights/Run()
	var/static/list/obscuring_typecache = typecacheof(list(
		/obj/structure/table,
		/obj/structure/bookcase,
		/obj/machinery/computer,
		/obj/machinery/vending,
	))

	for(var/obj/machinery/light/floor/light as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light/floor))
		var/turf/light_turf = light.loc
		if(!isturf(light_turf) || !is_station_level(light_turf.z)) // only check lights on-station
			continue
		if(!istype(light, /obj/machinery/light/floor/has_bulb))
			TEST_FAIL("[light] ([light.type]) does not start with a bulb at [AREACOORD(light_turf)], this is likely a mistake")
			continue
		for(var/obj/thing in light_turf)
			if(thing.density && (is_type_in_typecache(thing, obscuring_typecache) || ((thing.flags_1 & PREVENT_CLICK_UNDER_1) && thing.layer > light.layer)))
				TEST_FAIL("[light] ([light.type]) obscured by [thing] ([thing.type]) at [AREACOORD(light_turf)]")
