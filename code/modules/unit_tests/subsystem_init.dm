/datum/unit_test/subsystem_init/Run()
	for(var/datum/controller/subsystem/master_subsystem as anything in Master.subsystems)
		if(master_subsystem.flags & SS_NO_INIT)
			continue
		if(!master_subsystem.initialized)
			TEST_FAIL("[master_subsystem]([master_subsystem.type]) is a subsystem meant to initialize but doesn't get set as initialized.")
