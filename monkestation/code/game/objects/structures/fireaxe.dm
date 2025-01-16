/obj/structure/fireaxecabinet/attackby(obj/item/attacking_item, mob/living/user, params)
	if (isdrone(user) && attacking_item.tool_behaviour == TOOL_MULTITOOL)
		to_chat(src, span_warning("Using [src] could break your laws."))
		return
	. = ..()

/obj/structure/fireaxecabinet/attack_hand(mob/user, list/modifiers)
	if (isdrone(user))
		to_chat(src, span_warning("Using [src] could break your laws."))
		return
	. = ..()
