// SUIT STORAGE DECONTAMINATION UNIT!! /////////////////
/obj/machinery/decontamination_unit
	name = "advanced decontamination unit"
	desc = "This is a more advanced version of the industrial suit storage unit developed by the NT science and engineering team. It is capable of removing organic radiation as well as contaminated equipment."
	icon = 'icons/obj/machines/decontamination_unit.dmi'
	icon_state = "tube"
	density = TRUE
	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/decontamination_unit
	layer = ABOVE_WINDOW_LAYER

	var/obj/item/clothing/suit/space/suit = null
	var/obj/item/clothing/head/helmet/space/helmet = null
	var/obj/item/clothing/mask/mask = null
	var/obj/item/storage = null
								// if you add more storage slots, update cook() to clear their radiation too.

	var/suit_type = null
	var/helmet_type = null
	var/mask_type = null
	var/storage_type = null
	var/list/container = list()

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

/obj/machinery/decontamination_unit/open
	state_open = TRUE
	density = FALSE

/obj/machinery/decontamination_unit/Initialize()
	. = ..()
	decon = new(list(src), FALSE)
	decon_emagged = new(list(src), FALSE)
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(storage_type)
		storage = new storage_type(src)
	update_icon()

/obj/machinery/decontamination_unit/Destroy()
	QDEL_NULL(suit)
	QDEL_NULL(helmet)
	QDEL_NULL(mask)
	QDEL_NULL(storage)
	QDEL_NULL(container)
	return ..()

/obj/machinery/decontamination_unit/update_icon()
	. = ..()
	icon_state = uv? "tube_on" : (state_open? "tube_open" : "tube")

/obj/machinery/decontamination_unit/proc/store_items()
	var/atom/pickup_zone = drop_location()
	for(var/obj/item/to_pickup in pickup_zone)
		to_pickup.forceMove(src)
		container += to_pickup

/obj/machinery/decontamination_unit/power_change()
	. = ..()
	if(!is_operational() && state_open)
		open_machine()
		dump_contents()
	update_icon()

/obj/machinery/decontamination_unit/proc/dump_contents()
	dropContents()
	helmet = null
	suit = null
	mask = null
	storage = null
	occupant = null
	container = list()

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
	if(occupant || helmet || suit || storage)
		to_chat(user, span_warning("It's too cluttered inside to fit in!"))
		return

	if(target == user)
		user.visible_message(span_warning("[user] starts squeezing into [src]!"), span_notice("You start working your way into [src]..."))
	else
		target.visible_message(span_warning("[user] starts shoving [target] into [src]!"), span_userdanger("[user] starts shoving you into [src]!"))

	if(do_mob(user, target, 30))
		if(occupant || helmet || suit || storage)
			return
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
			sleep(8)
			say("ERROR: PLEASE CONTACT SUPPORT!!")
			if(mob_occupant)
				visible_message(span_warning("[src]'s gate creaks open with a loud whining noise, barraging you with the nauseating smell of charred flesh. A cloud of foul smoke escapes from its chamber."))
				mob_occupant.electrocute_act(50, src)
			else
				visible_message(span_warning("[src]'s gate creaks open with a loud whining noise."))
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
			QDEL_NULL(helmet)
			QDEL_NULL(suit)
			QDEL_NULL(mask)
			QDEL_NULL(storage)
			for(var/obj/item/item in container)	
				QDEL_NULL(item)
			shock()
		else
			flick("tube_up", src)
			decon.stop()
			playsound(src, 'sound/machines/decon/decon-up.ogg', 100, TRUE)
			sleep(8)
			say("The decontamination process is completed, thank you for your patient.")
			playsound(src, 'sound/machines/decon/decon-open.ogg', 50, TRUE)
			if(mob_occupant)
				visible_message(span_notice("[src]'s gate slides open, ejecting you out."))
				mob_occupant.radiation = 0
			else
				visible_message(span_notice("[src]'s gate slides open. The glowing yellow lights dim to a gentle green."))
			var/list/things_to_clear = list() //Done this way since using GetAllContents on the SSU itself would include circuitry and such.
			if(suit)
				things_to_clear += suit
				things_to_clear += suit.GetAllContents()
			if(helmet)
				things_to_clear += helmet
				things_to_clear += helmet.GetAllContents()
			if(mask)
				things_to_clear += mask
				things_to_clear += mask.GetAllContents()
			if(storage)
				things_to_clear += storage
				things_to_clear += storage.GetAllContents()
			if(occupant)
				things_to_clear += occupant
				things_to_clear += occupant.GetAllContents()
			if(container.len)
				things_to_clear += container
			for(var/am in things_to_clear) //Scorches away blood and forensic evidence, although the SSU itself is unaffected
				var/atom/movable/dirty_movable = am
				dirty_movable.wash(CLEAN_ALL)
		open_machine(0)
		if(occupant || container.len)
			dump_contents()

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
	dump_contents()

/obj/machinery/decontamination_unit/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user, W))
		return
	if(W.tool_behaviour == TOOL_MULTITOOL)
		reset_emag(user)
		return
	return ..()

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
		dump_contents()
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
		dump_contents()

	add_fingerprint(user)
	if(locked)
		visible_message(span_notice("You hear someone kicking against the doors of [src]!"), \
			span_notice("You start kicking against the doors..."))
		addtimer(CALLBACK(src, .proc/resist_open, user), 300)
	else
		open_machine()
		dump_contents()

/obj/machinery/decontamination_unit/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += span_warning("Its maintenance panel is smoking slightly.")

/obj/machinery/decontamination_unit/proc/resist_open(mob/user)
	if(!state_open && !uv && occupant && (user in src) && user.stat == 0) // Check they're still here.
		visible_message(span_notice("You see [user] burst out of [src]!"), \
			span_notice("You escape the cramped confines of [src]!"))
		open_machine()

/obj/machinery/decontamination_unit/attackby(obj/item/I, mob/user, params)
	if(state_open && is_operational())
		if(istype(I, /obj/item/clothing/suit))
			if(suit)
				to_chat(user, span_warning("The unit already contains a suit!."))
				return
			if(!user.transferItemToLoc(I, src))
				return
			suit = I
		else if(istype(I, /obj/item/clothing/head))
			if(helmet)
				to_chat(user, span_warning("The unit already contains a helmet!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			helmet = I
		else if(istype(I, /obj/item/clothing/mask))
			if(mask)
				to_chat(user, span_warning("The unit already contains a mask!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			mask = I
		else
			if(storage)
				to_chat(user, span_warning("The auxiliary storage compartment is full!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			storage = I

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
		dump_contents()
		return

	return ..()

/obj/machinery/decontamination_unit/default_pry_open(obj/item/I)//needs to check if the storage is locked.
	. = !(state_open || panel_open || is_operational() || locked) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open \the [src]."), span_notice("You pry open \the [src]."))
		open_machine()

/obj/machinery/decontamination_unit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SuitStorageUnit", name)
		ui.open()

/obj/machinery/decontamination_unit/ui_data()
	var/list/data = list()
	data["locked"] = locked
	data["open"] = state_open
	data["uv_active"] = uv
	if(helmet)
		data["helmet"] = helmet.name
	else
		data["helmet"] = null
	if(suit)
		data["suit"] = suit.name
	else
		data["suit"] = null
	if(mask)
		data["mask"] = mask.name
	else
		data["mask"] = null
	if(storage)
		data["storage"] = storage.name
	else
		data["storage"] = null
	if(occupant)
		data["occupied"] = TRUE
	else
		data["occupied"] = FALSE
	return data

/obj/machinery/decontamination_unit/ui_act(action, params)
	if(..() || uv)
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
				if(occupant || container.len)
					dump_contents() // Dump out contents if someone is in there.
			. = TRUE
		if("lock")
			if(state_open)
				return
			locked = !locked
			. = TRUE
		if("uv")
			var/mob/living/mob_occupant = occupant
			if(!helmet && !mask && !suit && !storage && !occupant && !container.len)
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
		if("dispense")
			if(!state_open)
				return

			var/static/list/valid_items = list("helmet", "suit", "mask", "storage")
			var/item_name = params["item"]
			if(item_name in valid_items)
				var/obj/item/I = vars[item_name]
				vars[item_name] = null
				if(I)
					I.forceMove(loc)
			. = TRUE
	update_icon()

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
		if(occupant || container.len)
			dump_contents() // Dump out contents if someone is in there.

/obj/machinery/decontamination_unit/CtrlShiftClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || state_open)
		return
	locked = !locked
	update_icon()
