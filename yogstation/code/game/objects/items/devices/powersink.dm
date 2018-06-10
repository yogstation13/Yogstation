/obj/item/powersink/examine(mob/user)
	. = ..()
	if(isobserver(user))
		to_chat(user, "The power dial reads [power_drained] J.")

/obj/item/powersink/multitool_act(mob/user)
	to_chat(user, "The power dial reads [power_drained] J.")
	return TRUE