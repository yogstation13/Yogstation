/mob/camera/flocktrace/ClickOn(var/atom/A, var/params)
	var/list/modifiers = params2list(params)
	A.attack_flocktrace(src, modifiers)

/atom/proc/attack_flocktrace(/mob/camera/flocktrace/user, var/list/modifiers)
	return