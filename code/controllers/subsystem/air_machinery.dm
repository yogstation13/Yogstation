
SUBSYSTEM_DEF(air_machinery)
	name = "Atmospherics Machinery"
	init_order = INIT_ORDER_AIR_MACHINERY
	priority = FIRE_PRIORITY_AIR
	wait = 0.5 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	loading_points = 4.2 SECONDS // Yogs -- loading times

	var/list/obj/machinery/atmos_machinery = list()
	var/list/currentrun = list()

/datum/controller/subsystem/air_machinery/Initialize(timeofday)
	setup_atmos_machinery()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/air_machinery/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.atmos_init()
		CHECK_TICK

/datum/controller/subsystem/air_machinery/proc/start_processing_machine(obj/machinery/machine)
	if(machine.atmos_processing)
		return
	machine.atmos_processing = TRUE
	atmos_machinery += machine

/datum/controller/subsystem/air_machinery/proc/stop_processing_machine(obj/machinery/machine)
	if(!machine.atmos_processing)
		return
	machine.atmos_processing = FALSE
	atmos_machinery -= machine
	currentrun -= machine

/datum/controller/subsystem/air_machinery/fire(resumed = 0)
	if (!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/M = currentrun[currentrun.len]
		currentrun.len--
		if(M == null)
			atmos_machinery.Remove(M)
		if(!M || (M.process_atmos(wait / (1 SECONDS)) == PROCESS_KILL))
			stop_processing_machine(M)
		if(MC_TICK_CHECK)
			return
