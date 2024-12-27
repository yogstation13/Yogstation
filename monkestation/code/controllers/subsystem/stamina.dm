SUBSYSTEM_DEF(stamina)
	name = "Stamina"

	priority = FIRE_PRIORITY_STAMINA
	flags = SS_TICKER | SS_KEEP_TIMING | SS_NO_INIT
	wait = 10 // Not seconds - we're running on SS_TICKER, so this is ticks.

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/stamina/stat_entry(msg)
	msg = "P:[length(processing)]"
	return ..()

/datum/controller/subsystem/stamina/fire(resumed = FALSE)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(length(current_run))
		var/datum/stamina_container/thing = current_run[length(current_run)]
		current_run.len--
		thing.update(world.tick_lag * wait * 0.1)
		if (MC_TICK_CHECK)
			return
