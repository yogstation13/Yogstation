SUBSYSTEM_DEF(maintrooms)
	name = "maintrooms"
	init_order = INIT_ORDER_MAINTROOMS
	flags = SS_NO_FIRE

/datum/controller/subsystem/maintrooms/Initialize(timeofday)
#ifdef LOWMEMORYMODE
	return SS_INIT_NO_NEED
#endif
#ifdef UNIT_TESTS // This whole subsystem just introduces a lot of odd confounding variables into unit test situations, so let's just not bother with doing an initialize here.
	return SS_INIT_NO_NEED
#endif

	generate_maintrooms()
	return SS_INIT_SUCCESS


/datum/controller/subsystem/maintrooms/proc/generate_maintrooms()
	var/list/errorList = list()
	SSmapping.LoadGroup(errorList, "Maintrooms", "map_files/generic", "MaintStation.dmm", default_traits = ZTRAITS_BACKROOM_MAINTS, silent = TRUE)
	if(errorList.len)	// maintrooms failed to load
		message_admins("Maintrooms failed to load!")
		log_game("Maintrooms failed to load!")

	for(var/area/A as anything in GLOB.areas)
		if(istype(A, /area/procedurally_generated/maintenance/the_backrooms))
			A.RunGeneration()
