GLOBAL_DATUM_INIT(holder_state, /datum/ui_state/holder_state, new)

/datum/ui_state/holder_state/can_use_topic(src_object, mob/user)
	if(user.client && user.client.holder)
		return UI_INTERACTIVE
	return UI_CLOSE
