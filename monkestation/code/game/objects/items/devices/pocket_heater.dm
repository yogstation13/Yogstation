/// How long one of these lasts with a 10 MJ cell, in seconds.
#define HEATER_TIME 1800

/// How much charge this consumes per second.
#define CHARGE_PER_SECOND (10000 / HEATER_TIME)

/obj/item/pocket_heater/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/high(src)
	capacitor = new /obj/item/stock_parts/capacitor(src)

/obj/item/pocket_heater
	name = "pocket heater"
	desc = "A highly compact electronic heater that fits in your pocket. Mainly used by the members of cold-blooded species on expeditions to frigid environments."
	icon = 'monkestation/icons/obj/items/pocket_heater.dmi'
	icon_state = "heater_off"
	w_class = WEIGHT_CLASS_SMALL

	var/obj/item/stock_parts/cell/cell
	var/obj/item/stock_parts/capacitor/capacitor

	var/on = FALSE

/obj/item/pocket_heater/Destroy(force)
	. = ..()
	cell = null
	capacitor = null

/obj/item/pocket_heater/process(seconds_per_tick)
	if(!cell.use(CHARGE_PER_SECOND * seconds_per_tick))
		set_on(FALSE)
		return

	var/mob/living/user = loc
	if(!istype(user))
		return

	user.adjust_bodytemperature(capacitor.rating * seconds_per_tick, max_temp = user.standard_body_temperature)

/obj/item/pocket_heater/examine(mob/user)
	. = ..()

	if(cell)
		if(cell.charge > CHARGE_PER_SECOND * SSobj.wait)
			. += span_notice("It has [ceil(cell.charge / CHARGE_PER_SECOND / 60)] minute\s of charge left, right-click to remove the cell.")
		else
			. += span_warning("It's out of charge, right-click to remove the cell.")
	else
		. += span_warning("It lacks a cell.")

	if(capacitor)
		. += span_notice("Its heating power is at [capacitor.rating * 25]%, use a screwdriver to remove the capacitor.")
		if(capacitor.rating < 2)
			. += span_warning("Due to its low heating power, thermal insulation is highly recommended.")
	else
		. += span_warning("It lacks a capacitor.")

/obj/item/pocket_heater/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(cell)
			balloon_alert(user, "already has a cell!")
		else
			balloon_alert(user, "cell inserted")
			playsound(src, 'sound/machines/click.ogg', vol = 30, vary = TRUE)
			cell = attacking_item
			cell.forceMove(src)
		return

	if(istype(attacking_item, /obj/item/stock_parts/capacitor))
		if(capacitor)
			balloon_alert(user, "already has a capacitor!")
		else
			balloon_alert(user, "capacitor inserted")
			playsound(src, 'sound/machines/click.ogg', vol = 30, vary = TRUE)
			capacitor = attacking_item
			capacitor.forceMove(src)
		return

	return ..()

/obj/item/pocket_heater/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	remove_cell(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/pocket_heater/attack_self_secondary(mob/user, modifiers)
	. = ..()
	remove_cell(user)

/obj/item/pocket_heater/proc/remove_cell(mob/user)
	if(!cell)
		balloon_alert(user, "no cell!")
		return

	balloon_alert(user, "cell removed")
	playsound(src, 'sound/machines/click.ogg', vol = 30, vary = TRUE)
	user.put_in_hands(cell)
	cell = null
	set_on(FALSE, silent = TRUE)

/obj/item/pocket_heater/screwdriver_act(mob/living/user, obj/item/tool)
	if(!capacitor)
		balloon_alert(user, "no capacitor!")
		return TRUE

	balloon_alert(user, "capacitor removed")
	tool.play_tool_sound(src)
	user.put_in_hands(capacitor)
	capacitor = null
	set_on(FALSE, silent = TRUE)

	return TRUE

/obj/item/pocket_heater/attack_self_secondary_tk(mob/user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/pocket_heater/attack_self(mob/user, modifiers)
	. = ..()

	if(on)
		set_on(FALSE)
		return

	if(!cell)
		balloon_alert(user, "no cell!")
		return

	if(!cell.charge)
		balloon_alert(user, "no charge!")
		return

	if(cell.charge < CHARGE_PER_SECOND * SSobj.wait)
		balloon_alert(user, "not enough charge!")
		return

	if(!capacitor)
		balloon_alert(user, "no capacitor!")
		return

	set_on(TRUE)

/obj/item/pocket_heater/proc/set_on(new_on, silent = FALSE)
	if(on == new_on)
		return
	on = new_on

	icon_state = "heater_[on ? "on" : "off"]"

	if(!silent)
		playsound(src, 'sound/machines/click.ogg', vol = 30, vary = TRUE)

	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

	if(silent)
		return

	var/mob/user = loc
	if(!istype(user))
		return

	balloon_alert(user, "heater [on ? "on" : "off"]")

#undef HEATER_TIME
#undef CHARGE_PER_SECOND
