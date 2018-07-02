/mob/dead/observer/DblClickOn(var/atom/A, var/params)
	if(client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return
	..()

/mob/dead/observer/ClickOn(var/atom/A, var/params)
	if(client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return
	..()