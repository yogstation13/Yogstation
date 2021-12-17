/datum/department_goal/sec
	account = ACCOUNT_SEC


// Keep the nuclear core of the self-destruct device safe
/datum/department_goal/sec/nukecore
	name = "Protect the nuke"
	desc = "Protect the nuclear core of the station's self-destruct device, by keeping it in the device"
	continuous = 1200 // Check every 2 minutes
	reward = 2000 // Corresponds to 50k in 50mins
	fail_if_failed = TRUE // Set this to false if we ever bother making it so you can stuff the core back into the self-destruct device

/datum/department_goal/sec/nukecore/check_complete()
	for(var/obj/machinery/nuclearbomb/selfdestruct/s in GLOB.nuke_list)
		if(s.core && is_station_level(s.z))
			return TRUE
	return FALSE
