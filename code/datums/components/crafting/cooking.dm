/datum/component/cooking/Initialize()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(create_mob_button))

/datum/component/cooking/proc/create_mob_button(mob/user, client/CL)
	var/datum/hud/H = user.hud_used
	var/atom/movable/screen/cook/C = new()
	C.icon = H.ui_style
	H.static_inventory += C
	CL.screen += C
	RegisterSignal(C, COMSIG_CLICK, PROC_REF(component_ui_interact))

/datum/component/cooking
	var/busy
	var/display_craftable_only = FALSE
	var/display_compact = FALSE

/datum/component/cooking/proc/component_ui_interact(atom/movable/screen/craft/image, location, control, params, user)
	if(user == parent)
		ui_interact(user)
