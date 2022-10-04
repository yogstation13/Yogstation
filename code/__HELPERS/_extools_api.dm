//#define AUXOOLS_LOGGING // rust_g is used as a fallback if this is undefined

/proc/extools_log_write()

/proc/extools_finalize_logging()

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

//this exists because gases may be created when the MC doesn't exist yet
GLOBAL_REAL_VAR(list/__auxtools_initialized)

#define AUXTOOLS_CHECK(LIB)\
	if (!islist(__auxtools_initialized)) {\
		__auxtools_initialized = list();\
	}\
	if (!__auxtools_initialized[LIB]) {\
		if (fexists(LIB)) {\
			var/string = call(LIB,"auxtools_init")();\
			__auxtools_initialized[LIB] = TRUE;\
			if(!findtext(string, "SUCCESS")) {\
				CRASH(string);\
			}\
		} else {\
			CRASH("No file named [LIB] found!")\
		}\
	}\

#define AUXTOOLS_SHUTDOWN(LIB)\
	if (__auxtools_initialized[LIB] && fexists(LIB)){\
		call(LIB,"auxtools_shutdown")();\
		__auxtools_initialized[LIB] = FALSE;\
	}\
