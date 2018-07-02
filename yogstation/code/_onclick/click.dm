/mob/ClickOn(atom/A, params)
	if(client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return
	..()