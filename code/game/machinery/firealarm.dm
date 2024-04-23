#define FIREALARM_COOLDOWN 67 // Chosen fairly arbitrarily, it is the length of the audio in FireAlarm.ogg. The actual track length is 7 seconds 8ms but but the audio stops at 6s 700ms

/obj/item/electronics/firealarm
	name = "fire alarm electronics"
	custom_price = 5
	desc = "A fire alarm circuit. Can handle heat levels up to 40 degrees celsius."

/obj/item/wallframe/firealarm
	name = "fire alarm frame"
	desc = "Used for building fire alarms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	result_path = /obj/machinery/firealarm

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	max_integrity = 250
	integrity_failure = 100
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 100, FIRE = 90, ACID = 30)
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = AREA_USAGE_ENVIRON
	resistance_flags = FIRE_PROOF

	light_power = 1
	light_range = 1.6
	light_color = "#ff3232"
	//Trick to get the glowing overlay visible from a distance
	luminosity = 1

	/// 1 = will auto detect fire, 0 = no auto
	var/detecting = 1
	/// 2 = complete, 1 = no wires, 0 = circuit gone
	var/buildstage = 2
	/// Cooldown for next alarm trigger, so it doesnt spam much
	var/last_alarm = 0
	/// The area of the current fire alarm
	var/area/myarea = null
	/// If true, then this area has a real fire and not by someone triggering it manually
	var/real_fire = FALSE
	/// If real_fire is true then it will show you the current hot temperature
	var/bad_temp = null
	/// The radio to alert engineers, atmos techs
	var/obj/item/radio/radio

/obj/machinery/firealarm/Initialize(mapload, dir, building)
	. = ..()
	if(dir)
		src.setDir(dir)
	if(building)
		buildstage = 0
		panel_open = TRUE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
	update_appearance()
	myarea = get_area(src)
	LAZYADD(myarea.firealarms, src)
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_eng()
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()
	STOP_PROCESSING(SSmachines, src) // I will do this

	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(update_security_level))

/obj/machinery/firealarm/Destroy()
	myarea.firereset(src, TRUE)
	QDEL_NULL(radio)
	LAZYREMOVE(myarea.firealarms, src)
	return ..()

/obj/machinery/firealarm/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "fire_b[buildstage]"
		return
	if(stat & BROKEN)
		icon_state = "firex"
		return
	icon_state = "fire0"

/obj/machinery/firealarm/proc/update_security_level()
	if(is_station_level(z))
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/firealarm/update_overlays()
	. = ..()
	if(stat & (NOPOWER|BROKEN))
		return

	if(is_station_level(z))
		var/current_level = SSsecurity_level.get_current_level_as_number()
		. += mutable_appearance(icon, "fire_[current_level]")
		. += emissive_appearance(icon, "fire_[current_level]", src)
		switch(current_level)
			if(SEC_LEVEL_GREEN)
				set_light(l_color = LIGHT_COLOR_BLUEGREEN)
			if(SEC_LEVEL_BLUE)
				set_light(l_color = LIGHT_COLOR_ELECTRIC_CYAN)
			if(SEC_LEVEL_RED)
				set_light(l_color = LIGHT_COLOR_FLARE)
			if(SEC_LEVEL_DELTA)
				set_light(l_color = LIGHT_COLOR_INTENSE_RED)
	else
		. += mutable_appearance(icon, "fire_[SEC_LEVEL_GREEN]")
		. += emissive_appearance(icon, "fire_[SEC_LEVEL_GREEN]", src)
		set_light(l_color = LIGHT_COLOR_BLUE)

	var/area/A = src.loc
	A = A.loc

	if(!A.fire && !A.delta_light)
		. += mutable_appearance(icon, "fire_off")
		. += emissive_appearance(icon, "fire_off", src)
	else if(obj_flags & EMAGGED)
		. += mutable_appearance(icon, "fire_emagged")
		. += emissive_appearance(icon, "fire_emagged", src)
		set_light(l_color = LIGHT_COLOR_RED)
	else
		. += mutable_appearance(icon, "fire_on")
		. += emissive_appearance(icon, "fire_on", src)
		set_light(l_color = LIGHT_COLOR_RED)

/obj/machinery/firealarm/emp_act(severity)
	. = ..()

	if (. & EMP_PROTECT_SELF)
		return

	if(prob(5 * severity))
		alarm()

/obj/machinery/firealarm/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	update_appearance()
	if(user)
		user.visible_message(span_warning("Sparks fly out of [src]!"),
							span_notice("You emag [src], disabling its thermal sensors."))
	playsound(src, "sparks", 50, 1)
	return TRUE

/obj/machinery/firealarm/examine(mob/user)
	. = ..()
	if(areafire_check())
		. += span_danger("Fire detected in this area, current fire alarm temperature: [bad_temp-T0C]C")
	else
		. += span_notice("There's no fire detected.")

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	var/turf/open/T = get_turf(src)
	if((temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST || temperature < BODYTEMP_COLD_DAMAGE_LIMIT || (istype(T) && T.turf_fire)) && (last_alarm+FIREALARM_COOLDOWN < world.time) && !(obj_flags & EMAGGED) && detecting && !stat)
		if(!real_fire)
			radio.talk_into(src, "Fire detected in [myarea].", RADIO_CHANNEL_ENGINEERING)
		real_fire = TRUE
		bad_temp = temperature
		alarm()
		START_PROCESSING(SSmachines, src)
	..()

/obj/machinery/firealarm/process() //Fire alarm only start processing when its triggered by temperature_expose()
	var/turf/open/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(env.return_temperature() < FIRE_MINIMUM_TEMPERATURE_TO_EXIST && env.return_temperature() > BODYTEMP_COLD_DAMAGE_LIMIT && (istype(T) && !T.turf_fire))
		real_fire = FALSE
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/firealarm/proc/areafire_check()
	for(var/obj/machinery/firealarm/FA in myarea.firealarms)
		if(FA.real_fire)
			return TRUE
	return FALSE

/obj/machinery/firealarm/proc/alarm(mob/user)
	if(!is_operational() || (last_alarm+FIREALARM_COOLDOWN > world.time))
		return
	last_alarm = world.time
	myarea.firealert(src)
	playsound(loc, 'goon/sound/machinery/FireAlarm.ogg', 75)
	if(user)
		log_game("[user] triggered a fire alarm at [COORD(src)]")

/obj/machinery/firealarm/proc/reset(mob/user)
	if(!is_operational())
		return
	for(var/obj/machinery/firealarm/F in myarea.firealarms)
		F.myarea.firereset(F)
		F.bad_temp = null
	if(user)
		log_game("[user] reset a fire alarm at [COORD(src)]")

/obj/machinery/firealarm/attack_hand(mob/user)
	if(buildstage != 2)
		return ..()
	add_fingerprint(user)
	play_click_sound("button")
	if(myarea.fire || myarea.party)
		reset(user)
	else
		alarm(user)

/obj/machinery/firealarm/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/firealarm/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/firealarm/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(W.tool_behaviour == TOOL_SCREWDRIVER && buildstage == 2)
		W.play_tool_sound(src)
		panel_open = !panel_open
		to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]."))
		update_appearance()
		return

	if(panel_open)

		if(W.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
			if(atom_integrity < max_integrity)
				if(!W.tool_start_check(user, amount=0))
					return

				to_chat(user, span_notice("You begin repairing [src]..."))
				if(W.use_tool(src, user, 40, volume=50))
					update_integrity(max_integrity)
					to_chat(user, span_notice("You repair [src]."))
			else
				to_chat(user, span_warning("[src] is already in good condition!"))
			return

		switch(buildstage)
			if(2)
				if(W.tool_behaviour == TOOL_MULTITOOL)
					detecting = !detecting
					if (src.detecting)
						user.visible_message("[user] has reconnected [src]'s detecting unit!", span_notice("You reconnect [src]'s detecting unit."))
					else
						user.visible_message("[user] has disconnected [src]'s detecting unit!", span_notice("You disconnect [src]'s detecting unit."))
					return

				else if(W.tool_behaviour == TOOL_WIRECUTTER)
					buildstage = 1
					W.play_tool_sound(src)
					new /obj/item/stack/cable_coil(user.loc, 5)
					to_chat(user, span_notice("You cut the wires from \the [src]."))
					update_appearance()
					return

				else if(W.force) //hit and turn it on
					..()
					if(!myarea.fire)
						alarm()
					return

			if(1)
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/coil = W
					if(coil.get_amount() < 5)
						to_chat(user, span_warning("You need more cable for this!"))
					else
						coil.use(5)
						buildstage = 2
						to_chat(user, span_notice("You wire \the [src]."))
						update_appearance()
					return

				else if(W.tool_behaviour == TOOL_CROWBAR)
					user.visible_message("[user.name] removes the electronics from [src.name].", \
										span_notice("You start prying out the circuit..."))
					if(W.use_tool(src, user, 20, volume=50))
						if(buildstage == 1)
							if(stat & BROKEN)
								to_chat(user, span_notice("You remove the destroyed circuit."))
								stat &= ~BROKEN
							else
								to_chat(user, span_notice("You pry out the circuit."))
								new /obj/item/electronics/firealarm(user.loc)
							buildstage = 0
							update_appearance()
					return
			if(0)
				if(istype(W, /obj/item/electronics/firealarm))
					to_chat(user, span_notice("You insert the circuit."))
					qdel(W)
					buildstage = 1
					update_appearance()
					return

				else if(istype(W, /obj/item/electroadaptive_pseudocircuit))
					var/obj/item/electroadaptive_pseudocircuit/P = W
					if(!P.adapt_circuit(user, 15))
						return
					user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
					span_notice("You adapt a fire alarm circuit and slot it into the assembly."))
					buildstage = 1
					update_appearance()
					return

				else if(W.tool_behaviour == TOOL_WRENCH)
					user.visible_message("[user] removes the fire alarm assembly from the wall.", \
										 span_notice("You remove the fire alarm assembly from the wall."))
					var/obj/item/wallframe/firealarm/frame = new /obj/item/wallframe/firealarm()
					frame.forceMove(user.drop_location())
					W.play_tool_sound(src)
					qdel(src)
					return

	return ..()


/obj/machinery/firealarm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((buildstage == 0) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)	
	return FALSE

/obj/machinery/firealarm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
			span_notice("You adapt a fire alarm circuit and slot it into the assembly."))
			buildstage = 1
			update_appearance()
			return TRUE
	return FALSE

/obj/machinery/firealarm/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(.) //damage received
		if(atom_integrity > 0 && !(stat & BROKEN) && buildstage != 0)
			if(prob(33))
				alarm()

/obj/machinery/firealarm/singularity_pull(S, current_size)
	if (current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects, the fire alarm experiences integrity failure
		deconstruct()
	..()

/obj/machinery/firealarm/atom_break(damage_flag)
	if(buildstage == 0) //can't break the electronics if there isn't any inside.
		return

	. = ..()
	if(.)
		myarea.firereset(src, TRUE)
		LAZYREMOVE(myarea.firealarms, src)

/obj/machinery/firealarm/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 1)
		if(!(stat & BROKEN))
			var/obj/item/I = new /obj/item/electronics/firealarm(loc)
			if(!disassembled)
				I.update_integrity(I.max_integrity * 0.5)
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

/obj/machinery/firealarm/proc/update_fire_light(fire)
	if(fire == !!light_power)
		return  // do nothing if we're already active
	if(fire)
		set_light(l_power = 3)
		update_appearance()
	else
		set_light(l_power = 1)
		update_appearance()

/*
 * Return of the Return of the Party button
 */

/area
	var/party = FALSE

/obj/machinery/firealarm/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"
	var/static/party_overlay

/obj/machinery/firealarm/partyalarm/reset()
	if (stat & (NOPOWER|BROKEN))
		return
	if (!myarea || !myarea.party)
		return
	myarea.party = FALSE
	myarea.cut_overlay(party_overlay)

/obj/machinery/firealarm/partyalarm/alarm()
	if (stat & (NOPOWER|BROKEN))
		return
	if (!myarea || myarea.party || istype(myarea, /area/space))
		return
	myarea.party = TRUE
	if (!party_overlay)
		party_overlay = iconstate2appearance('icons/turf/areas.dmi', "party")
	myarea.add_overlay(party_overlay)
