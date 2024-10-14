/obj/item/pda/CtrlClick(mob/user)
	if(user.contains_atom(src))
		attack_self(user)
		return TRUE
	return ..()

/obj/item/pda
	light_color = "#ffffff"
