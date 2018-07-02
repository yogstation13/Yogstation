/mob/living/silicon/robot/ClickOn(var/atom/A, var/params)
	if(client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return
	..()