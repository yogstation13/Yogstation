/obj/item/powersink/examine(mob/user)
	. = ..()
	if(isobserver(user))
		to_chat(user, "The power dial reads [power_drained] J.")