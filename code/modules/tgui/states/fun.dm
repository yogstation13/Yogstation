GLOBAL_DATUM_INIT(fun_state, /datum/ui_state/fun_state, new)

/datum/ui_state/fun_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, R_FUN))
		return UI_INTERACTIVE
	return UI_CLOSE
