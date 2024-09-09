/proc/count_lists()
#ifndef OPENDREAM
	var/list_count = 0
	for(var/list/list)
		list_count++

	var/file = file("data/list_count/[GLOB.round_id].txt")

	WRITE_FILE(file, list_count)
#endif

/proc/save_types()
#ifndef OPENDREAM
	var/datum/D
	var/atom/A
	var/list/counts = new
	for(A) counts[A.type] = (counts[A.type]||0) + 1
	for(D) counts[D.type] = (counts[D.type]||0) + 1

	var/F = file("data/type_tracker/[GLOB.round_id]-stat_track.txt")
	for(var/i in counts)
		WRITE_FILE(F, "[i]\t[counts[i]]\n")
#endif

/proc/save_datums()
#ifndef OPENDREAM
	var/datum/D
	var/list/counts = new
	for(D) counts[D.type] = (counts[D.type]||0) + 1

	var/F = file("data/type_tracker/[GLOB.round_id]-datums-[world.time].txt")
	for(var/i in counts)
		WRITE_FILE(F, "[i]\t[counts[i]]\n")
#endif

///these procs don't work on od
SUBSYSTEM_DEF(memory_stats)
	name = "Mem Stats"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 5 MINUTES
	flags = SS_NO_INIT | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

/datum/controller/subsystem/memory_stats/fire(resumed)
	if(world.system_type == MS_WINDOWS)
		var/memory_summary = call_ext("memorystats", "get_memory_stats")()
		if(memory_summary)
			rustg_file_write(memory_summary, "data/mem_stat/[GLOB.round_id]-memstat.txt")
