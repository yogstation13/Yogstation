/mob/living/silicon/ai/DblClickOn(var/atom/A, params)
	if(client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return
	..()

/mob/living/silicon/ai/ClickOn(var/atom/A, params)
	if(client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return
	..()