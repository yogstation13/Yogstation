SUBSYSTEM_DEF(YogFeatures)
	name = "Yog Features"
	flags = SS_BACKGROUND
	init_order = -101 //last subsystem to initialize, and first to shut down

/datum/controller/subsystem/YogFeatures/Initialize()
	return ..()

/datum.controller/subsystem/YogFeatures/fire(resumed = 0)
	return

