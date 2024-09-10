/obj/item/clothing/neck/necklace/memento_mori/attack_hand(mob/user, list/modifiers)
	if(prevent_accidental_suicide(user))
		return
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/MouseDrop(atom/over_object)
	if(prevent_accidental_suicide(over_object))
		return
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/proc/prevent_accidental_suicide(mob/user)
	if(user == active_owner && tgui_alert(user, "Taking this off will INSTANTLY KILL YOU! Are you really sure you want to take it off?", "Memento Mori", list("Yes", "No")) != "Yes")
		return TRUE
	return FALSE
