/datum/antagonist/nukeop/clownop/find_nuke()
	for(var/obj/machinery/nuclearbomb/syndicate/bananium/denton in GLOB.nuke_list)
		if(!denton.centcom)
			return denton

/datum/antagonist/nukeop/leader/clownop/find_nuke() // Whoever made clownops sucks at OOP
	for(var/obj/machinery/nuclearbomb/syndicate/bananium/denton in GLOB.nuke_list)
		if(!denton.centcom)
			return denton