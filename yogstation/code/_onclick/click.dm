/client/Click()
	if(src.prefs && src.prefs.afreeze)
		to_chat(src, span_userdanger("You have been frozen by an administrator."))
		return
	return ..()