/obj/machinery/recharge_station
	name = "cyborg recharging station"
	desc = "This device recharges cyborgs and resupplies them with materials."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 1000
	req_access = list(ACCESS_ROBO_CONTROL)
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/cyborgrecharger
	occupant_typecache = list(/mob/living/silicon/robot, /mob/living/carbon/human)
	var/recharge_speed
	var/repairs
	/// Is there a occupant waiting to be borged?
	var/borging = FALSE
	/// Is there a occupant actively getting borged?
	var/borging_active = FALSE
	// The countdown in which the borging process will officially begin.
	COOLDOWN_DECLARE(borg_countdown)
	/// How many seconds does 'borg_countdown' start at?
	var/borging_time = 30 SECONDS
	/// How many seconds does it take to break out of borging process if left uninterpreted?
	var/breakout_time = 4 SECONDS

/obj/machinery/recharge_station/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	repairs = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/stock_parts/cell/C in component_parts)
		recharge_speed *= C.maxcharge / 10000

/obj/machinery/recharge_station/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	playsound(src, "sparks", 75, TRUE, -1)
	to_chat(user, span_notice("You use the cryptographic sequencer on [src] causing a well-hidden panel to open."))
	
/obj/machinery/recharge_station/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Recharging <b>[recharge_speed]J</b> per cycle.")
		if(repairs)
			. += span_notice("[src] has been upgraded to support automatic repairs.")
		if(obj_flags & EMAGGED)
			if(borging)
				if(COOLDOWN_FINISHED(src, borg_countdown))
					. += span_danger("A full loading bar appears: \"NOW CONVERTING.\"")
				else
					var/timeleft = round(COOLDOWN_TIMELEFT(src, borg_countdown))/10
					. += span_danger("A incomplete loading bar appears: \"Beginning in... [timeleft] [timeleft > 1 ? "seconds" : "second"].\"")
			else
				. += span_notice("A hidden button labeled \"CONVERT\" is visible near the bottom of it.")

/obj/machinery/recharge_station/AltClick(mob/user)
	if(user == occupant || !Adjacent(user))
		return ..()
	if(obj_flags & EMAGGED)
		if(issilicon(user)) // Would of been an effective replacement of the Robotic Factory if not for this.
			to_chat(user, span_notice("You can't press the button with your hands - since you don't have any."))
			return
		if(!occupant)	
			to_chat(user, span_notice("There is no one inside [src] to use it on."))
			return
		if(!borging)
			if(do_after(user, 2 SECONDS, src)) // To prevent instant use.
				visible_message(span_notice("[user] press a button on the [src]!"), span_notice("You press a button on the [src].") ) // To indicate that they tried something (evil).
				if(!can_borg())
					visible_message(span_danger("[src] buzzes."))
					playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
					return
				borging = TRUE
				COOLDOWN_START(src, borg_countdown, borging_time)
				visible_message(span_danger("[src] omniously hums."))
		return
	return ..()

/// Checks if the occupant can be borged.
/obj/machinery/recharge_station/proc/can_borg()
	if(!occupant || issilicon(occupant))
		return FALSE
	var/mob/living/carbon/human/human = occupant
	if(!human)
		return FALSE
	if(human.stat == DEAD) // No, you cannot go on a rampage and borg their corpse.
		return FALSE
	var/datum/mind/mind = human.mind
	if(mind && mind.has_antag_datum(/datum/antagonist/changeling)) // Changelings can't be borged.
		return FALSE
	if(HAS_TRAIT(human, TRAIT_PIERCEIMMUNE) || HAS_TRAIT(human, TRAIT_NODISMEMBER)) // Just naturally thicc.
		return FALSE
	var/obj/item/clothing/head = human.head
	if(head && (head.clothing_flags & THICKMATERIAL)) // '/can_inject' code.
		return FALSE
	var/obj/item/clothing/suit = human.wear_suit
	if(suit && (suit.clothing_flags & THICKMATERIAL))
		return FALSE
	return TRUE

/// Starts the final process to borg. 
/obj/machinery/recharge_station/proc/try_borg()
	var/mob/living/carbon/human/human = occupant
	if(!human)
		return
	borging = TRUE
	borging_active = TRUE 
	var/list/bodyparts = list()
	for(var/obj/item/bodypart/bodypart as anything in human.bodyparts)
		if(bodypart.body_zone == BODY_ZONE_HEAD || bodypart.body_zone == BODY_ZONE_CHEST) // Don't want to accidentally instant-kill them.
			continue
		if(bodypart.status == BODYPART_ROBOTIC) // We love robots.
			continue
		if(!bodypart.dismemberable) // In the case that the limb somehow cannot be dismembered.
			continue
		bodyparts += bodypart
	playsound(src, 'sound/machines/juicer.ogg', 80, 1) // Juicer sounds more horrifying than Blender.
	for(var/obj/item/bodypart/bodypart in bodyparts) // Goodbye limbs.
		if(!src || human != occupant || !borging) // Something happened which allowed them to escape.
			borging = FALSE
			borging_active = FALSE
			return
		human.Paralyze(2 SECONDS, ignore_canstun = TRUE) // You're trapped here now.
		if(prob(25))
			do_sparks(1, FALSE, src)
		if(prob(50))
			human.emote("scream")
		bodypart.dismember() // Will kill if 4 dismembers while in hard crit. 
		human.spawn_gibs(FALSE) // Immersion.
		sleep(2 SECONDS)
	if(!src || human != occupant || !borging)
		borging = FALSE
		borging_active = FALSE
		return
	if(human.stat == DEAD) // Should of kept this flesh bag healthy (enough) until then.
		open_machine()
		return
	var/mob/living/silicon/robot/R = human.Robotize()
	R.cell = new /obj/item/stock_parts/cell/upgraded/plus(R, 5000)
	R.Paralyze(4 SECONDS)
	borging = FALSE
	borging_active = FALSE
	open_machine()
	playsound(src, 'sound/machines/ping.ogg', 20, TRUE)

/obj/machinery/recharge_station/process(delta_time)
	if(!is_operational())
		if(borging || borging_active)
			borging = FALSE
			borging_active = FALSE
			visible_message(span_danger("[src] buzzes."))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return
	if(occupant)
		process_occupant(delta_time)
	return 1

/obj/machinery/recharge_station/relaymove(mob/user)
	if(user.stat)
		return
	if(borging || borging_active)
		borging_resist(user)
		return
	open_machine()

// Most stolen from closet's '/container_resist'
/obj/machinery/recharge_station/proc/borging_resist(mob/living/user)
	if(!user || state_open || user.last_special >= world.time)
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_warning("[src] begins to shake violently!"),
		span_notice("You fight against the [src] and start pushing your way out... (this will take about [DisplayTimeText(breakout_time)].)"),
		span_italics("You hear banging from [src]."))
	if(do_after(user, breakout_time, src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open )
			return
		open_machine()
		user.visible_message(span_danger("[user] successfully broke out of [src]!"),
							span_notice("You successfully break out of [src]!"))
	else
		if(user.loc == src)
			to_chat(user, span_warning("You fail to break out of [src]!"))
	
/obj/machinery/recharge_station/emp_act(severity)
	. = ..()
	if(!(stat & (BROKEN|NOPOWER)))
		if(occupant && !(. & EMP_PROTECT_CONTENTS))
			occupant.emp_act(severity)
		if (!(. & EMP_PROTECT_SELF))
			open_machine()

/obj/machinery/recharge_station/attackby(obj/item/P, mob/user, params)
	if(state_open)
		if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", P))
			return

	if(default_pry_open(P))
		return

	if(default_deconstruction_crowbar(P))
		return
	return ..()

/obj/machinery/recharge_station/interact(mob/user)
	if(user == occupant && borging)
		borging_resist(user)
		return FALSE
	toggle_open()
	return TRUE

/obj/machinery/recharge_station/proc/toggle_open()
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/recharge_station/open_machine()
	. = ..()
	use_power = IDLE_POWER_USE
	if(borging || borging_active)
		borging = FALSE
		borging_active = FALSE
		visible_message(span_danger("[src] buzzes."))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)

/obj/machinery/recharge_station/close_machine()
	. = ..()
	if(occupant)
		use_power = ACTIVE_POWER_USE //It always tries to charge, even if it can't.
		add_fingerprint(occupant)

/obj/machinery/recharge_station/update_icon()
	if(is_operational())
		if(state_open)
			icon_state = "borgcharger0"
		else
			icon_state = (occupant ? "borgcharger1" : "borgcharger2")
	else
		icon_state = (state_open ? "borgcharger-u0" : "borgcharger-u1")

/obj/machinery/recharge_station/proc/process_occupant(delta_time)
	if(!occupant)
		return
	SEND_SIGNAL(occupant, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, recharge_speed * delta_time / 2, repairs)
	if(borging && !borging_active && COOLDOWN_FINISHED(src, borg_countdown))
		try_borg()
	
/obj/machinery/recharge_station/fullupgrade
	flags_1 = NODECONSTRUCT_1

/obj/machinery/recharge_station/fullupgrade/Initialize(mapload)
	. = ..()
	update_icon()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stock_parts/cell/bluespace(null)
	RefreshParts()
