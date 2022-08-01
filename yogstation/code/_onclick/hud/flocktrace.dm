/mob/camera/flocktrace/ClickOn(var/atom/A, var/params)
	if(stored_action)
		if(stored_action.perform_action(A))
			return
	var/list/modifiers = params2list(params)
	A.attack_flocktrace(src, modifiers)

/atom/proc/attack_flocktrace(/mob/camera/flocktrace/user, var/list/modifiers)
	return
