// Reactor frame, used to build a finished reactor
/obj/structure/reactor_frame
	name = "nuclear reactor frame"
	desc = "The outer shell of a nuclear reactor core, made from plasteel due to its excellent strength and radiation shielding."
	icon = 'icons/obj/machines/reactor.dmi'
	icon_state = "reactor_frame_0"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF // no
	density = FALSE
	anchored = TRUE
	pixel_x = -32
	pixel_y = -32
	var/completion = 0

/obj/structure/reactor_frame/examine(mob/user)
	. = ..()
	if(!anchored)
		. += span_notice("It can be secured with a wrench.")
		return
	switch(completion)
		if(0)
			. += span_notice("The frame can be reinforced with metal rods, or unsecured with a wrench.")
		if(1)
			. += span_notice("The metal rods can be welded into place.")
		if(2)
			. += span_notice("The control rods can be added using plasteel sheets.")
		if(3)
			. += span_notice("The coolant pipes can be wrenched into place.")

/obj/structure/reactor_frame/attackby(obj/item/I, mob/living/user, params)
	var/obj/item/stack/S = I
	if(istype(S, /obj/item/stack/rods))
		if(!anchored)
			user.balloon_alert(user, span_notice("anchor it first!"))
			return
		if(completion > 0)
			user.balloon_alert(user, span_notice("already reinforced!"))
			return
		if(S.use_tool(src, user, 2 SECONDS, 20))
			completion++
			update_icon()
			return
		return
	if(I.tool_behaviour == TOOL_WELDER)
		if(completion < 1)
			user.balloon_alert(user, span_notice("add rods first!"))
			return
		if(completion > 1)
			user.balloon_alert(user, span_notice("already welded!"))
			return
		if(I.use_tool(src, user, 2 SECONDS, 1, 50))
			completion++
			update_icon()
			return
		return
	if(istype(S, /obj/item/stack/sheet/plasteel))
		if(completion < 2)
			user.balloon_alert(user, span_notice("weld it first!"))
			return
		if(completion > 2)
			user.balloon_alert(user, span_notice("already has control rods!"))
			return
		if(I.use_tool(src, user, 2 SECONDS, 10))
			completion++
			update_icon()
			return
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		if(!completion)
			I.use_tool(src, user, 0, volume=50)
			I.play_tool_sound(src, 50)
			setAnchored(!anchored)
			user.balloon_alert(user, span_notice("[anchored ? "" : "un"]secured"))
			return
		if(I.use_tool(src, user, 2 SECONDS, volume=50))
			new /obj/machinery/atmospherics/components/trinary/nuclear_reactor(get_turf(src))
			qdel(src)
			return
		return
	return ..()

/obj/structure/reactor_frame/update_icon(updates)
	. = ..()
	icon_state = "reactor_frame_[completion]"

/obj/structure/reactor_corium
	name = "radioactive mass"
	desc = "A large mass of molten reactor fuel, sometimes called corium. If you can see it, you're probably close enough to receive a lethal dose of radiation."
	icon = 'icons/obj/machines/reactor.dmi'
	icon_state = "reactor_corium"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF // no
	light_color = LIGHT_COLOR_RED
	light_range = 10
	light_on = TRUE
	anchored = TRUE
	density = FALSE
	pixel_x = -32
	pixel_y = -32

/obj/structure/reactor_corium/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/radioactive, 15000, src, 0)
