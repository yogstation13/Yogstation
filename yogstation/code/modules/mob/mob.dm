/atom/proc/pointed_at(var/mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_POINTED_AT, user)