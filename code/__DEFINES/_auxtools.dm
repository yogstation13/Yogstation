#define AUXMOS (world.system_type == MS_WINDOWS ? "auxmos.dll" : __detect_auxmos())

/proc/__detect_auxmos()
	if (fexists("./libauxmos.so"))
		return "./libauxmos.so"
	else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/libauxmos.so"))
		return "[world.GetConfig("env", "HOME")]/.byond/bin/libauxmos.so"
	else
		CRASH("Could not find libauxmos.so")

/proc/enable_debugging()
    CRASH("Auxtools not found")
