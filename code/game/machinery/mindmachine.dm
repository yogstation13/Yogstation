/obj/machinery/mindmachine
	name = "\improper mind machine"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/machines/mind_machine.dmi'
	density = TRUE

#define MINDMACHINE_CAN_SUCCESS 1
#define MINDMACHINE_CAN_PODS 2
#define MINDMACHINE_CAN_OCCUPANTS 3
#define MINDMACHINE_CAN_DEAD 4
#define MINDMACHINE_CAN_CHARGE 5
#define MINDMACHINE_CAN_ACTIVE 6
#define MINDMACHINE_CAN_MINDRESIST 7
#define MINDMACHINE_CAN_ADMINGHOST 8
#define MINDMACHINE_CAN_ANTAGBLACKLIST 9
#define MINDMACHINE_CAN_MINDSHIELD 10
#define MINDMACHINE_CAN_MOBBLACKLIST 11
#define MINDMACHINE_CAN_SILICON 12
#define MINDMACHINE_CAN_MINDLESS_NOTANIMALS 13

#define MINDMACHINE_SENTIENT_PAIR 1
#define MINDMACHINE_SENTIENT_SOLO 2
#define MINDMACHINE_SENTIENT_NONE 3

/obj/machinery/mindmachine/hub
	name = "\improper mind machine hub"
	desc = "The main hub of a complete mind machine setup. Placed between two mind pods and used to control and manage the transfer. \
			Houses an experimental bluespace conduit which uses bluespace crystals for charge."
	icon_state = "hub"
	circuit = /obj/item/circuitboard/machine/mindmachine_hub
	/// A list of mobs that cannot be swapped to/from.
	var/static/list/blacklisted_mobs = typecacheof(list(
		/mob/living/simple_animal/slaughter,
		/mob/living/simple_animal/hostile/retaliate/goat/king,
		/mob/living/simple_animal/hostile/megafauna
	))
	/// The first connected mind machine pod.
	var/obj/machinery/mindmachine/pod/firstPod
	/// The second connected mind machine pod.
	var/obj/machinery/mindmachine/pod/secondPod
	/// Are the occupants currently getting mindswapped?
	var/active = FALSE
	/// How long does it take to fully complete a mindswap?
	var/completion_time = 30 SECONDS
	/// How many demiseconds have passed while `active`?
	var/delta_since = 0
	/// The progress to be shown in the UI (0 to 100).
	var/progressLength = 0
	/// Should the next completed mindswap fail in a terrible fashion?
	var/fail_on_next = FALSE
	/// How much charges does this hub have?
	var/charge = 0
	/// How much charges are required to mindswap?
	var/cost = 1

/obj/machinery/mindmachine/hub/Initialize(mapload)
	. = ..()
	try_connect_pods()

/obj/machinery/mindmachine/hub/Destroy()
	disconnect_pods()
	return ..()

/obj/machinery/mindmachine/hub/examine(mob/user)
	. = ..()
	if(!firstPod || !secondPod)
		. += span_notice("It can be connected with two nearby mind pods by using a <i>multitool</i>.")


/obj/machinery/mindmachine/hub/update_icon_state()
	switch(active)
		if(TRUE)
			icon_state = "hub_active"
		else
			icon_state = "hub"
	return ..()

/obj/machinery/mindmachine/hub/process(delta_time)
	if(!active)
		return

	delta_since += delta_time * 1 SECONDS
	if(delta_since < completion_time) // Still waiting.
		return

	STOP_PROCESSING(SSobj, src)
	active = FALSE
	delta_since = 0
	update_appearance(UPDATE_ICON)
	firstPod?.update_appearance(UPDATE_ICON)
	secondPod?.update_appearance(UPDATE_ICON)

	switch(initiate_mindswap(TRUE, TRUE))
		if(TRUE)
			playsound(src, 'sound/machines/ping.ogg', 100)
		else
			playsound(src, 'sound/machines/buzz-sigh.ogg', 100)
		
	firstPod?.open_machine()
	secondPod?.open_machine()

/obj/machinery/mindmachine/hub/attackby(obj/item/I, mob/user, params)
	// Connection
	if(user.a_intent == INTENT_HELP && I.tool_behaviour == TOOL_MULTITOOL)
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

/obj/machinery/mindmachine/hub/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/machinery/mindmachine/hub/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(fail_on_next)
		return FALSE
	playsound(src, "sparks", 100, 1)
	to_chat(user, span_warning("You temporarily alter the mind transfer regulator.")) // A bunch of words that I made up.
	fail_on_next = TRUE

/obj/machinery/mindmachine/hub/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(fail_on_next)
		return
	playsound(src, "sparks", 100, 1)
	visible_message(span_warning("[src] buzzes.]"))
	fail_on_next = TRUE

/obj/machinery/mindmachine/hub/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/mindmachine/hub/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MindMachineHub", name)
		ui.open()

/obj/machinery/mindmachine/hub/ui_data(mob/user)
	. = list()
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
		.["firstOpen"] = null
		.["firstLocked"] = null
		.["firstName"] = null
		.["firstStat"] = null
		.["firstMindType"] = null

	.["secondPod"] = secondPod ? secondPod : null
	.["secondOpen"] = secondPod?.state_open ? TRUE : FALSE

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
		.["secondOpen"] = null
		.["secondLocked"] = null
		.["secondName"] = null
		.["secondStat"] = null
		.["secondMindType"] = null

	.["fullyConnected"] = (firstPod && secondPod) ? TRUE : FALSE
	.["fullyOccupied"] = (firstPod.occupant && secondPod.occupant) ? TRUE : FALSE
	.["active"] = active
	.["progress"] = clamp(round(delta_since/completion_time, 0.01) * 100, 0, 100)


/obj/machinery/mindmachine/hub/ui_act(action, params)
	if(..())
		return

	switch(action)
		// First
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
		// Second
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
		// General
		if("activate")
			switch(can_mindswap())
				if(MINDMACHINE_CAN_SUCCESS)
					START_PROCESSING(SSobj, src)
					active = TRUE
					delta_since = 0
					firstPod.locked = TRUE
					secondPod.locked = TRUE
					update_appearance(UPDATE_ICON)
					firstPod?.update_appearance(UPDATE_ICON)
					secondPod?.update_appearance(UPDATE_ICON)
					. = TRUE
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
				// These are grouped together are here to prevent instant/easy determination for antag-checking.
				if(MINDMACHINE_CAN_MINDRESIST, MINDMACHINE_CAN_ADMINGHOST, MINDMACHINE_CAN_MINDSHIELD, MINDMACHINE_CAN_ANTAGBLACKLIST)
					balloon_alert(usr, "unable to detect brain waves")
					playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
					return
				if(MINDMACHINE_CAN_MOBBLACKLIST)
					balloon_alert(usr, "mind is too great")
					playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
					return
				if(MINDMACHINE_CAN_SILICON)
					balloon_alert(usr, "unable to interface with silicons")
					playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
					return
				if(MINDMACHINE_CAN_MINDLESS_NOTANIMALS)
					balloon_alert(usr, "mind waves incompatible")
					playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
					return

// Finds the two nearest mind machine pods and use them for `connect_pods` if possible.
/obj/machinery/mindmachine/hub/proc/try_connect_pods()
	var/first_found
	for(var/direction in GLOB.cardinals)
		var/obj/machinery/mindmachine/pod/found = locate(/obj/machinery/mindmachine/pod, get_step(src, direction))
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
/obj/machinery/mindmachine/hub/proc/connect_pods(obj/machinery/mindmachine/pod/first, obj/machinery/mindmachine/pod/second)
	firstPod = first
	firstPod.hub = src
	secondPod = second
	secondPod.hub = src

/// Disconnects pods from itself & disconnects itself from the pods.
/obj/machinery/mindmachine/hub/proc/disconnect_pods()
	firstPod?.hub = null
	firstPod = null
	secondPod?.hub = null
	secondPod = null

/obj/machinery/mindmachine/hub/proc/end_mindswapping()
	STOP_PROCESSING(SSobj, src)
	active = FALSE
	delta_since = 0
	update_appearance(UPDATE_ICON)
	firstPod?.update_appearance(UPDATE_ICON)
	secondPod?.update_appearance(UPDATE_ICON)

/// Safely attempts to mindswap, performs antag checks, aborts if checks fail.
/obj/machinery/mindmachine/hub/proc/initiate_mindswap(check_resist = FALSE, check_antag_datum = FALSE)
	switch(can_mindswap(check_resist, check_antag_datum))
		if(MINDMACHINE_CAN_SUCCESS)
			handle_mindswap(firstPod.occupant, secondPod.occupant)
			return TRUE
	return FALSE
	
/// Checks if they meet the requirements to mindswap.
/obj/machinery/mindmachine/hub/proc/can_mindswap(check_resist = FALSE, check_antag_datum = FALSE)
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
	if(active)
		return MINDMACHINE_CAN_ACTIVE
	
	// Some checks (check_resist & check_antag_datum) are only done near the start of
	// the actual mindswap solely to prevent people from antag checking by scanning them.
	if(check_resist)
		if(firstOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0) || secondOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
			return MINDMACHINE_CAN_MINDRESIST
		if(firstOccupant.key?[1] == "@" || secondOccupant.key?[1] == "@")
			return MINDMACHINE_CAN_ADMINGHOST
		if(HAS_TRAIT(firstOccupant, TRAIT_MINDSHIELD) || (HAS_TRAIT(secondOccupant, TRAIT_MINDSHIELD)))
			return MINDMACHINE_CAN_MINDSHIELD

	if(check_antag_datum)
		var/list/datum/antagonist/blacklisted_antag_datums = list(
			// Checks similar to wizard's mind swap:
			/datum/antagonist/changeling, // Their brain is useless (since they're a changeling).
			/datum/antagonist/cult, // Additional spells aren't transferring over sadly.
			/datum/antagonist/clockcult, // Same as bloodcult.
			/datum/antagonist/rev, // Issues arise when doing mindswapping from/to a headrev.
			// Causes HUD issues and probably more!
			/datum/antagonist/bloodsucker,
			/datum/antagonist/vampire
		)
		for(var/antag_datum in blacklisted_antag_datums)
			to_chat(world, "to looping [antag_datum]")
			if(firstOccupant.mind?.has_antag_datum(antag_datum) || secondOccupant.mind?.has_antag_datum(antag_datum))
				return MINDMACHINE_CAN_ANTAGBLACKLIST

	if(is_type_in_typecache(firstOccupant, blacklisted_mobs) || is_type_in_typecache(secondOccupant, blacklisted_mobs))
		return MINDMACHINE_CAN_MOBBLACKLIST
	if(issilicon(firstOccupant) || issilicon(secondOccupant))
		return MINDMACHINE_CAN_SILICON
	if(determine_mindswap_type(firstOccupant, secondOccupant) == MINDMACHINE_SENTIENT_NONE)
		if(!isanimal(firstOccupant) || !isanimal(secondOccupant)) // Must be both animals.
			return MINDMACHINE_CAN_MINDLESS_NOTANIMALS
	return MINDMACHINE_CAN_SUCCESS

/// Returns what type of mindswapping we should do.
/obj/machinery/mindmachine/hub/proc/determine_mindswap_type(mob/living/firstOccupant, mob/living/secondOccupant)
	if(!firstOccupant.key && !secondOccupant.key)
		return MINDMACHINE_SENTIENT_NONE
	if(firstOccupant.key && secondOccupant.key)
		return MINDMACHINE_SENTIENT_PAIR
	return MINDMACHINE_SENTIENT_SOLO

/// Mindswaps the two occupants based on their determined mindswap type.
/obj/machinery/mindmachine/hub/proc/handle_mindswap(mob/living/firstOccupant, mob/living/secondOccupant)
	var/type = determine_mindswap_type(firstOccupant, secondOccupant)
	switch(type)
		if(MINDMACHINE_SENTIENT_NONE)
			if(!isanimal(firstOccupant) || !isanimal(secondOccupant))
				return FALSE
			if(fail_on_next)
				mindswap_malfunction(firstOccupant, firstOccupant, MINDMACHINE_SENTIENT_NONE)
			else
				mindswap_nonsentient(firstOccupant, secondOccupant)
			return TRUE
		if(MINDMACHINE_SENTIENT_SOLO)
			var/sentientOccupant = firstOccupant.key ? firstOccupant : secondOccupant
			var/nonsentientOccupant = firstOccupant.key ? secondOccupant : firstOccupant
			if(fail_on_next)
				mindswap_malfunction(sentientOccupant, nonsentientOccupant, MINDMACHINE_SENTIENT_SOLO)
			else
				mindswap_sentient(sentientOccupant, nonsentientOccupant, fail_on_next)
			return TRUE
		if(MINDMACHINE_SENTIENT_PAIR)
			if(fail_on_next)
				mindswap_malfunction(firstOccupant, secondOccupant, MINDMACHINE_SENTIENT_PAIR)
			else
				mindswap_sentient(firstOccupant, secondOccupant, fail_on_next)
			return TRUE

/// Switches various factors between two non-sentient animals.
/obj/machinery/mindmachine/hub/proc/mindswap_nonsentient(mob/living/simple_animal/firstAnimal, mob/living/simple_animal/secondAnimal, fail = FALSE)
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

/// Mindswaps the two occupants (which one is sentient).
/obj/machinery/mindmachine/hub/proc/mindswap_sentient(mob/living/sentientOccupant, mob/living/otherOccupant, fail = FALSE)
	if(!otherOccupant.mind)
		otherOccupant.mind_initialize()

	var/datum/mind/sentientMind = sentientOccupant.mind
	var/datum/mind/otherMind = otherOccupant.mind
	var/otherKey = otherMind.key

	// It is important that a sentient mind swaps first. If you don't, the non-sentient mind will store the ckey of the sentient mind (and that it is bad)!
	sentientMind.transfer_to(otherOccupant)
	otherMind.transfer_to(sentientOccupant)
	if(otherKey)
		sentientOccupant.key = otherKey

	SEND_SOUND(sentientMind, sound('sound/magic/mandswap.ogg'))
	SEND_SOUND(otherMind, sound('sound/magic/mandswap.ogg'))

/obj/machinery/mindmachine/hub/proc/mindswap_malfunction(mob/living/firstOccupant, mob/living/secondOccupant, mindtype)
	if(!mindtype)
		return
	
	switch(mindtype)
		if(MINDMACHINE_SENTIENT_NONE)
			var/mob/living/simple_animal/firstAnimal = firstOccupant
			var/mob/living/simple_animal/secondAnimal = secondOccupant
			if(!firstAnimal || !secondAnimal)
				return
			// Failing means factions will be randomized which may cause them to be hostile to nearby people.
			// And since there are a million factions... let us keep it simple:
			var/list/random_factions = list("hostile", "neutral", "plants", "spiders")
			var/random_faction = random_factions[rand(1, random_factions.len)]
			firstAnimal.faction = list()
			firstAnimal.faction += random_faction

			random_faction = random_factions[rand(1, random_factions.len)]
			secondAnimal.faction = list()
			secondAnimal.faction += random_faction
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
			mindswap_sentient(firstOccupant, selectedMob)
			selectedMob.emote("gasp")
			to_chat(selectedMob, span_danger("Your mind is thrown out of the machine and forced into a nearby vessel!"))
			return
		if(MINDMACHINE_SENTIENT_PAIR)
			if(!firstOccupant || !secondOccupant)
				return
			// Gonna keep it simple. Just solo malfunction them.
			mindswap_malfunction(firstOccupant, null, MINDMACHINE_SENTIENT_SOLO)
			mindswap_malfunction(secondOccupant, null, MINDMACHINE_SENTIENT_SOLO)
			return

/obj/machinery/mindmachine/pod
	name = "\improper mind machine pod"
	desc = "A large pod used for mind transfers. \
	Contains two locking systems: One for ensuring occupants do not disturb the transfer process, and another that prevents lower minded creatures from leaving on their own."
	icon_state = "pod_open"
	circuit = /obj/item/circuitboard/machine/mindmachine_pod
	/// The connected mind machine hub.
	var/obj/machinery/mindmachine/hub/hub
	/// Is this pod closed and locked?
	var/locked = FALSE

/obj/machinery/mindmachine/pod/Initialize(mapload)
	. = ..()
	occupant_typecache = GLOB.typecache_living

/obj/machinery/mindmachine/pod/update_icon_state()
	switch(state_open)
		if(TRUE)
			icon_state = "pod_open"
		else
			if(hub?.active)
				icon_state = "pod_active"
			else
				icon_state = "pod_closed"
	return ..()

/obj/machinery/mindmachine/pod/Destroy()
	hub?.disconnect_pods()
	return ..()

/obj/machinery/mindmachine/pod/attackby(obj/item/I, mob/user, params)
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
/obj/machinery/mindmachine/pod/MouseDrop_T(atom/dropped, mob/user)
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
			user.visible_message(span_warning("[user] enters the [src] and closes the door behind [user.p_them()]!"))
		else
			dropped.visible_message(span_warning("[user] puts [dropped] into the [src]."))
		close_machine(dropped)
		return

/// Opens and closes the pod. Protects against interaction if the machine is active.
/obj/machinery/mindmachine/pod/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(locked)
		to_chat(user, span_notice("The pod is locked!"))
		return
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/mindmachine/pod/Exited(atom/movable/user)
	if(!state_open && user == occupant)
		container_resist(user)

/obj/machinery/mindmachine/pod/relaymove(mob/user)
	if(!state_open)
		container_resist(user)

/obj/machinery/mindmachine/pod/container_resist(mob/living/user)
	user.visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/mindmachine/pod/close_machine(atom/movable/target)
	..(target)
	playsound(src, 'sound/machines/decon/decon-close.ogg', 25, TRUE)

/obj/machinery/mindmachine/pod/open_machine(drop)
	if(hub?.active)
		hub.end_mindswapping()
	locked = FALSE
	..(drop)
	playsound(src, 'sound/machines/decon/decon-open.ogg', 25, TRUE)
