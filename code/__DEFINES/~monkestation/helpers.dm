/// Until a condition is true, sleep, or until a certain amount of time has passed.
/// Basically, UNTIL() but with a timeout.
#define UNTIL_OR_TIMEOUT(Condition, Timeout) \
	do { \
		var/__end_time = REALTIMEOFDAY + (Timeout); \
		UNTIL((Condition) || (REALTIMEOFDAY > __end_time)); \
	} while(0)
