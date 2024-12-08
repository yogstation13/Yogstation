/obj/item/flashlight/lantern/rayne
	name = "lantern"
	icon = 'monkestation/icons/obj/rayne_corp/rayne.dmi'
	icon_state = "rayne_lantern"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	desc = "A lantern that hangs off the shoulder providing some warmth and lighting with an incandescent heat lamp. \
			This is an old piece of technology, usefull for exploring cold planetoids or the void of space. \
			It is stamped with a Rayne Corp logo on the bottom."
	light_outer_range = 5// luminosity when on
	light_system = OVERLAY_LIGHT
	inhand_icon_state = "rayne_lantern"
	worn_icon = 'monkestation/icons/obj/rayne_corp/rayne.dmi'
	worn_icon_state = "rayne_lantern_worn"
	slot_flags = ITEM_SLOT_NECK | ITEM_SLOT_BELT

/obj/item/flashlight/lantern/rayne/process(seconds_per_tick)

	var/mob/living/user = loc
	if(!istype(user))
		return
	user.adjust_bodytemperature(2 * seconds_per_tick, max_temp = user.standard_body_temperature)

/obj/item/flashlight/lantern/rayne/toggle_light()
	..()
	//icon_state = "rayne_lantern_[on ? "on" : "off"]"
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	var/mob/user = loc
	if(!istype(user))
		return
	balloon_alert(user, "heater [on ? "on" : "off"]")
	return TRUE
