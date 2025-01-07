/datum/crewmonitor/proc/get_ntnet_wireless_status(z)
	// NTNet is down and we are not connected via wired connection. No signal.
	if(!find_functional_ntnet_relay())
		return NTNET_NO_SIGNAL

	if(is_station_level(z))
		return NTNET_GOOD_SIGNAL
	else if(is_mining_level(z))
		return NTNET_LOW_SIGNAL
	return NTNET_NO_SIGNAL

/datum/crewmonitor/proc/get_tracking_level(tracked_mob, tracker_z, nt_net, validation=TRUE)
	if(!tracked_mob)
		if (validation)
			stack_trace("Null entry in suit sensors or nanite sensors list.")
		return SENSOR_OFF

	var/mob/living/tracked_living_mob = tracked_mob

	// Check if z-level is correct
	var/turf/pos = get_turf(tracked_living_mob)

	// Is our target in nullspace for some reason?
	if(!pos)
		if (validation)
			stack_trace("Tracked mob has no loc and is likely in nullspace: [tracked_living_mob] ([tracked_living_mob.type])")
		return SENSOR_OFF

	// Machinery and the target should be on the same level or different levels of the same station
	if(pos.z != tracker_z && !(tracker_z in SSmapping.get_connected_levels(pos.z)) && !(nt_net && get_ntnet_wireless_status(pos.z)) && !HAS_TRAIT(tracked_living_mob, TRAIT_MULTIZ_SUIT_SENSORS))
		return SENSOR_OFF

	// Set sensor level based on whether we're in the nanites list or the suit sensor list.
	if(tracked_living_mob in GLOB.nanite_sensors_list)
		return SENSOR_COORDS

	var/mob/living/carbon/human/tracked_human = tracked_living_mob

	// Check their humanity.
	if(!ishuman(tracked_human))
		if (validation)
			stack_trace("Non-human mob is in suit_sensors_list: [tracked_living_mob] ([tracked_living_mob.type])")
		return SENSOR_OFF

	// Check they have a uniform
	var/obj/item/clothing/under/uniform = tracked_human.w_uniform
	if (!istype(uniform))
		if (validation)
			stack_trace("Human without a suit sensors compatible uniform is in suit_sensors_list: [tracked_human] ([tracked_human.type]) ([uniform?.type])")
		return SENSOR_OFF

	// Check if their uniform is in a compatible mode.
	if((uniform.has_sensor <= NO_SENSORS) || !uniform.sensor_mode)
		if (validation)
			stack_trace("Human without active suit sensors is in suit_sensors_list: [tracked_human] ([tracked_human.type]) ([uniform.type])")
		return SENSOR_OFF

	return uniform.sensor_mode
