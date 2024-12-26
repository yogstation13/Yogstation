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

#ifndef OPENDREAM
///these procs don't work on od
SUBSYSTEM_DEF(memory_stats)
	name = "Mem Stats"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 5 MINUTES
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

/datum/controller/subsystem/memory_stats/Initialize()
	if(world.system_type != MS_WINDOWS || !rustg_file_exists("memorystats.dll"))
		flags |= SS_NO_FIRE
	// Technically this isn't really as much of an initialization as it is "just disabling itself if it won't work", so no reason to actually print any output
	return SS_INIT_NO_NEED

/datum/controller/subsystem/memory_stats/fire(resumed)
	var/memory_summary = get_memory_stats()
	if(memory_summary)
		rustg_file_write(memory_summary, "data/mem_stat/[GLOB.round_id]-memstat.txt")

/datum/controller/subsystem/memory_stats/proc/get_memory_stats()
	if(world.system_type != MS_WINDOWS || !rustg_file_exists("memorystats.dll"))
		return
	return trimtext(call_ext("memorystats", "get_memory_stats")())
#endif

/client/proc/server_memory_stats()
	set name = "Server Memory Stats"
	set category = "Debug"
	set desc = "Print various statistics about the server's current memory usage (does not work on OpenDream)"

	if(!check_rights(R_DEBUG))
		return
#ifndef OPENDREAM
	var/result = span_danger("Error fetching memory statistics!")
	var/memory_stats = SSmemory_stats.get_memory_stats()
	if(memory_stats)
		result = memory_stats
#else
	var/result = span_danger("Memory statistics not supported on OpenDream, sorry!")
#endif
	to_chat(src, boxed_message(result), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
