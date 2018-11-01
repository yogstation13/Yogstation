/client/Click()
	if(src.prefs && src.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You have been frozen by an administrator.</span>")
		return
	return ..()