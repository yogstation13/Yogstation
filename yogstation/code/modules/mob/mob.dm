/atom/proc/pointed_at(var/mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_POINTED_AT, user) //why the hell is this here?

/mob
	var/client/oobe_client //when someone aghosts/uses a scrying orb, this holds the client while it's somewhere else