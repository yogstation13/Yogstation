#define INIT_PROFILE_NAME "init_profiler.json"

///Subsystem exists so we can separately log init time costs from the costs of general operation
///Hopefully this makes sorting out what causes problems when easier
SUBSYSTEM_DEF(init_profiler)
	name = "Init Profiler"
	init_order = INIT_ORDER_INIT_PROFILER
	init_stage = INITSTAGE_MAX
	flags = SS_NO_FIRE

/datum/controller/subsystem/init_profiler/Initialize()
	if(CONFIG_GET(flag/auto_profile))
		write_init_profile()
		return SS_INIT_SUCCESS
	return SS_INIT_NO_NEED

/datum/controller/subsystem/init_profiler/proc/write_init_profile()
	var/list/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
	current_profile_data = json_decode(current_profile_data) // yes this is stupid but this gets us a list in a non-awful format
	CHECK_TICK
	sortTim(current_profile_data, GLOBAL_PROC_REF(sort_overtime_dsc))

	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	rustg_file_write(json_encode(current_profile_data), "[GLOB.log_directory]/[INIT_PROFILE_NAME]")
	world.Profile(PROFILE_CLEAR) //Now that we're written this data out, dump it. We don't want it getting mixed up with our current round data

#undef INIT_PROFILE_NAME
