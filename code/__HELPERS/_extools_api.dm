//#define AUXOOLS_LOGGING // rust_g is used as a fallback if this is undefined

/proc/extools_log_write()

/proc/extools_finalize_logging()

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

GLOBAL_LIST_EMPTY(auxtools_initialized)

#define AUXTOOLS_CHECK(LIB)\
	if (!GLOB.auxtools_initialized[LIB]) {\
		if (fexists(LIB)) {\
			var/string = call(LIB,"auxtools_init")();\
			GLOB.auxtools_initialized[LIB] = TRUE;\
			if(!findtext(string, "SUCCESS")) {\
				CRASH(string);\
			}\
		} else {\
			CRASH("No file named [LIB] found!")\
		}\
	}\

#define AUXTOOLS_SHUTDOWN(LIB)\
	if (GLOB.auxtools_initialized[LIB] && fexists(LIB)){\
		call(LIB,"auxtools_shutdown")();\
		GLOB.auxtools_initialized[LIB] = FALSE;\
	}\
