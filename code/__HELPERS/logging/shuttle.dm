/// Logging for shuttle actions
/proc/log_shuttle(text)
	WRITE_LOG(GLOB.world_game_log, "SHUTTLE: [text]")
