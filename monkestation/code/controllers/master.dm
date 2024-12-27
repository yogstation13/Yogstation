#ifndef OPENDREAM
/datum/controller/master/init_subsystem(datum/controller/subsystem/subsystem)
	. = ..()
	var/static/no_memstat = FALSE
	if(no_memstat)
		return
	try
		var/memory_summary = trimtext(replacetext(call_ext(MEMORYSTATS_DLL_PATH, "memory_stats")(), "Server mem usage:", ""))
		if(memory_summary)
			rustg_file_append("=== [subsystem.name] ===\n[memory_summary]\n", "[GLOB.log_directory]/profiler/memstat-init.txt")
		else
			no_memstat = TRUE
	catch
		no_memstat = TRUE
#endif
