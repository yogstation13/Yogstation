/obj/machinery/atmospherics/components/unary/vent_pump
	var/cover = FALSE //For hiding tiny objects in, TRUE means cover is up, can hide.
	var/max_n_of_items = 3

/obj/machinery/atmospherics/components/unary/vent_pump/crowbar_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You begin prying [cover ? "in" : "off"] the vent cover."))
	if(I.use_tool(src, user, 50, volume=50))
		cover = !cover
		to_chat(user, span_notice("You pry [cover ? "off" : "in"] the vent cover."))
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_pump/attackby(obj/item/W, mob/user, params)
	if(cover && !welded)
		if(istype(W) && W.w_class == WEIGHT_CLASS_TINY && user.a_intent != INTENT_HARM)
			if(contents.len>=max_n_of_items || !user.transferItemToLoc(W, src))
				to_chat(user, span_warning("You can't seem to fit [W]."))
				return
			to_chat(user, span_warning("You insert [W] into [src]."))
			return
	..()

/obj/machinery/atmospherics/components/unary/vent_pump/attack_hand(mob/user)
	if(cover && !welded)
		if(!contents.len)
			to_chat(user, span_warning("There's nothing in [src]!"))
			return
		var/obj/item/I = contents[contents.len] //the most recently-added item
		user.put_in_hands(I)
		to_chat(user, span_notice("You take out [I] from [src]."))
	..()

/obj/machinery/atmospherics/components/unary/vent_pump/examine(mob/user)
	.=..()
	if(cover)
		. += "Its cover is open."
