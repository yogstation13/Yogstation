/obj/screen/drop/Click()
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()

/obj/screen/act_intent/Click(location, control, params)
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()

/obj/screen/internals/Click()
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()

/obj/screen/mov_intent/Click()
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()

/obj/screen/pull/Click()
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()

/obj/screen/resist/Click()
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()

/obj/screen/storage/Click(location, control, params)
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()

/obj/screen/throw_catch/Click()
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()

/obj/screen/zone_sel/Click(location, control,params)
	if(usr.client && usr.client.prefs.afreeze)
		to_chat(src, "<span class='userdanger'>You are frozen by an administrator.</span>")
		return TRUE
	..()