/mob/Login()
	. = ..()
	if(!. || QDELETED(client))
		return FALSE

	if(QDELETED(client?.client_token_holder))
		if(!client?.prefs.loaded)
			CRASH("Tried to load client_token's on a logging in mob but prefs haven't loaded.")
		client?.client_token_holder = new(client)
