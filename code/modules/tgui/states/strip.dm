GLOBAL_DATUM_INIT(strip_state, /datum/ui_state/strip_state, new)

/// Carbons and cyborgs can strip mobs, other living can view but not strip
/datum/ui_state/strip_state/can_use_topic(src_object, mob/user)
	if(iscarbon(user) || iscyborg(user))
		if(!user.Adjacent(src_object))
			return UI_DISABLED
		return UI_INTERACTIVE
	if(isliving(user))
		if(!user.Adjacent(src_object))
			return UI_DISABLED
		return UI_UPDATE
	return UI_CLOSE
