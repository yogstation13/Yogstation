/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(usr, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return
	..()