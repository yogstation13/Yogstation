/obj/machinery/atmospherics/components/unary/vent_pump
	var/cover = FALSE //For hiding tiny objects in, 1 means cover is up, can hide.
	var/max_n_of_items = 3

/obj/machinery/atmospherics/components/unary/vent_pump/crowbar_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin prying [cover ? "in" : "off"] the vent cover.</span>")
	if(I.use_tool(src, user, 50, volume=50))
		cover = !cover
		to_chat(user, "<span class='notice'>You pry [cover ? "off" : "in"] the vent cover.</span>")
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_pump/attackby(obj/item/W, mob/user, params)
	if(cover && !welded)
		if(istype(W) && W.w_class == WEIGHT_CLASS_TINY && user.a_intent != INTENT_HARM)
			if(contents.len>=max_n_of_items || !user.transferItemToLoc(W, src))
				to_chat(user, "<span class='warning'>You can't seem to fit [W].</span>")
				return
			to_chat(user, "<span class='warning'>You insert [W] into [src].</span>")
			return
	..()

/obj/machinery/atmospherics/components/unary/vent_pump/attack_hand(mob/user)
	if(cover && !welded)
		if(!contents.len)
			to_chat(user, "<span class='warning'>There's nothing in [src]!</span>")
			return
		var/obj/item/I = contents[contents.len] //the most recently-added item
		user.put_in_hands(I)
		to_chat(user, "<span class='notice'>You take out [I] from [src].</span>")
	..()

/obj/machinery/atmospherics/components/unary/vent_pump/examine(mob/user)
	..()
	if(cover)
		to_chat(user, "Its cover is open.")
