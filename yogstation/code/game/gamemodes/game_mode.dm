/datum/game_mode/proc/remove_quiet_rounders(list/datum/candidates)
	for(var/datum/mind/possible_antag in candidates)
		if(!(possible_antag.current.client.prefs.toggles & QUIET_ROUND))
			candidates -= possible_antag
