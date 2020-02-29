/proc/random_unique_gorilla_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(gorilla_name(gender))

		if(!findname(.))
			break

/proc/is_admin(var/user)
	if(ismob(user))
		var/mob/temp = user
		if(temp && temp.client && temp.client.holder)
			return TRUE

	else if(istype(user, /client))
		var/client/temp = user
		if(temp && temp.holder)
			return TRUE

	return FALSE

/proc/is_donator(var/user)
	if(is_admin(user))
		return TRUE

	if(CONFIG_GET(flag/everyone_is_donator))
		return TRUE

	if(ismob(user))
		var/mob/temp = user
		if(temp && temp.client)
			if(temp.client.is_mentor())
				return TRUE
			if(temp.client.prefs)
				return (temp.client.prefs.unlock_content & 2)

	else if(istype(user, /client))
		var/client/temp = user
		if(temp)
			if(temp.is_mentor())
				return TRUE
			if(temp.prefs)
				return (temp.prefs.unlock_content & 2)

	return FALSE

/proc/get_donators()
	if(GLOB.donators.len)
		return GLOB.donators
	
	//Else if GLOB.donators has not been loaded yet, then load it in!
	if(!SSdbcore.IsConnected())
		message_admins("Failed to connect to database in get_donators().")
		log_sql("Failed to connect to database in get_donators().")
		return

	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("donors")] WHERE (expiration_time > Now()) AND (revoked IS NULL)")
	if(!query.Execute())
		message_admins("Error loading donators from database.")
		log_sql("Error loading donators from database.")
		qdel(query)
		return

	var/key
	while(query.NextRow())
		key = query.item[1]
		if(key)
			GLOB.donators |= ckey(key)

	qdel(query)
	return GLOB.donators

/proc/compare_ckey(var/user, var/target)
	if(!user || !target)
		return FALSE

	var/key1 = user
	var/key2 = target

	if(ismob(user))
		var/mob/M = user
		if(M.ckey)
			key1 = M.ckey
		else if(M.client && M.client.ckey)
			key1 = M.client.ckey
	else if(istype(user, /client))
		var/client/C = user
		key1 = C.ckey
	else
		key1 = lowertext(key1)

	if(ismob(target))
		var/mob/M = target
		if(M.ckey)
			key2 = M.ckey
		else if(M.client && M.client.ckey)
			key2 = M.client.ckey
	else if(istype(target, /client))
		var/client/C = target
		key2 = C.ckey
	else
		key2 = lowertext(key2)


	if(key1 == key2)
		return TRUE
	else
		return FALSE
