/obj/item/flashlight/seclite/flicker
	name = "old flashlight"
	desc = "A robust flashlight used by the military back in the day. This one is old. Alt-Click to remove the battery."
	icon_state = "seclite"
	item_state = "seclite"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 9 // Not as good as a stun baton.
	brightness_on = 4 // A little better than the standard flashlight.
	hitsound = 'sound/weapons/genhit1.ogg'
	var/obj/item/stock_parts/cell/metro/cell
	var/is_flickering = FALSE

/obj/item/flashlight/seclite/flicker/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell/metro))
		if(cell)
			cell.forceMove(loc)
			to_chat(user, "<span class='info'>You replace the current cell with a new one.</span>")
		else
			to_chat(user, "<span class='info'>You insert a power cell.</span>")
		cell = W
		W.forceMove(src)

/obj/item/flashlight/seclite/flicker/attack_self(mob/user)
	..()
	if(!cell)
		on = FALSE
		update_brightness()
		to_chat(user, "<span class='warning'>The flashlight needs a power cell to function!</span>")
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/flashlight/seclite/flicker/process()
	if(cell.use(5))
		if(cell.percent() < 50 && !is_flickering)
			visible_message("[src] flickers")
			flashlight_power = 0.5 //strength of the light when on
			update_brightness()
			is_flickering = TRUE
		else
			if(cell.percent() > 50 && is_flickering)
				flashlight_power = 1
				update_brightness()
				is_flickering = FALSE
	else
		on = FALSE
		update_brightness()
		STOP_PROCESSING(SSobj, src)

/obj/item/flashlight/seclite/flicker/AltClick(mob/user)
	if(!cell)
		to_chat(user, "<span class='warning'>There is no cell inside!</span>")
	if(user.can_put_in_hand(cell, 1))
		user.put_in_hand(cell, 1)

