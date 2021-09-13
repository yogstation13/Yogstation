GLOBAL_DATUM_INIT(skill_menu_state, /datum/ui_state/skill_menu, new)

/datum/ui_state/skill_menu/can_use_topic(src_object, mob/user)
	. = UI_CLOSE
	if(check_rights_for(user.client, R_ADMIN))
		. = UI_INTERACTIVE
	else if(istype(src_object, /datum/language_menu))
		var/datum/skill_menu/SM = src_object
		if(SM.skillset.get_atom() == user)
			. = UI_INTERACTIVE
