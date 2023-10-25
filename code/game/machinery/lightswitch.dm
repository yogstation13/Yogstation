/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light-p"
	desc = "Make dark."
	power_channel = AREA_USAGE_LIGHT

	light_power = 0
	light_range = 7

	/// Set this to a string, path, or area instance to control that area
	/// instead of the switch's location.
	var/area/area = null

/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	if(istext(area))
		area = text2path(area)
	if(ispath(area))
		area = GLOB.areas_by_type[area]
	if(!area)
		area = get_area(src)

	if(!name)
		name = "light switch ([area.name])"

	update_appearance(UPDATE_ICON)
	if(mapload)
		return INITIALIZE_HINT_LATELOAD
	return

/obj/machinery/light_switch/LateInitialize()
	if(!is_station_level(z))
		return
	var/area/source_area = get_area(get_turf(src))
	if(source_area.lights_always_start_on)
		return
	turn_off()

/obj/machinery/light_switch/update_overlays()
	. = ..()
	if(stat & NOPOWER)
		return
	if(area.lightswitch)
		. += "light1"
	else
		. += "light0"

/obj/machinery/light_switch/proc/turn_off()
	if(!area.lightswitch)
		return
	area.lightswitch = FALSE
	area.update_icon()

	for(var/obj/machinery/light_switch/L in area)
		L.update_icon()

	area.power_change()

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "It is [area.lightswitch ? "on" : "off"]."
	if((obj_flags & EMAGGED) && user.can_hear())
		. += span_danger("You hear a faint hum coming from the switch.")

/obj/machinery/light_switch/interact(mob/user)
	if(obj_flags & EMAGGED)
		shock(user)
	. = ..()

	area.lightswitch = !area.lightswitch
	area.update_appearance(UPDATE_ICON)
	play_click_sound("button")

	for(var/obj/machinery/light_switch/L in area)
		L.update_appearance(UPDATE_ICON)

	area.power_change()

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
