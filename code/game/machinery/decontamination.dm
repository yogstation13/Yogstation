// DECONTAMINATION STORAGE UNIT!! /////////////////
/obj/machinery/decontamination_unit
	name = "advanced decontamination storage unit"
	desc = "This is a more advanced version of the industrial suit storage unit developed by the NT science and engineering team. It is capable of removing organic radiation as well as contaminated equipment."
	icon = 'icons/obj/machines/decontamination_unit.dmi'
	icon_state = "tube"
	density = TRUE
	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/decontamination_unit
	layer = ABOVE_WINDOW_LAYER
								// if you add more storage slots, update cook() to clear their radiation too.

	var/max_n_of_items = 53

	state_open = FALSE
	var/locked = FALSE
	panel_open = FALSE

	var/uv = FALSE
	var/uv_emagged = FALSE
	var/uv_cycles = 3
	var/message_cooldown
	var/breakout_time = 300

	var/datum/looping_sound/decontamination_unit/decon
	var/datum/looping_sound/decontamination_unit/emagged/decon_emagged

	var/flick_waitTime = 9.5 //Waits for flick animation to complete before opening the door or it will be weird..

/obj/machinery/decontamination_unit/open
	state_open = TRUE
	density = FALSE

/obj/machinery/decontamination_unit/Initialize()
	. = ..()
	decon = new(list(src), FALSE)
	decon_emagged = new(list(src), FALSE)
	update_icon()

/obj/machinery/decontamination_unit/update_icon()
	. = ..()
	icon_state = uv? "tube_on" : (state_open? "tube_open" : "tube")

/obj/machinery/decontamination_unit/proc/store_items()
	var/atom/pickup_zone = drop_location()
	for(var/obj/item/to_pickup in pickup_zone)
		to_pickup.forceMove(src)

/obj/machinery/decontamination_unit/power_change()
	. = ..()
	if(!is_operational() && state_open)
		open_machine()
		dump_mob()
		playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)
	update_icon()

/obj/machinery/decontamination_unit/proc/dump_mob()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		if(isliving(A))
			var/mob/living/L = A
			L.forceMove(T)
			L.update_mobility()
	occupant = null

/obj/machinery/decontamination_unit/MouseDrop_T(atom/A, mob/living/user)
	if(!istype(user) || user.stat || !Adjacent(user) || !Adjacent(A) || !isliving(A))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	var/mob/living/target = A
	if(!state_open)
		to_chat(user, span_warning("The unit's doors are shut!"))
		return
	if(!is_operational())
		to_chat(user, span_warning("The unit is not operational!"))
		return

	if(target == user)
		user.visible_message(span_warning("[user] starts squeezing into [src]!"), span_notice("You start working your way into [src]..."))
	else
		target.visible_message(span_warning("[user] starts shoving [target] into [src]!"), span_userdanger("[user] starts shoving you into [src]!"))

	if(do_mob(user, target, 30))
		if(target == user)
			user.visible_message(span_warning("[user] slips into [src] and closes the door behind [user.p_them()]!"), "<span class=notice'>You slip into [src]'s cramped space and shut its door.</span>")
		else
			target.visible_message("<span class='warning'>[user] pushes [target] into [src] and shuts its door!<span>", span_userdanger("[user] shoves you into [src] and shuts the door!"))
		close_machine(target)
		add_fingerprint(user)

/obj/machinery/decontamination_unit/proc/cook()
	var/mob/living/mob_occupant = occupant
	if(uv_cycles)
		uv_cycles--
		uv = TRUE
		locked = TRUE
		update_icon()
		if(uv_emagged)
			radiation_pulse(src, 500, 5)
			decon_emagged.start()
			if(mob_occupant)
				mob_occupant.adjustFireLoss(rand(15, 26))
				mob_occupant.radiation += 500
				mob_occupant.adjust_fire_stacks(2)
				mob_occupant.IgniteMob()
			if(iscarbon(mob_occupant) && mob_occupant.stat < UNCONSCIOUS)
				//Awake, organic and screaming
				mob_occupant.emote("scream")
		else
			decon.start()
		addtimer(CALLBACK(src, .proc/cook), 50)
	else
		uv_cycles = initial(uv_cycles)
		uv = FALSE
		locked = FALSE
		if(uv_emagged)
			flick("tube_up", src)
			decon_emagged.stop()
			playsound(src, 'sound/machines/decon/decon-up.ogg', 100, TRUE)
			addtimer(CALLBACK(src, .proc/decon_eject_emagged), flick_waitTime)
		else
			flick("tube_up", src)
			decon.stop()
			playsound(src, 'sound/machines/decon/decon-up.ogg', 100, TRUE)
			addtimer(CALLBACK(src, .proc/decon_eject), flick_waitTime)

/obj/machinery/decontamination_unit/proc/decon_eject_emagged()
	var/mob/living/mob_occupant = occupant
	say("ERROR: PLEASE CONTACT SUPPORT!!")
	if(mob_occupant)
		visible_message(span_warning("[src]'s gate creaks open with a loud whining noise, barraging you with the nauseating smell of charred flesh. A cloud of foul smoke escapes from its chamber."))
		mob_occupant.electrocute_act(50, src)
	else
		visible_message(span_warning("[src]'s gate creaks open with a loud whining noise."))
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
	for(var/obj/item/item in contents)	
		QDEL_NULL(item)
	shock()
	open_machine(0)
	if(occupant)
		dump_mob()

/obj/machinery/decontamination_unit/proc/decon_eject()
	var/mob/living/mob_occupant = occupant
	say("The decontamination process is completed, thank you for your patient.")
	playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)
	if(mob_occupant)
		visible_message(span_notice("[src]'s gate slides open, ejecting you out."))
		mob_occupant.radiation = 0
	else
		visible_message(span_notice("[src]'s gate slides open. The glowing yellow lights dim to a gentle green."))
	var/list/things_to_clear = list() //Done this way since using GetAllContents on the SSU itself would include circuitry and such.
	if(occupant)
		things_to_clear += occupant
		things_to_clear += occupant.GetAllContents()
		dump_mob()
	if(contents.len)
		things_to_clear += contents
	for(var/am in things_to_clear) //Scorches away blood and forensic evidence, although the SSU itself is unaffected
		var/atom/movable/dirty_movable = am
		dirty_movable.wash(CLEAN_ALL)
	open_machine(0)

/obj/machinery/decontamination_unit/proc/shock(mob/user)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	electrocute_mob(user, src, src, 1, TRUE)

/obj/machinery/decontamination_unit/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("[src] has no functional safeties to emag."))
		return
	if(!state_open)
		if(!panel_open)
			to_chat(user, span_warning("Open the panel first."))
			return
	else
		return
	to_chat(user, span_warning("You short out [src]'s safeties."))
	uv_emagged = TRUE
	obj_flags |= EMAGGED

/obj/machinery/decontamination_unit/relaymove(mob/user)
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	open_machine()
	dump_mob()
	playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)

/obj/machinery/decontamination_unit/proc/reset_emag(mob/user)
	if(panel_open)
		if(obj_flags & EMAGGED)
			to_chat(user, span_warning("Resetting circuitry..."))
			if(do_after(user, 6 SECONDS, src))
				to_chat(user, span_caution("You reset the [src]'s safeties."))
				uv_emagged = FALSE
				obj_flags -= EMAGGED
		else
			to_chat(user, span_notice("The [src] is in normal state."))
			return
	else
		to_chat(user, span_warning("Open the panel first."))
		return

/obj/machinery/decontamination_unit/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		dump_mob()
		playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)
		return
	if(uv)
		visible_message(span_notice("You hear someone kicking against the doors of [src]!"), \
			span_notice("You cannot escape while it's active!"))
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You hear someone kicking against the doors of [src]!"), \
		span_notice("You start kicking against the doors... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_italics("You hear a thump from [src]."))
	if(do_after(user, (breakout_time), src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
			span_notice("You successfully break out of [src]!"))
		open_machine()
		dump_mob()
		playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)

	add_fingerprint(user)
	if(locked)
		visible_message(span_notice("You hear someone kicking against the doors of [src]!"), \
			span_notice("You start kicking against the doors..."))
		addtimer(CALLBACK(src, .proc/resist_open, user), 300)
	else
		open_machine()
		dump_mob()
		playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)

/obj/machinery/decontamination_unit/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = initial(max_n_of_items) * B.rating

/obj/machinery/decontamination_unit/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += span_warning("Its maintenance panel is smoking slightly.")
	if(in_range(user, src) || isobserver(user))
		if (contents.len >= max_n_of_items)
			. += span_notice("The status display reads: <b>Inventory full!</b> Please remove items or upgrade the parts of this storage unit.")
		else
			. += span_notice("The status display reads: Inventory quantity is currently <b>[contents.len] out of [max_n_of_items]</b> items.")

/obj/machinery/decontamination_unit/proc/resist_open(mob/user)
	if(!state_open && !uv && occupant && (user in src) && user.stat == 0) // Check they're still here.
		visible_message(span_notice("You see [user] burst out of [src]!"), \
			span_notice("You escape the cramped confines of [src]!"))
		open_machine()
		playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)

/obj/machinery/decontamination_unit/is_operational()
	return ..() && anchored

/obj/machinery/decontamination_unit/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(I.tool_behaviour == TOOL_MULTITOOL)
		reset_emag(user)
		return

	if(state_open && is_operational())
		//Unable to add an item, it's already full.
		if(contents.len >= max_n_of_items)
			to_chat(user, span_warning("\The [src] is full!"))
			return FALSE

		if(!(istype(I, /obj/item/storage/bag)))
			load(I)
			updateUsrDialog()

		//Adding items from a bag
		else
			var/loaded = 0
			for(var/obj/G in I.contents)
				if(contents.len >= max_n_of_items)
					break
				load(G)
				loaded++
			updateUsrDialog()

			if(loaded)
				if(contents.len >= max_n_of_items)
					user.visible_message("[user] loads \the [src] with \the [I].", \
									 span_notice("You fill \the [src] with \the [I]."))
				else
					user.visible_message("[user] loads \the [src] with \the [I].", \
										 span_notice("You load \the [src] with \the [I]."))
				if(I.contents.len > 0)
					to_chat(user, span_warning("Some items are refused."))
				return TRUE
			else
				to_chat(user, span_warning("There is nothing in [I] to put in [src]!"))
				return FALSE

		visible_message(span_notice("[user] inserts [I] into [src]."), span_notice("You load [I] into [src]."))
		update_icon()
		return

	if(!state_open && !uv)
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			panel_open = !panel_open
			user.visible_message(span_notice("\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src]."), span_notice("You [panel_open ? "open" : "close"] the hatch on \the [src]."))
			I.play_tool_sound(src, 50)
			return
		if(default_deconstruction_crowbar(I))
			return
	if(default_pry_open(I))
		dump_mob()
		return

	return ..()

/obj/machinery/decontamination_unit/default_pry_open(obj/item/I)//needs to check if the storage is locked.
	. = !(state_open || panel_open || is_operational() || locked) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open \the [src]."), span_notice("You pry open \the [src]."))
		open_machine()
		playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)

/obj/machinery/decontamination_unit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Decon", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/decontamination_unit/ui_data()
	var/list/data = list()
	data["locked"] = locked
	data["open"] = state_open
	data["uv_active"] = uv

	var/listofitems = list()
	for (var/I in src)
		var/atom/movable/O = I
		if (!QDELETED(O))
			var/md5name = md5(O.name)
			if (listofitems[md5name])
				listofitems[md5name]["amount"]++
			else
				listofitems[md5name] = list("name" = O.name, "type" = O.type, "amount" = 1)
	sortList(listofitems)

	data["contents"] = listofitems
	data["name"] = name
	if(occupant)
		data["occupied"] = TRUE
	else
		data["occupied"] = FALSE
	return data

/obj/machinery/decontamination_unit/ui_act(action, params)
	if(..() || uv)
		return

	if (!anchored)
		return
	switch(action)
		if("door")
			if(state_open)
				close_machine()
				store_items()
				playsound(src, 'sound/machines/decon/decon-close.ogg', 50, TRUE)
			else
				open_machine(0)
				playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)
				if(occupant)
					dump_mob()
			. = TRUE
		if("lock")
			if(state_open)
				return
			locked = !locked
			. = TRUE
		if("uv")
			var/mob/living/mob_occupant = occupant
			if(!occupant && !contents.len)
				return
			else 
				if(uv_emagged)
					say("ERROR: Decontamination process is going over safety limit!!")
					uv_cycles = 7
				else
					say("Please wait untill the decontamination process is completed.")
					uv_cycles = initial(uv_cycles)
				if(mob_occupant && uv_emagged)
					to_chat(mob_occupant, span_userdanger("[src]'s confines grow warm, then hot, then scorching. You're being burned [!mob_occupant.stat ? "alive" : "away"]!"))
				else
					to_chat(mob_occupant, span_warning("[src]'s confines grow warm. You're being decontaminated."))
				flick("tube_down", src)
				cook()
				. = TRUE
		if("Release")
			var/desired = 0

			if (params["amount"])
				desired = text2num(params["amount"])
			else
				desired = input("How many items?", "How many items would you like to take out?", 1) as null|num

			if(desired <= 0)
				return FALSE

			if(QDELETED(src) || QDELETED(usr) || !usr.Adjacent(src)) // Sanity checkin' in case stupid stuff happens while we wait for input()
				return FALSE

			//Retrieving a single item into your hand
			if(desired == 1 && Adjacent(usr) && !issilicon(usr))
				for(var/obj/item/O in src)
					var/check_name1 = replacetext(O.name,"\improper","")
					var/check_name2 = replacetext(O.name,"\proper","")
					if((check_name1 == params["name"]) || (check_name2 == params["name"]))
						dispense(O, usr)
						break
				return TRUE

			//Retrieving many items
			for(var/obj/item/O in src)
				if(desired <= 0)
					break
				var/check_name1 = replacetext(O.name,"\improper","")
				var/check_name2 = replacetext(O.name,"\proper","")
				if((check_name1 == params["name"]) || (check_name2 == params["name"]))
					dispense(O, usr)
					desired--
			return TRUE
	update_icon()

/obj/machinery/decontamination_unit/proc/load(obj/item/O)
	if(ismob(O.loc))
		var/mob/M = O.loc
		if(!M.transferItemToLoc(O, src))
			to_chat(usr, span_warning("\The [O] is stuck to your hand, you cannot put it in \the [src]!"))
			return FALSE
		else
			return TRUE
	else
		if(SEND_SIGNAL(O.loc, COMSIG_CONTAINS_STORAGE))
			return SEND_SIGNAL(O.loc, COMSIG_TRY_STORAGE_TAKE, O, src)
		else
			O.forceMove(src)
			return TRUE

/obj/machinery/decontamination_unit/proc/dispense(obj/item/O, var/mob/M)
	if(!M.put_in_hands(O))
		O.forceMove(get_turf(M))
		adjust_item_drop_location(O)

/obj/machinery/decontamination_unit/handle_atom_del(atom/A) // Update the UIs in case something inside gets deleted
	SStgui.update_uis(src)

/obj/machinery/decontamination_unit/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(panel_open)
		to_chat(user, span_warning("Close the panel first!"))
		return
	if(uv)
		to_chat(user, span_warning("You cannot open the gate while the cycle is running!"))
		return
	if(state_open)
		close_machine()
		store_items()
		playsound(src, 'sound/machines/decon/decon-close.ogg', 75, TRUE)
	else
		open_machine(0)
		playsound(src, 'sound/machines/decon/decon-open.ogg', 75, TRUE)
		if(occupant)
			dump_mob()

/obj/machinery/decontamination_unit/CtrlShiftClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || state_open)
		return
	locked = !locked
	update_icon()
