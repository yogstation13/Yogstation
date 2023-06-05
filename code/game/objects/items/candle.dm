#define CANDLE_LUMINOSITY	2

/obj/item/candle
	name = "red candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to \
		humankind. The jewelry he kept for himself."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = WEIGHT_CLASS_TINY
	light_system = MOVABLE_LIGHT
	light_range = CANDLE_LUMINOSITY
	light_color = LIGHT_COLOR_FIRE
	light_on = FALSE
	heat = 1000
	var/wax = 2000
	var/lit = FALSE
	var/infinite = FALSE
	var/start_lit = FALSE
	var/candle_type = "red"

/obj/item/candle/Initialize()
	. = ..()
	if(start_lit)
		light()

/obj/item/candle/update_icon()
	icon_state = "candle[(wax > 800) ? ((wax > 1500) ? 1 : 2) : 3][lit ? "_lit" : ""]"

/obj/item/candle/attackby(obj/item/W, mob/user, params)
	var/msg = W.ignition_effect(src, user)
	if(msg)
		light(msg)
	else
		return ..()

/obj/item/candle/fire_act(exposed_temperature, exposed_volume)
	if(!lit)
		light() //honk
	return ..()

/obj/item/candle/is_hot()
	return lit * heat

/obj/item/candle/proc/light(show_message)
	if(!lit)
		lit = TRUE
		if(show_message)
			usr.visible_message(show_message)
		set_light_on(TRUE)
		START_PROCESSING(SSobj, src)
		update_icon()

/obj/item/candle/proc/put_out_candle()
	if(!lit)
		return
	lit = FALSE
	update_icon()
	set_light_on(FALSE)
	return TRUE

/obj/item/candle/extinguish()
	put_out_candle()
	return ..()

/obj/item/candle/process(delta_time)
	if(!lit)
		return PROCESS_KILL
	if(!infinite)
		wax -= delta_time
	if(wax <= 0)
		if(candle_type == "resin")
			new /obj/item/trash/candle/resin(loc)
			qdel(src)
		else
			new /obj/item/trash/candle(loc)
			qdel(src)
	update_icon()
	open_flame()

/obj/item/candle/attack_self(mob/user)
	if(put_out_candle())
		user.visible_message(span_notice("[user] snuffs [src]."))

/obj/item/candle/infinite
	infinite = TRUE
	start_lit = TRUE

/obj/item/candle/resin
	name = "resin candle"
	desc = "An extra thick candle made of hardened resin to guarantee a \
			long burn. Smells like a mix of ash and mushrooms."
	icon = 'icons/obj/candle.dmi'
	icon_state = "resincandle1"
	item_state = "resincandle1"
	w_class = WEIGHT_CLASS_TINY
	light_color = LIGHT_COLOR_FIRE
	heat = 1000
	wax = 2000
	candle_type = "resin"

/obj/item/candle/resin/update_icon()
	icon_state = "resincandle[(wax > 800) ? ((wax > 1500) ? 1 : 2) : 3][lit ? "_lit" : ""]"

#undef CANDLE_LUMINOSITY
