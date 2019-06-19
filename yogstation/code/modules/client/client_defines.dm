/client
	var/connection_number = 0
	var/last_ping_time = 0 // Stores the last time this cilent pinged someone in OOC, to protect against spamming pings
	var/last_note_query = 0 // Stores the last time this client asked for their notes, to prevent spamming
	
	var/list/afreeze_stored_verbs = list()