/datum/component/redirect
	dupe_mode = COMPONENT_DUPE_ALLOWED

/datum/component/redirect/Initialize(list/signals, datum/callback/_callback)
	//It's not our job to verify the right signals are registered here, just do it.
	if(!LAZYLEN(signals) || !istype(_callback))
<<<<<<< HEAD
		return COMPONENT_INCOMPATIBLE
=======
		. = COMPONENT_INCOMPATIBLE
		CRASH("A redirection component was initialized with incorrect args.")
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	RegisterSignal(signals, _callback)
