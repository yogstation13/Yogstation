/obj/machinery/sci_bombardment
	name = "Lavaland Artillery Mainframe"
	desc = "A machine consisting of Bluespace relays and a targetting mechanism, the L.A.M. tracks signals visible on nearby planetary bodies. Modern advancements to the Bluespace guidance system makes it significantly more accurate than its predecessor, the Lavaland Instantaneous Geotracking Missile Armament.\n"
	icon = 'icons/obj/machines/lam.dmi'
	icon_state = "LAM_Base"
	light_color = LIGHT_COLOR_PINK
	density = TRUE
	verb_say = "states coldly"
	idle_power_usage = 500
	active_power_usage = 10000
	var/countdown = 30
	var/mincount = 15 // Minimum countdown time
	var/target_delay = FALSE
	var/locked = TRUE
	var/loaded = FALSE
	var/stopcount = TRUE
	var/tick = 0
	var/obj/item/radio/radio
	var/obj/item/transfer_valve/scibomb //Right here, JC
	var/radio_freq = FREQ_SCIENCE
	var/turf/dest //target location for the TTV. Does not move with GPS after targetting
	var/tcoords
	var/targetdest = "None" //target name, defaults to N/A after firing.

/obj/machinery/sci_bombardment/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice>You can see that the firing chamber is [scibomb ? "loaded" : "empty"].</span>"
		return

/obj/machinery/sci_bombardment/Initialize()
	. = ..()
	radio = new /obj/item/radio/(src)
	radio.frequency = radio_freq
	update_icon()

/obj/machinery/sci_bombardment/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/sci_bombardment/update_icon()
	cut_overlays()
	if(!powered(power_channel))
		add_overlay("LAM_radar0")
	else
		add_overlay("LAM_screen[dest && !locked && !target_delay ? "Targ" : "Idle"]")
		add_overlay("LAM_radar[target_delay || locked ? "0" : "1"]")
	if(scibomb)
		add_overlay("LAM_hatch")
	return

/obj/machinery/sci_bombardment/attackby(obj/item/transfer_valve/B, mob/user, params)
	if(istype(B, /obj/item/transfer_valve) && B.tank_one && B.tank_two)
		if(!user.transferItemToLoc(B, src))
			return
		if(!loaded)
			scibomb = B
			loaded = TRUE
			playsound(src, 'sound/effects/bin_close.ogg', 100, 1)
			to_chat(usr, "<span class='notice'>You load [B] into the firing mechanism.</span>")
			update_icon()
		else
			to_chat(usr, "<span class='warning'>There is already a transfer valve loaded in the firing mechanism!</span>")
			return
	else
		to_chat(usr, "<span class='warning'>[B] is refused, as it is invalid or incomplete.</span>")
	return

/obj/machinery/sci_bombardment/proc/countdown()
	if(stopcount) //Abort launch
		tick = countdown
		return
	tick -= 1
	if(tick == 0)
		stopcount = TRUE
		tick = countdown
		fire_ttv()
		radio.talk_into(src, "Payload successfully deployed.",)
		use_power = 1
		return
	else if(tick <= 5)
		use_power = 2
		radio.talk_into(src, "[tick]...",)
	playsound(src, 'sound/effects/clock_tick.ogg', 80, 0)
	spawn(10)
		countdown()

/obj/machinery/sci_bombardment/proc/fire_ttv()
	if(!scibomb || !dest)
		return
	playsound(src, 'sound/effects/gravhit.ogg', 80, 0.25)
	playsound(src, 'sound/effects/podwoosh.ogg', 80, 0.25)
	scibomb.forceMove(dest)
	scibomb.toggle_valve()
	dest = initial(dest)
	targetdest = initial(dest)
	tcoords = initial(tcoords)
	scibomb = initial(scibomb)
	loaded = FALSE
	update_icon()
	. = TRUE

/obj/machinery/sci_bombardment/proc/reset_lam() //prevent the spam of targetting coordinates and fake TTV launches
	target_delay = TRUE
	update_icon()
	sleep(100)
	target_delay = FALSE
	update_icon()
	playsound(src, 'sound/items/scanner_match.ogg', 100, 1)
	return
//UI segment


/obj/machinery/sci_bombardment/ui_interact(mob/user, ui_key = "lam", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/lam_window_height = clamp(325 + GLOB.GPS_list.len * 24, 325, 700)
		ui = new(user, src, ui_key, "Lam", name, 470, lam_window_height, master_ui, state)
		ui.open()

/obj/machinery/sci_bombardment/ui_data(mob/user)
	var/list/data = list()
	data["tcoords"] = tcoords
	data["countdown"] = countdown
	data["locked"] = locked
	data["loaded"] = loaded
	data["stopcount"] = stopcount
	if(locked)
		return data
	if(tcoords)
		data["tcoords"] = tcoords
		data["targetdest"] = targetdest

	var/list/signals = list()
	data["signals"] = list()

	for(var/gps in GLOB.GPS_list)
		var/obj/item/gps/G = gps
		var/turf/pos = get_turf_global(G) // yogs - get_turf_global instead of get_turf
		if(pos.z != 5)
			continue
		var/list/signal = list()
		signal["entrytag"] = G.gpstag //GPS name
		signal["coords"] = "[pos.x], [pos.y], [pos.z]"

		signals += list(signal)
	data["signals"] = signals
	return data


/obj/machinery/sci_bombardment/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("lock")
			if(iscyborg(usr) || isAI(usr))
				locked = !locked
				radio.talk_into(src, "Controls [locked ? "locked" : "unlocked"] by [usr].",)
			else 
				var/mob/M = usr
				var/obj/item/card/id/I = M.get_idcard(TRUE)
				if(check_access(I) && 30 in I.access)
					locked = !locked
					radio.talk_into(src, "Controls [locked ? "locked" : "unlocked"] by [I.registered_name].",)
				else
					to_chat(usr, "<span class='warning'>Access denied. Please seek assistance from station AI or Research Director.</span>")
			update_icon()
			. = TRUE
		if("count")
			if(locked)
				return
			var/a = text2num(stripped_input(usr, "Set a new countdown timer. (Minimum [mincount])", name, 15))
			if(a < mincount)
				to_chat(usr, "<span class='warning'>The countdown remains unchanged.</span>")
				return
			countdown = a
			to_chat(usr, "<span class='notice'>Countdown set to [countdown] seconds.</span>")
			. = TRUE
		if("unload")
			if(!loaded || locked)
				return
			if(!stopcount)
				playsound(src, 'sound/misc/box_deploy.ogg', 80, 0.5)
				to_chat(usr, "<span class='warning'>It's too late to do that now! There's only [tick] seconds remaining! Abort!</span>")
				return
			playsound(src, 'sound/machines/blastdoor.ogg', 75, 0)
			to_chat(usr, "<span class='notice'>[scibomb] is ejected from the loading chamber.</span>")
			loaded = FALSE
			scibomb.forceMove(drop_location())
			scibomb = null
			update_icon()
			. = TRUE

		if("launch")
			if(locked || target_delay || !scibomb || !dest)
				return
			stopcount = !stopcount
			if (!stopcount)
				radio.talk_into(src, "Beginning launch on coordinates [tcoords]. ETA: [countdown] seconds.",)
				tick = countdown + 1
				countdown()
			else
				radio.talk_into(src, "Launch sequence aborted by [usr]. Resetting mainframe...",)
				reset_lam()
			. = TRUE
		if("target")
			if(locked || target_delay || !stopcount)
				return
			targetdest = params["targetdest"]
			tcoords = params["tcoords"]
			for(var/gps in GLOB.GPS_list)
				var/obj/item/gps/T = gps
				var/turf/pos = get_turf_global(T) // yogs - get_turf_global instead of get_turf
				if(T.gpstag == targetdest && "[pos.x], [pos.y], [pos.z]" == tcoords)
					dest = get_turf_global(T) // yogs - get_turf_global instead of get_turf
					break
			if(!dest)
				radio.talk_into(src, "ERROR: Telemetry mismatch. Isolation of GPS required before trying again. Resetting mainframe...",)
			radio.talk_into(src, "Target set to [targetdest] at coordinates [tcoords]. [tcoords ? "Resetting mainframe..." : ""]",)
			playsound(src, 'sound/effects/servostep.ogg', 100, 1)
			reset_lam()
			. = TRUE