/datum/department_goal/sec
	account = ACCOUNT_SEC


// Keep the nuclear core of the self-destruct device safe
/datum/department_goal/sec/nukecore
	name = "Protect the nuke"
	desc = "Protect the nuclear core of the station's self-destruct device, by keeping it there"
	continuous = 1200 // Check every 2 minutes
	reward = 2000 // Corresponds to 50k in 50mins

/datum/department_goal/sec/nukecore/check_complete()
	for(var/obj/machinery/nuclearbomb/selfdestruct/s in GLOB.nuke_list)
		if(s.core && is_station_level(s.z))
			return TRUE
	// Fail it if it's not there
	completed = TRUE
	return FALSE
