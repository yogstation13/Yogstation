/client
	var/connection_number = 0
	var/last_ping_time = 0 // Stores the last time this cilent pinged someone in OOC, to protect against spamming pings

	var/list/afreeze_stored_verbs = list()

	var/last_antag_token_check
	var/antag_token_timer