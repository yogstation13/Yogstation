#define LIGHT_BARE 1
#define LIGHT_WIRE 2
#define LIGHT_CONSTRUCTED 3

/datum/wires/light_switch
	holder_type = /obj/machinery/light_switch
	proper_name = "Light Switch"

/datum/wires/light_switch/New(atom/holder)
	wires = list(
		WIRE_POWER,
	)
	..()

/datum/wires/light_switch/interactable(mob/user)
	var/obj/machinery/light_switch/A = holder
	if(A.panel_open && A.construction_state == LIGHT_WIRE)
		return TRUE

/datum/wires/light_switch/get_status()
	var/obj/machinery/light_switch/A = holder
	var/list/status = list()
	status += "The relay light is [A.area.lightswitch ? "green" : "red"]."
	return status

/datum/wires/light_switch/on_pulse(wire)
	var/obj/machinery/light_switch/A = holder
	switch(wire)
		if(WIRE_POWER)
			if(A.area.lightswitch)
				A.turn_off()
			else
				A.turn_on()

/datum/wires/light_switch/on_cut(wire, mend)
	var/obj/machinery/light_switch/A = holder
	switch(wire)
		if(WIRE_POWER)
			A.shock(usr, 50)
			if(mend)
				A.stat &= ~BROKEN
				A.turn_on()
			else
				A.stat &= BROKEN
				A.turn_off()



/obj/item/wallframe/light_switch
	name = "light switch frame"
	desc = "Used for building light switches."
	icon = 'icons/obj/power.dmi'
	icon_state = "light-b"
	result_path = /obj/machinery/light_switch
	pixel_shift = -25

/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light-b"
	desc = "Make dark."
	power_channel = AREA_USAGE_LIGHT

	///Range of the light emitted when powered, but off
	var/light_on_range = 1

	/// Set this to a string, path, or area instance to control that area
	/// instead of the switch's location.
	var/area/area = null
	var/construction_state = LIGHT_BARE

/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/light_switch(src)
	if(istext(area))
		area = text2path(area)
	if(ispath(area))
		area = GLOB.areas_by_type[area]
	if(!area)
		area = get_area(src)

	if(!name)
		name = "light switch ([area.name])"

	if(mapload)
		construction_state = LIGHT_CONSTRUCTED

	update_appearance()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD
	return INITIALIZE_HINT_NORMAL

/obj/machinery/light_switch/update_appearance(updates=ALL)
	. = ..()
	luminosity = (stat & NOPOWER) ? 0 : 1

/obj/machinery/light_switch/update_icon_state()
	set_light(area.lightswitch ? 0 : light_on_range)
	switch(construction_state)
		if(LIGHT_BARE)
			icon_state = "light-b"
		if(LIGHT_WIRE)
			icon_state = "light-w"
		if(LIGHT_CONSTRUCTED)
			icon_state = "light-c"
	
	return ..()

/obj/machinery/light_switch/update_overlays()
	. = ..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(construction_state != LIGHT_CONSTRUCTED)
		return
	. += mutable_appearance(icon, "[area.lightswitch ? "light1" : "light0"]")
	. += emissive_appearance(icon, "[area.lightswitch ? "light1" : "light0"]", src)

/obj/machinery/light_switch/proc/turn_off()
	if(!area.lightswitch)
		return
	area.lightswitch = FALSE
	area.update_appearance()

	for(var/obj/machinery/light_switch/L in area)
		L.update_appearance()

	area.power_change()

/obj/machinery/light_switch/proc/turn_on()
	if(area.lightswitch)
		return
	area.lightswitch = TRUE
	area.update_appearance()

	for(var/obj/machinery/light_switch/L in area)
		L.update_appearance()

	area.power_change()

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "It is [area.lightswitch ? "on" : "off"]."
	if((obj_flags & EMAGGED) && user.can_hear())
		. += span_danger("You hear a faint hum coming from the switch.")

/obj/machinery/light_switch/interact(mob/user)
	if(obj_flags & EMAGGED)
		shock(user)
	if(construction_state != LIGHT_CONSTRUCTED)
		return
	. = ..()

	area.lightswitch = !area.lightswitch
	play_click_sound("button")

	for(var/obj/machinery/light_switch/L in area)
		L.update_appearance()

	area.power_change()

/obj/machinery/light_switch/attackby(obj/item/W, mob/user, params)
	switch(construction_state)
		if(LIGHT_BARE)
			var/obj/item/stack/cable_coil/c = W
			if(istype(c) && c.use(1))
				to_chat(user, span_notice("You insert wiring into [src]."))
				construction_state = LIGHT_WIRE
				update_appearance()
				return
			if(W.tool_behaviour == TOOL_WRENCH)
				W.play_tool_sound(src)
				to_chat(user, span_notice("You remove the frame."))
				new /obj/item/wallframe/light_switch(loc)
				qdel(src)
				return
		if(LIGHT_WIRE)
			if(W.tool_behaviour == TOOL_WIRECUTTER && wires.is_cut(WIRE_POWER))
				W.play_tool_sound(src)
				to_chat(user, span_notice("You cut the wires out."))
				new /obj/item/stack/cable_coil(loc, 1)
				construction_state = LIGHT_BARE
				update_appearance()
				return
			if(panel_open && is_wire_tool(W))
				wires.interact(user)
				return
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				W.play_tool_sound(src)
				to_chat(user, span_notice("You screw the cover on."))
				panel_open = FALSE
				construction_state = LIGHT_CONSTRUCTED
				update_appearance()
				return
		if(LIGHT_CONSTRUCTED)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				W.play_tool_sound(src)
				to_chat(user, span_notice("You take the cover off."))
				panel_open = TRUE
				construction_state = LIGHT_WIRE
				update_appearance()
				return
	return ..()

/obj/machinery/light_switch/power_change()
	if(area == get_area(src))
		return ..()

/obj/machinery/light_switch/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(stat & (BROKEN|NOPOWER)))
		power_change()

/obj/machinery/light_switch/proc/shock(mob/user)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	electrocute_mob(user, get_area(src), src, 0.7, TRUE)


/obj/machinery/light_switch/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("Nothing new seems to happen when you swipe the emag."))
		return FALSE
	to_chat(user, span_notice("You swipe the emag on the light switch. "))
	if(user.can_hear())
		to_chat(user, span_notice("The light switch gives off a soft hum."))
	obj_flags |= EMAGGED
	return TRUE
