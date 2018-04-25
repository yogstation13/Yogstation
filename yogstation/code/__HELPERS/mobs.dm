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

	if(ismob(user))
		var/mob/temp = user
		if(temp && temp.client && temp.client.prefs)
			return (temp.client.prefs.unlock_content & 2)

	else if(istype(user, /client))
		var/client/temp = user
		if(temp && temp.prefs)
			return (temp.prefs.unlock_content & 2)

	return FALSE

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