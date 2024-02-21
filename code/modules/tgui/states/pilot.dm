GLOBAL_DATUM_INIT(pilot_state, /datum/ui_state/pilot_state, new)

/datum/ui_state/pilot_state/can_use_topic(src_object, mob/user)
	if(!ismecha(src_object))
		return UI_CLOSE
	var/obj/mecha/gundam = src_object
	if(user == gundam.occupant)
		return UI_INTERACTIVE
	return UI_CLOSE
