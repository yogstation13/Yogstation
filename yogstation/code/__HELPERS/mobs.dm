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