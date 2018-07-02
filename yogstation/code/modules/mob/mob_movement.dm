/client/Move(n, direct)
	if(prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return FALSE
	..()