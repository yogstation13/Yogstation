PROCESSING_SUBSYSTEM_DEF(priority_effects)
	name = "Priority Status Effects"
	flags = SS_TICKER | SS_KEEP_TIMING | SS_NO_INIT
	wait = 2 // Not seconds - we're running on SS_TICKER, so this is ticks.
	stat_tag = "PEFF"
