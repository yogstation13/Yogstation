/*	One of the returned values from `/obj/machinery/mindmachine_hub/can_mindswap()`
	Used to determine the reason why they failed to mindswap. */
#define MINDMACHINE_CAN_SUCCESS 1 // Except this value, this is success.
#define MINDMACHINE_CAN_SRCGONE 2
#define MINDMACHINE_CAN_PODS 3
#define MINDMACHINE_CAN_OCCUPANTS 4
#define MINDMACHINE_CAN_DEAD 5
#define MINDMACHINE_CAN_CHARGE 6
#define MINDMACHINE_CAN_ACTIVE 7
#define MINDMACHINE_CAN_MOBBLACKLIST 8
#define MINDMACHINE_CAN_SILICON 9
#define MINDMACHINE_CAN_SILICON_AISHELL 10
#define MINDMACHINE_CAN_MINDLESS_NOTANIMALS 11
#define MINDMACHINE_CAN_MINDRESIST 12
#define MINDMACHINE_CAN_MINDSHIELD 13
#define MINDMACHINE_CAN_ADMINGHOST 14
#define MINDMACHINE_CAN_ANTAGBLACKLIST 15
#define MINDMACHINE_CAN_DOUBLEMINDCKEY 16

/*	One of the returned values from `/obj/machinery/mindmachine_hub/determine_mindswap_type()`
	Used to determine if the pods contained 2 (pair), 1 (solo), or 0 (none) sentient mobs. */
#define MINDMACHINE_SENTIENT_PAIR 1
#define MINDMACHINE_SENTIENT_SOLO 2
#define MINDMACHINE_SENTIENT_NONE 3

/obj/machinery/mindmachine_hub
	name = "\improper mind machine hub"
	desc = "The main hub of a complete mind machine setup. Placed between two mind pods and used to control and manage the transfer. \
			Houses an experimental bluespace conduit which uses bluespace crystals for charge."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer" // This may appear to be a computer, but it is a machine (that looks like a computer).
	density = TRUE
	circuit = /obj/item/circuitboard/machine/mindmachine_hub
	/// The current icon of the screen.
	var/icon_screen = "medcomp"
	var/icon_keyboard = "med_key"
	/// A list of mobs that cannot be swapped to/from.
	var/static/list/blacklisted_mobs = typecacheof(list(
		/mob/living/simple_animal/slaughter,
		/mob/living/simple_animal/hostile/retaliate/goat/king,
		/mob/living/simple_animal/hostile/megafauna
	))
	/// The first connected mind machine pod.
	var/obj/machinery/mindmachine_pod/firstPod
	/// The second connected mind machine pod.
	var/obj/machinery/mindmachine_pod/secondPod
	/// Are the occupants currently getting mindswapped?
	var/active = FALSE
	/// How long does it take to fully complete a mindswap?
	var/completion_time = 30 SECONDS
	/// How much charges does this hub have?
	var/charge = 0
	/// How much charges are required to mindswap?
	var/cost = 4
	/// Should the next completed mindswap fail?
	var/fail_regardless = FALSE
	/// If not rigged (and not delayed), what is the chance of failure?
	var/fail_chance = 30
	/// Can silicons be mindswapped?
	var/silicon_permitted = FALSE
	/// Can delay transferred be used?
	var/delaytransfer_permitted = FALSE
	/// Is the transfer being delayed?
	var/delaytransfer_active = FALSE
	/// Was the transfer started by a delay?
	var/transfer_by_delay = FALSE

	COOLDOWN_DECLARE(until_completion)

/obj/machinery/mindmachine_hub/Initialize(mapload)
	. = ..()
	try_connect_pods()

/obj/machinery/mindmachine_hub/Destroy()
	deactivate()
	disconnect_pods()
	return ..()

/obj/machinery/mindmachine_hub/examine(mob/user)
	. = ..()
	if(panel_open && fail_regardless)
		. += span_warning("The regulator is misaligned. A <i>multitool</i> should fix it.")
	if(!firstPod || !secondPod)
		. += span_notice("It can be connected with two nearby mind pods by using a <i>multitool</i>.")
	. += span_notice("The charge meter reads: [charge].")
	. += span_notice("It costs [cost] charges per attempt.")

/obj/machinery/mindmachine_hub/update_icon_state()
	if(active)
		icon_screen = "crew" // Icon state? Icon screen? Eh, close enough!
	else
		icon_screen = initial(icon_screen)
	return ..()

// A copy paste of computer's update_overlays().
/obj/machinery/mindmachine_hub/update_overlays()
	. = ..()
	if(stat & NOPOWER)
		. += "[icon_keyboard]_off"
		return
	. += icon_keyboard

	// This whole block lets screens ignore lighting and be visible even in the darkest room
	var/overlay_state = icon_screen
	if(stat & BROKEN)
		overlay_state = "[icon_state]_broken"
	. += mutable_appearance(icon, overlay_state)
	. += emissive_appearance(icon, icon_screen, src)

/obj/machinery/mindmachine_hub/RefreshParts()
	// 2 matter bins. Reduce failure chance by 5 per tier. Results in 30 (tier 1) to 0 (tier 4).
	var/pre_fail_chance = 40
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		pre_fail_chance -= M.rating*5
	fail_chance = max(0, pre_fail_chance)
	// 1 capacitor. Reduces cost by 1 per tier. Results in 4 (tier 1) to 1 (tier 4).
	var/pre_cost = 5
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		pre_cost -= C.rating*1
	cost = max(1, pre_cost)
	// 1 scanning module. Unlocks delayed transfer & if silicons can be mind transferred. Only useful at tier 4.
	var/obj/item/stock_parts/scanning_module/C = locate() in component_parts
	silicon_permitted = (C && C.rating >= 4) ? TRUE : FALSE
	delaytransfer_permitted = (C && C.rating >= 4) ? TRUE : FALSE

/obj/machinery/mindmachine_hub/process(delta_time)
	if(active && COOLDOWN_FINISHED(src, until_completion))
		var/success = initiate_mindswap(FALSE, TRUE, TRUE)
		if(success) // Successfully transferred their mind to someone/something.
			balloon_alert_to_viewers("transferred")
			playsound(src, 'sound/machines/ping.ogg', 100)
		else
			balloon_alert_to_viewers("failed")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 100)
		if(charge >= cost)
			charge -= cost
		deactivate()

/obj/machinery/mindmachine_hub/proc/try_activate(mob/user, was_delayed = FALSE)
	delaytransfer_active = FALSE
	switch(can_mindswap()) // No checking here for mind protection/antag to prevent easy antag checking.
		if(MINDMACHINE_CAN_SUCCESS)
			if(was_delayed)
				log_game("[key_name(user)] initiated a mind machine mindswap process between [key_name(firstPod.occupant)] and [key_name(secondPod.occupant)] (delayed).")
			else
				log_game("[key_name(user)] initiated a mind machine mindswap process between [key_name(firstPod.occupant)] and [key_name(secondPod.occupant)].")
			activate(was_delayed)
			. = TRUE
		if(MINDMACHINE_CAN_SRCGONE)
			return
		if(MINDMACHINE_CAN_PODS)
			balloon_alert(usr, "not connected")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_OCCUPANTS)
			balloon_alert(usr, "not enough occupants")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_DEAD)
			balloon_alert(usr, "vital signs not detected")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_CHARGE)
			balloon_alert(usr, "not enough charge")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_ACTIVE)
			balloon_alert(usr, "already on")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_MINDRESIST, MINDMACHINE_CAN_ADMINGHOST, MINDMACHINE_CAN_MINDSHIELD, MINDMACHINE_CAN_ANTAGBLACKLIST)
			balloon_alert(usr, "unable to detect brain waves")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_MOBBLACKLIST)
			balloon_alert(usr, "mind is too great")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_SILICON)
			balloon_alert(usr, "not upgraded for silicons")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_SILICON_AISHELL)
			balloon_alert(usr, "silicon mind too distant")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return
		if(MINDMACHINE_CAN_MINDLESS_NOTANIMALS, MINDMACHINE_CAN_DOUBLEMINDCKEY)
			balloon_alert(usr, "mind waves incompatible")
			playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
			return

/// If not active, activates the hub and locks the pods.
/obj/machinery/mindmachine_hub/proc/activate(was_delayed = FALSE)
	if(!active && firstPod && secondPod)
		active = TRUE
		if(was_delayed)
			transfer_by_delay = TRUE
		COOLDOWN_START(src, until_completion, completion_time)
		START_PROCESSING(SSobj, src)
		update_appearance(UPDATE_ICON)
		firstPod.update_appearance(UPDATE_ICON)
		secondPod.update_appearance(UPDATE_ICON)
		firstPod.locked = TRUE
		secondPod.locked = TRUE

/// If active, deactivates the hubs and opens the pods.
/obj/machinery/mindmachine_hub/proc/deactivate()
	if(active)
		active = FALSE
		transfer_by_delay = FALSE
		STOP_PROCESSING(SSobj, src)
		update_appearance(UPDATE_ICON)
		firstPod?.update_appearance(UPDATE_ICON)
		secondPod?.update_appearance(UPDATE_ICON)
		firstPod?.open_machine()
		secondPod?.open_machine()
		
/obj/machinery/mindmachine_hub/attackby(obj/item/I, mob/user, params)
	// Connection
	if(user.a_intent == INTENT_HELP && I.tool_behaviour == TOOL_MULTITOOL)
		if(panel_open && fail_regardless)
			to_chat(user, span_notice("You realign [src]'s regulator."))
			fail_regardless = FALSE
			return
		if(!firstPod || !secondPod)
			var/success = try_connect_pods()
			if(success)
				to_chat(user, span_notice("You successfully connected the [src]."))
			else
				to_chat(user, span_notice("[src] does not detect two nearby pods to connect to."))
			return
	// Charge Increase
	var/increase_per = 0
	if(istype(I, /obj/item/stack/telecrystal))
		increase_per = 10
	else if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		if(istype(I, /obj/item/stack/ore/bluespace_crystal/artificial))
			increase_per = 1
		else if(istype(I, /obj/item/stack/ore/bluespace_crystal/refined))
			increase_per = 5
		else
			increase_per = 2
	if(increase_per)
		if(!user.temporarilyRemoveItemFromInventory(I))
			to_chat(user, span_warning("[I] is stuck to your hand!"))
			return
		var/obj/item/stack/stack_item = I
		if(stack_item)
			var/amt = stack_item.get_amount()
			if(amt >= 1 && stack_item.use(amt))
				var/increased_charge_by = increase_per * amt
				to_chat(user, span_notice("You increased [src]'s charge by [increased_charge_by] charges."))
				playsound(src, 'sound/machines/ping.ogg', 100)
				charge += increased_charge_by
		return
	// Deconstruction
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/mindmachine_hub/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/machinery/mindmachine_hub/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(fail_regardless)
		return FALSE
	playsound(src, "sparks", 100, 1)
	to_chat(user, span_warning("You temporarily alter the mind transfer regulator."))
	fail_regardless = TRUE

/obj/machinery/mindmachine_hub/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(fail_regardless)
		return
	playsound(src, "sparks", 100, 1)
	visible_message(span_warning("[src] buzzes."))
	fail_regardless = TRUE

/obj/machinery/mindmachine_hub/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/mindmachine_hub/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MindMachineHub", name)
		ui.open()

/obj/machinery/mindmachine_hub/ui_data(mob/user)
	. = list()
	.["fullyConnected"] = (firstPod && secondPod) ? TRUE : FALSE
	if(firstPod && secondPod)
		.["fullyOccupied"] = (firstPod.occupant && secondPod.occupant) ? TRUE : FALSE
	.["canDelayTransfer"] = delaytransfer_permitted
	.["active"] = active
	.["progress"] = clamp(round(COOLDOWN_TIMELEFT(src, until_completion)/completion_time, 0.01) * 100, 0, 100)

	.["firstPod"] = firstPod ? firstPod : null
	if(firstPod)
		.["firstOpen"] = firstPod.state_open
		.["firstLocked"] = firstPod.locked
		var/mob/living/firstLiving = firstPod.occupant
		if(firstLiving)
			.["firstName"] = firstLiving.name
			switch(firstLiving.stat)
				if(CONSCIOUS, SOFT_CRIT)
					.["firstStat"] = "Conscious"
				if(UNCONSCIOUS)
					.["firstStat"] = "Unconscious"
				if(DEAD)
					.["firstStat"] = "Dead"
			.["firstMindType"] = firstLiving.key ? "Sentient" : "Non-Sentient"
		else
			.["firstName"] = null
			.["firstStat"] = null
			.["firstMindType"] = null
	else // If you don't null it and keep the ui open, then above data doesn't change until you reopen.
		.["firstOpen"] = null
		.["firstLocked"] = null
		.["firstName"] = null
		.["firstStat"] = null
		.["firstMindType"] = null

	.["secondPod"] = secondPod ? secondPod : null
	if(secondPod)
		.["secondOpen"] = secondPod.state_open
		.["secondLocked"] = secondPod.locked
		var/mob/living/secondLiving = secondPod.occupant
		if(secondLiving)
			.["secondName"] = secondLiving.name
			switch(secondLiving.stat)
				if(CONSCIOUS, SOFT_CRIT)
					.["secondStat"] = "Conscious"
				if(UNCONSCIOUS)
					.["secondStat"] = "Unconscious"
				if(DEAD)
					.["secondStat"] = "Dead"
			.["secondMindType"] = secondLiving.key ? "Sentient" : "Non-Sentient"
		else
			.["secondName"] = null
			.["secondStat"] = null
			.["secondMindType"] = null
	else
		.["secondOpen"] = null
		.["secondLocked"] = null
		.["secondName"] = null
		.["secondStat"] = null
		.["secondMindType"] = null

/obj/machinery/mindmachine_hub/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("first_toggledoor")
			if(firstPod)
				if(firstPod.state_open)
					firstPod.close_machine()
				else
					firstPod.open_machine()
				. = TRUE
		if("first_togglelock")
			if(firstPod)
				playsound(firstPod, 'sound/machines/switch3.ogg', 30, TRUE)
				firstPod.locked = !firstPod.locked
				. = TRUE
		if("second_toggledoor")
			if(secondPod)
				if(secondPod.state_open)
					secondPod.close_machine()
				else
					secondPod.open_machine()
				. = TRUE
		if("second_togglelock")
			if(secondPod)
				playsound(secondPod, 'sound/machines/switch3.ogg', 30, TRUE)
				secondPod.locked = !secondPod.locked
				. = TRUE
		if("activate")
			try_activate(usr)
		if("activate_delay")
			if(active || delaytransfer_active)
				balloon_alert(usr, "already delayed")
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			delaytransfer_active = TRUE
			balloon_alert(usr, "delay active")
			playsound(src, 'sound/machines/ping.ogg', 50)
			addtimer(CALLBACK(src, PROC_REF(try_activate), usr, TRUE), 3 SECONDS)

/// Finds the two nearest mind machine pods and use them for `connect_pods` if possible.
/obj/machinery/mindmachine_hub/proc/try_connect_pods()
	var/first_found
	for(var/direction in GLOB.cardinals)
		var/obj/machinery/mindmachine_pod/found = locate(/obj/machinery/mindmachine_pod, get_step(src, direction))
		if(!found)
			continue
		if(found.hub) // Already connected to something else.
			continue
		if(!first_found)
			first_found = found
			continue
		connect_pods(first_found, found)
		return TRUE
	return FALSE

/// Connects pods to itself & connects itself to the pods.
/obj/machinery/mindmachine_hub/proc/connect_pods(obj/machinery/mindmachine_pod/first, obj/machinery/mindmachine_pod/second)
	firstPod = first
	firstPod.hub = src
	secondPod = second
	secondPod.hub = src

/// Disconnects pods from itself & disconnects itself from the pods.
/obj/machinery/mindmachine_hub/proc/disconnect_pods()
	firstPod?.hub = null
	firstPod = null
	secondPod?.hub = null
	secondPod = null

/obj/machinery/mindmachine_hub/proc/should_fail(no_fail = FALSE, ignore_rigged = FALSE, ignore_delayed = FALSE)
	if(no_fail)
		return FALSE
	if(!ignore_rigged && fail_regardless)
		return TRUE
	var/total_fail_chance = fail_chance
	if(!ignore_delayed && transfer_by_delay)
		total_fail_chance += 20
	if(prob(total_fail_chance))
		return TRUE
	return FALSE

/// Safely attempts to mindswap, performs any required checks, aborts if checks fail.
/obj/machinery/mindmachine_hub/proc/initiate_mindswap(check_active = TRUE, check_resist = FALSE, check_antag_datum = FALSE)
	var/ret = can_mindswap(check_active, check_resist, check_antag_datum)
	if(ret == MINDMACHINE_CAN_SUCCESS)
		handle_mindswap(firstPod.occupant, secondPod.occupant)
		return TRUE
	return FALSE
	
/// Checks if they meet the requirements to mindswap.
/obj/machinery/mindmachine_hub/proc/can_mindswap(check_active = FALSE, check_resist = FALSE, check_antag_datum = FALSE)
	if(!src)  // Hub deleted while delay activating.
		return MINDMACHINE_CAN_SRCGONE
	if(!firstPod || !secondPod)
		return MINDMACHINE_CAN_PODS
	var/mob/living/firstOccupant = firstPod.occupant
	var/mob/living/secondOccupant = secondPod.occupant
	if(!firstOccupant || !secondOccupant)
		return MINDMACHINE_CAN_OCCUPANTS
	if(firstOccupant.stat == DEAD || secondOccupant.stat == DEAD)
		return MINDMACHINE_CAN_DEAD
	if(cost > charge)
		return MINDMACHINE_CAN_CHARGE
	if(check_active && active)
		return MINDMACHINE_CAN_ACTIVE
	if(is_type_in_typecache(firstOccupant, blacklisted_mobs) || is_type_in_typecache(secondOccupant, blacklisted_mobs))
		return MINDMACHINE_CAN_MOBBLACKLIST
	if(issilicon(firstOccupant) || issilicon(secondOccupant))
		if(!silicon_permitted)
			return MINDMACHINE_CAN_SILICON
		if(iscyborg(firstOccupant))
			var/mob/living/silicon/robot/firstCyborg = firstOccupant
			if(firstCyborg.shell)
				return MINDMACHINE_CAN_SILICON_AISHELL
		if(iscyborg(secondOccupant))
			var/mob/living/silicon/robot/secondCyborg = secondOccupant
			if(secondCyborg.shell)
				return MINDMACHINE_CAN_SILICON_AISHELL

	if(determine_mindswap_type(firstOccupant, secondOccupant) == MINDMACHINE_SENTIENT_NONE)
		if(!isanimal(firstOccupant) || !isanimal(secondOccupant)) // No point in mindswapping two non-sentient humans.
			return MINDMACHINE_CAN_MINDLESS_NOTANIMALS
	/* 	Some checks (check_resist & check_antag_datum) are only done at the start of
		the actual mindswap solely to prevent people from antag checking by scanning them. */
	if(check_resist)
		if(firstOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, 0) || secondOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, 0))
			return MINDMACHINE_CAN_MINDRESIST
		if(HAS_TRAIT(firstOccupant, TRAIT_MINDSHIELD) || (HAS_TRAIT(secondOccupant, TRAIT_MINDSHIELD)))
			return MINDMACHINE_CAN_MINDSHIELD
		if(firstOccupant.key?[1] == "@" || secondOccupant.key?[1] == "@")
			return MINDMACHINE_CAN_ADMINGHOST
	if(check_antag_datum)
		/* 	As depressing as it is to cut off enjoyment for certain people, these antags either cause problems
			or it is not realistic to add them in. In addition, wizard mindswap restrictions are here too.*/
		var/list/datum/antagonist/blacklisted_antag_datums = list(
			// From wizard mindswap's restricted list:
			/datum/antagonist/changeling,
			/datum/antagonist/cult,
			/datum/antagonist/rev,
			// Additional
			/datum/antagonist/clockcult, // Same as bloodcult.
			/datum/antagonist/bloodsucker,
			/datum/antagonist/vampire
		)
		for(var/antag_datum in blacklisted_antag_datums)
			if(firstOccupant.mind?.has_antag_datum(antag_datum) || secondOccupant.mind?.has_antag_datum(antag_datum))
				return MINDMACHINE_CAN_ANTAGBLACKLIST
	if(firstOccupant.mind?.key == secondOccupant.mind?.key)
		return MINDMACHINE_CAN_DOUBLEMINDCKEY
	return MINDMACHINE_CAN_SUCCESS

/// Returns what type of mindswapping we should do.
/obj/machinery/mindmachine_hub/proc/determine_mindswap_type(mob/living/firstOccupant, mob/living/secondOccupant)
	if(!firstOccupant.key && !secondOccupant.key)
		return MINDMACHINE_SENTIENT_NONE
	if(firstOccupant.key && secondOccupant.key)
		return MINDMACHINE_SENTIENT_PAIR
	return MINDMACHINE_SENTIENT_SOLO

/// Mindswaps the two occupants based on their determined mindswap type.
/obj/machinery/mindmachine_hub/proc/handle_mindswap(mob/living/firstOccupant, mob/living/secondOccupant)
	var/type = determine_mindswap_type(firstOccupant, secondOccupant)
	switch(type)
		if(MINDMACHINE_SENTIENT_NONE)
			if(!isanimal(firstOccupant) || !isanimal(secondOccupant))
				return FALSE
			if(should_fail())
				mindswap_malfunction(firstOccupant, firstOccupant, MINDMACHINE_SENTIENT_NONE)
			else
				mindswap_nonsentient(firstOccupant, secondOccupant)
			return TRUE
		if(MINDMACHINE_SENTIENT_SOLO)
			var/sentientOccupant = firstOccupant.key ? firstOccupant : secondOccupant
			var/nonsentientOccupant = firstOccupant.key ? secondOccupant : firstOccupant
			if(should_fail())
				mindswap_malfunction(sentientOccupant, nonsentientOccupant, MINDMACHINE_SENTIENT_SOLO)
			else
				mindswap_sentient(sentientOccupant, nonsentientOccupant)
			return TRUE
		if(MINDMACHINE_SENTIENT_PAIR)
			if(should_fail())
				mindswap_malfunction(firstOccupant, secondOccupant, MINDMACHINE_SENTIENT_PAIR)
			else
				mindswap_sentient(firstOccupant, secondOccupant)
			return TRUE

/// Switches various factors between two non-sentient animals.
/obj/machinery/mindmachine_hub/proc/mindswap_nonsentient(mob/living/simple_animal/firstAnimal, mob/living/simple_animal/secondAnimal)
	// Faction
	var/list/firstFaction = firstAnimal.faction.Copy()
	var/list/secondFaction = secondAnimal.faction.Copy()
	firstAnimal.faction = secondFaction
	secondAnimal.faction = firstFaction
	// Speak Chance
	var/firstSpeakChance = firstAnimal.speak_chance
	var/secondSpeakChance = secondAnimal.speak_chance
	firstAnimal.speak_chance = secondSpeakChance
	secondAnimal.speak_chance = firstSpeakChance
	// Speak Lines
	var/list/firstSpeak = firstAnimal.speak.Copy()
	var/list/secondSpeak = secondAnimal.speak.Copy()
	firstAnimal.speak = secondSpeak
	secondAnimal.speak = firstSpeak
	log_game("[firstAnimal] and [secondAnimal] had their faction, speak list, and speak chance swapped by a mind machine.")

/// Mindswaps the two occupants (which one is sentient).
/obj/machinery/mindmachine_hub/proc/mindswap_sentient(mob/living/sentientOccupant, mob/living/otherOccupant, do_log = TRUE)
	if(!otherOccupant.mind)
		otherOccupant.mind_initialize()

	var/datum/mind/sentientMind = sentientOccupant.mind
	var/datum/mind/otherMind = otherOccupant.mind
	var/otherKey = otherMind.key

	if(do_log)
		log_game("[key_name(sentientMind)] and [key_name(otherMind)] was mindswapped by a mind machine.")
	// It is important that a sentient mind swaps first. If you don't, the non-sentient mind will store the ckey of the sentient mind (and that it is bad)!
	sentientMind.transfer_to(otherOccupant)
	otherMind.transfer_to(sentientOccupant)
	if(otherKey)
		sentientOccupant.key = otherKey

	SEND_SOUND(sentientMind, sound('sound/magic/mandswap.ogg'))
	SEND_SOUND(otherMind, sound('sound/magic/mandswap.ogg'))

/obj/machinery/mindmachine_hub/proc/mindswap_malfunction(mob/living/firstOccupant, mob/living/secondOccupant, mindtype)
	if(!mindtype)
		return
	
	switch(mindtype)
		if(MINDMACHINE_SENTIENT_NONE)
			var/mob/living/simple_animal/firstAnimal = firstOccupant
			var/mob/living/simple_animal/secondAnimal = secondOccupant
			if(!firstAnimal || !secondAnimal)
				return

			/* 	Failing means factions will be randomized which may cause them to be hostile to nearby people.
				And since there are a million factions... let us keep it simple: */
			var/list/random_factions = list("hostile", "neutral", "plants", "spiders")
			var/random_faction = random_factions[rand(1, random_factions.len)]
			firstAnimal.faction = list()
			firstAnimal.faction += random_faction
			log_game(span_notice("[firstAnimal] got faction [random_faction] due to malfunction mindswapped."))

			random_faction = random_factions[rand(1, random_factions.len)]
			secondAnimal.faction = list()
			secondAnimal.faction += random_faction
			log_game(span_notice("[secondAnimal] got faction [random_faction] due to malfunction mindswapped."))

			return
		if(MINDMACHINE_SENTIENT_SOLO)
			if(!firstOccupant)
				return

			// Throw this solo victim into a nearby body.
			var/list/mob/living/acceptableMobs = list()
			for(var/mob/living/aliveMob in GLOB.alive_mob_list)
				if(aliveMob.mind)
					continue
				if(is_type_in_typecache(aliveMob.type, blacklisted_mobs))
					continue
				if(issilicon(aliveMob))
					continue
				var/turf/T = get_turf(aliveMob)
				if(!T || !is_station_level(T.z))
					continue
				if(get_dist(src, aliveMob) > 50)
					continue
				acceptableMobs += aliveMob

			var/mob/living/selectedMob
			if(!length(acceptableMobs)) // .. Unless we can't find a body.
				if(ishuman(firstOccupant))
					firstOccupant.adjustOrganLoss(ORGAN_SLOT_BRAIN, 75) // Can die to this.
					to_chat(firstOccupant, span_danger("Your mind is severely damaged by the feedback!"))
				return

			selectedMob = pick(acceptableMobs)
			log_game("[key_name(firstOccupant)] was mindswapped into [selectedMob] due to malfunctional mind machine.")
			message_admins(span_notice("[ADMIN_LOOKUPFLW(firstOccupant)] was malfunctional mindswapped to [ADMIN_LOOKUPFLW(selectedMob)]!"))

			mindswap_sentient(firstOccupant, selectedMob, FALSE) // Already logged, so don't need to log again.
			selectedMob.emote("gasp") // Hints everyone nearby that something is off about this previously-nonsentient mob.
			to_chat(selectedMob, span_danger("Your mind is thrown out of the machine and forced into a nearby vessel!"))
			return
		if(MINDMACHINE_SENTIENT_PAIR)
			if(!firstOccupant || !secondOccupant)
				return
			// Gonna keep it simple. Just solo malfunction them.
			mindswap_malfunction(firstOccupant, null, MINDMACHINE_SENTIENT_SOLO)
			mindswap_malfunction(secondOccupant, null, MINDMACHINE_SENTIENT_SOLO)
			return

/obj/machinery/mindmachine_pod
	name = "\improper mind machine pod"
	desc = "A large pod used for mind transfers. \
	Contains two locking systems: One for ensuring occupants do not disturb the transfer process, and another that prevents lower minded creatures from leaving on their own."
	icon = 'icons/obj/objects.dmi'
	icon_state = "hivebot_fab"
	circuit = /obj/item/circuitboard/machine/mindmachine_pod
	/// The connected mind machine hub.
	var/obj/machinery/mindmachine_hub/hub
	/// Is this pod closed and locked?
	var/locked = FALSE

/obj/machinery/mindmachine_pod/Initialize(mapload)
	. = ..()
	occupant_typecache = GLOB.typecache_living
	open_machine(no_sound = TRUE)

/obj/machinery/mindmachine_pod/update_icon_state()
	switch(state_open)
		if(TRUE)
			icon_state = initial(icon_state)
		else
			if(hub?.active)
				icon_state = "hivebot_fab_on"
			else
				icon_state = "hivebot_fab_off"
	return ..()

/obj/machinery/mindmachine_pod/Destroy()
	hub?.disconnect_pods()
	return ..()

/obj/machinery/mindmachine_pod/attackby(obj/item/I, mob/user, params)
	// Force Unlock
	if(user.a_intent == INTENT_HELP && I.tool_behaviour == TOOL_CROWBAR)
		if(do_after(user, 1 SECONDS, src))
			open_machine()
			return
	if(!occupant)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
			return
		if(default_deconstruction_crowbar(I))
			return
	return ..()

/// Lets you shove people (or yourself) into the pod.
/obj/machinery/mindmachine_pod/MouseDrop_T(atom/dropped, mob/user)
	if(!isliving(dropped))
		return
	var/mob/living/living_mob = dropped
	if(!user.Adjacent(living_mob))
		return
	if(user.incapacitated() || !Adjacent(user))
		return
	if(occupant)
		to_chat(user, span_notice("The pod is already occupied!"))
		return
	if(!state_open)
		to_chat(user, span_notice("The pod is closed!"))
		return
	if(panel_open)
		to_chat(user, span_notice("Close the maintenance panel first."))
		return
	if(do_after(user, 3 SECONDS, dropped))
		if(dropped == user)
			user.visible_message(span_warning("[user] enters [src] and closes the door behind [user.p_them()]!"))
		else
			dropped.visible_message(span_warning("[user] puts [dropped] into [src]."))
		close_machine(dropped)
		return

/obj/machinery/mindmachine_pod/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(locked)
		to_chat(user, span_notice("The pod is locked!"))
		return
	if(state_open)
		// Due to spriting issues (the lack of empty closed sprite), you can only close if it is empty. :)
		close_machine(no_sound = TRUE)
		if(!occupant)
			open_machine(no_sound = TRUE)
		else
			playsound(src, 'sound/machines/decon/decon-close.ogg', 25, TRUE)
	else
		open_machine()

/obj/machinery/mindmachine_pod/Exited(atom/movable/user)
	if(!state_open && user == occupant)
		container_resist(user)

/obj/machinery/mindmachine_pod/relaymove(mob/user)
	if(!state_open)
		container_resist(user)

/obj/machinery/mindmachine_pod/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		return
	var/escape_time = 10 SECONDS
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You hear [user] kicking against the door of [src]!"), \
		span_notice("You start to pry [src]'s door open... (this will take about [DisplayTimeText(escape_time)].)"), \
		span_italics("You hear a metallic creaking from [src]."))
	if(!do_after(user,(escape_time), src))
		return
	if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
		return
	user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
		span_notice("You successfully break out of [src]!"))
	open_machine()

/obj/machinery/mindmachine_pod/close_machine(atom/movable/target, no_sound = FALSE)
	..(target)
	if(!no_sound)
		playsound(src, 'sound/machines/decon/decon-close.ogg', 25, TRUE)

/obj/machinery/mindmachine_pod/open_machine(drop, no_sound = FALSE)
	hub?.deactivate()
	locked = FALSE
	..(drop)
	if(!no_sound)
		playsound(src, 'sound/machines/decon/decon-open.ogg', 25, TRUE)
