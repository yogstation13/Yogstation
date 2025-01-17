/datum/antagonist/nukeop/proc/find_nuke() // Finds a nuke we can blow up
	for(var/obj/machinery/nuclearbomb/syndicate/denton in GLOB.nuke_list)
		if(!istype(denton,/obj/machinery/nuclearbomb/syndicate/bananium) && !denton.centcom) // OH MY GOD JC A BOMB
			return denton // A BOMB!

/datum/antagonist/nukeop/proc/find_self_destruct() // Finds a station-side self-destruct terminal
	for(var/obj/machinery/nuclearbomb/selfdestruct/selfd in GLOB.nuke_list)
		if(!selfd.centcom && is_station_level(selfd.z))
			return selfd
