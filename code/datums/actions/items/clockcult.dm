/datum/action/item_action/clock
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	background_icon_state = "bg_clock"
	buttontooltipstyle = "clockcult"

/datum/action/item_action/clock/IsAvailable(feedback = FALSE)
	if(!is_servant_of_ratvar(owner))
		return FALSE
	return ..()

/datum/action/item_action/clock/hierophant
	name = "Hierophant Network"
	desc = "Lets you discreetly talk with all other servants. Nearby listeners can hear you whispering, so make sure to do this privately."
	button_icon_state = "hierophant_slab"

/datum/action/item_action/clock/quickbind
	name = "Quickbind"
	desc = "If you're seeing this, file a bug report."
	var/scripture_index = 0 //the index of the scripture we're associated with
