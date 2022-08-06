/mob/camera/flocktrace/ClickOn(atom/A, params)
	if(stored_action?.perform_action(A))
		qdel(stored_action)
		stored_action = null
		return
	var/list/modifiers = params2list(params)
	A.attack_flocktrace(src, modifiers)

/atom/proc/attack_flocktrace(mob/camera/flocktrace/user, list/modifiers)
	return
