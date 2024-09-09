/obj/machinery/oven
	///our temperature for baked goods
	var/temperature = J_LO
	///time stamps specifically for chewin recipes
	var/cooking_timestamp = 0
	///our reference timestamp
	var/reference_time = 0
	///our oven timer
	var/oven_timer
	///timer duration
	var/timer_duration = 0
	///timer last start
	var/timer_laststart = 0

/obj/machinery/oven/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/oven/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Set Timer"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/oven/AltClick(mob/user)
	. = ..()
	if(!oven_timer)
		timer_duration = tgui_input_number(user, "How long should the timer be in 10th of a seconds", min_value = 0, max_value = 10000000)
		if(!timer_duration)
			return
		if(!open)
			timer_laststart = world.time
			oven_timer = addtimer(CALLBACK(src, PROC_REF(go_off_queen)), timer_duration, TIMER_UNIQUE | TIMER_STOPPABLE)
	else
		deltimer(oven_timer)
		oven_timer = null

/obj/machinery/oven/proc/go_off_queen()
	timer_duration = 0
	timer_laststart = 0
	oven_timer = null

	playsound(src, 'sound/weapons/gun/general/empty_alarm.ogg', 25)
