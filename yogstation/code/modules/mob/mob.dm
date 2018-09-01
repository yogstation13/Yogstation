/atom/proc/pointed_at(var/mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_POINTED_AT, user) //why the hell is this here?

/atom/prepare_huds()
	hud_list = list()
	for(var/hud in hud_possible)
		var/image/I = image('yogstation/icons/mob/hud.dmi', src, "")
		I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
		hud_list[hud] = I