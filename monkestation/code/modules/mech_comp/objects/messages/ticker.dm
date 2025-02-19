/obj/item/mcobject/messaging/ticker
	name = "ticker component"
	base_icon_state = "comp_arith"
	icon_state = "comp_arith"

	var/interval = 1 SECONDS
	///Store the number of loops we want seperately.
	var/total_loops = -1
	var/loops = -1
	var/on = FALSE
	/// Cooldown for when the next loop fires.
	COOLDOWN_DECLARE(next_loop)

/obj/item/mcobject/messaging/ticker/Initialize(mapload)
	. = ..()
	MC_ADD_CONFIG("Set Interval", set_interval)
	MC_ADD_CONFIG("Set Loop Counter", set_loops)
	MC_ADD_INPUT("Start Ticker", start_ticker)
	MC_ADD_INPUT("Stop Ticker", stop_ticker)
	MC_ADD_INPUT("Toggle Ticker", toggle_ticker)

/obj/item/mcobject/messaging/ticker/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/mcobject/messaging/ticker/examine(mob/user)
	. = ..()
	. += span_notice("It is currently [on ? "on" : "off"].")
	. += span_notice("Interval time: [DisplayTimeText(interval)].")
	. += span_notice("Total loops: [total_loops == -1 ? "infinite" : total_loops].")

/obj/item/mcobject/messaging/ticker/process()
	if(QDELETED(src) || !on || (total_loops != -1 && loops <= 0) || !COOLDOWN_FINISHED(src, next_loop))
		return PROCESS_KILL
	fire(stored_message)
	loops--
	COOLDOWN_START(src, next_loop, interval)

/obj/item/mcobject/messaging/ticker/proc/set_interval(mob/user, obj/item/tool)
	var/num = tgui_input_number(
		user,
		message = "Set interval in seconds (0.5 - 60)",
		title = "Configure Component",
		default = interval * 0.1,
		max_value = 60,
		min_value = 0.5,
		round_value = FALSE
	)
	if(!num)
		return

	interval = round(clamp(num, 0.5, 60) SECONDS, world.tick_lag)
	to_chat(user, "You set [src]'s interval to [DisplayTimeText(interval)].")
	return TRUE

/obj/item/mcobject/messaging/ticker/proc/set_loops(mob/user, obj/item/tool)
	var/num = tgui_input_number(
		user,
		message = "Set number of loops (-1 for infinite)",
		title = "Configure Component",
		default = total_loops,
		max_value = 100,
		min_value = -1
	)
	if(isnull(num))
		return

	total_loops = clamp(num, -1, 100)
	to_chat(user, "You set [src]'s loop count to [total_loops == -1 ? "infinite" : "[total_loops]"].")
	return TRUE

/obj/item/mcobject/messaging/ticker/proc/start_ticker(datum/mcmessage/input)
	if(on)
		return
	on = TRUE
	loops = total_loops
	START_PROCESSING(SSfastprocess, src)
	balloon_alert_to_viewers("started ticking")

/obj/item/mcobject/messaging/ticker/proc/stop_ticker(datum/mcmessage/input)
	if(!on)
		return
	STOP_PROCESSING(SSfastprocess, src)
	on = FALSE
	loops = 0
	balloon_alert_to_viewers("stopped ticking")

/obj/item/mcobject/messaging/ticker/proc/toggle_ticker(datum/mcmessage/input)
	if(on)
		stop_ticker(input)
	else
		start_ticker(input)
