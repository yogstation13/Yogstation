#define MAX_HISTORY_TICKS 100

SUBSYSTEM_DEF(lag_compensation)
	name = "Lag Compensation"
	flags = SS_TICKER | SS_BACKGROUND
	wait = 1
	var/list/mob_lagcomp_history = list()
	var/list/restore_history = list()
	var/compensating = FALSE

/datum/controller/subsystem/lag_compensation/Initialize()
	return ..()

/datum/controller/subsystem/lag_compensation/fire(resumed)
	var/current_tick = TICK_TIME
	mob_lagcomp_history[current_tick] = list()
	var/current_tick_list = mob_lagcomp_history[current_tick]
	for (var/mob/M in world)
		current_tick_list[M] = list(M.x, M.y, M.z, M.loc)

	//Clear stale ticks

	for (var/T in mob_lagcomp_history)
		if (T < (current_tick - MAX_HISTORY_TICKS))
			mob_lagcomp_history.Remove(T)

	. = ..()


/datum/controller/subsystem/lag_compensation/proc/set_mob_loc(var/mob/M, var/list/record)
	M.loc = record[4]
	M.x = record[1]
	M.y = record[2]
	M.z = record[3]

//Ping in ms
/datum/controller/subsystem/lag_compensation/proc/begin_lag_compensation(var/ping)
	if (compensating)
		CRASH("Attempted to begin lag compensation while already compensating.")
	compensating = TRUE
	var/ticks = DS2TICKS(ping / 100)
	var/current_tick_list = mob_lagcomp_history[ticks]
	if (isnull(current_tick_list))
		return FALSE
	restore_history = list()
	for (var/mob/M in current_tick_list)
		restore_history[M] = list(M.x, M.y, M.z, M.loc)
		var/list/current_tick = current_tick_list[M]
		set_mob_loc(M, current_tick)
	return TRUE

/datum/controller/subsystem/lag_compensation/proc/end_lag_compensation()
	if (!compensating)
		CRASH("Attempted to end lag compensation without compensating before.")
		
	for (var/mob/M in restore_history)
		set_mob_loc(M, restore_history[M])
	compensating = FALSE
	return TRUE
