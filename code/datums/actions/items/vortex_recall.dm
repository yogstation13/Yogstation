/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable(feedback = FALSE)
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/hierophant_club = target
		if(hierophant_club.teleporting)
			return FALSE
	return ..()
