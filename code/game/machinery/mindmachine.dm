/obj/machinery/mindmachine
	name = "\improper mind machine"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/machines/mind_machine.dmi'
	active_power_usage = 10000 // Placeholder value.
	density = TRUE

#define MINDMACHINE_NO_PODS "Mind transfer aborted. Pods are no longer connected."
#define MINDMACHINE_NO_OCCUPANTS "Mind transfer aborted. Occupant disconnected mid-transfer."
#define MINDMACHINE_UNKNOWN "Mind transfer aborted. Unknown reason."
#define MINDMACHINE_TRANSFER_NEARBYANIMAL "Mind transfer success..? Mind transfered to nearby animal."
#define MINDMACHINE_TOTAL_LOW_IQ "Unable to swap upward." // No swapping from non-sentient animal to non-sentient human.
#define MINDMACHINE_SUCCESS "Success!"

// Text from in GUI.
#define MINDMACHINE_NO_ERROR "No error."

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
	/// How much charges does this hub have?
	var/charge = 0
	/// How much charges are required to mindswap?
	var/cost = 1
	/// Are the occupants currently getting mindswapped?
	var/active = FALSE
	/// How long does it take to fully complete a mindswap?
	var/completion_time = 30 SECONDS
	/// How many demiseconds have passed while `active`?
	var/delta_since = 0
	/// Error message to be shown in the UI.
	var/errorMessage = MINDMACHINE_NO_ERROR
	/// The progress to be shown in the UI (0 to 100).
	var/progressLength = 0

/obj/machinery/mindmachine/hub/Initialize(mapload)
	. = ..()
	try_connect_pods()

/obj/machinery/mindmachine/hub/Destroy()
	disconnect_pods()
	return ..()

/obj/machinery/mindmachine/hub/update_icon_state()
	switch(active)
		if(TRUE)
			icon_state = "hub_active"
		else
			icon_state = "hub"
	return ..()

/obj/machinery/mindmachine/hub/examine(mob/user)
	. = ..()
	if(!firstPod || !secondPod)
		. += span_notice("It can be connected with two nearby mind pods by using a <i>multitool</i>.")

/obj/machinery/mindmachine/hub/process(delta_time)
	if(active)
		delta_since += delta_time * 1 SECONDS
		var/progressDecimal = round(delta_since/completion_time, 0.01)
		progressLength = clamp(progressDecimal * 100, 0, 100)
		if(delta_since > completion_time)
			finalize_mindswap()
			end_mindswapping()
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
		var/obj/item/stack/stack_item = I // Only accepting stacks for now.
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

/// Debugging only. Triggers attack_hand().
/obj/machinery/mindmachine/hub/AltClick(mob/user)
	attack_hand(user)

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
	.["errorMessage"] = errorMessage
	.["progress"] = progressLength

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
			if(!firstPod || !secondPod)
				balloon_alert(usr, "not connected")
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			var/mob/living/firstOccupant = firstPod.occupant
			var/mob/living/secondOccupant = secondPod.occupant
			if(!firstOccupant || !secondOccupant)
				balloon_alert(usr, "not enough occupants")
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			if(cost > charge)
				balloon_alert(usr, "not enough charge")
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			if(active)
				balloon_alert(usr, "already on")
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			if(firstOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0) || secondOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0) || firstOccupant.key?[1] == "@" || secondOccupant.key?[1] == "@" )
				balloon_alert(usr, "mind waves unable to find brain")
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			if(HAS_TRAIT(firstOccupant, TRAIT_MINDSHIELD) || (HAS_TRAIT(secondOccupant, TRAIT_MINDSHIELD)))
				balloon_alert(usr, "mind waves ineffective")
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			if(is_type_in_typecache(firstOccupant, blacklisted_mobs) || is_type_in_typecache(secondOccupant, blacklisted_mobs))
				balloon_alert(usr, "mind is too great")
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			if(issilicon(firstOccupant) || issilicon(secondOccupant))
				balloon_alert(usr, "not upgraded enough to impact silicons") // TODO: Allow silicons to mindswap at T4.
				playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
				return
			
			visible_message(span_notice("Beginning mind transfer..."))

			START_PROCESSING(SSobj, src)
			active = TRUE
			delta_since = 0
			progressLength = 0
			firstPod.locked = TRUE
			secondPod.locked = TRUE
			update_appearance(UPDATE_ICON)
			firstPod?.update_appearance(UPDATE_ICON)
			secondPod?.update_appearance(UPDATE_ICON)
			. = TRUE

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

/obj/machinery/mindmachine/hub/proc/connect_pods(obj/machinery/mindmachine/pod/first, obj/machinery/mindmachine/pod/second)
	firstPod = first
	firstPod.hub = src
	secondPod = second
	secondPod.hub = src

/obj/machinery/mindmachine/hub/proc/disconnect_pods()
	firstPod?.hub = null
	firstPod = null
	secondPod?.hub = null
	secondPod = null

/obj/machinery/mindmachine/hub/proc/end_mindswapping(interrupted = FALSE)
	STOP_PROCESSING(SSobj, src)
	active = FALSE
	delta_since = 0
	progressLength = 0
	update_appearance(UPDATE_ICON)
	firstPod?.update_appearance(UPDATE_ICON)
	secondPod?.update_appearance(UPDATE_ICON)

	if(!interrupted)
		return
	if(!firstPod || !secondPod)
		playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
		var/mob/living/carbon/firstCarbon = firstPod.occupant
		if(firstCarbon)
			SEND_SOUND(firstCarbon, sound('sound/weapons/gunshot.ogg')) // This is your brain popping.
			firstCarbon.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20, 75)
		var/mob/living/carbon/secondCarbon = secondPod.occupant
		if(secondCarbon)
			SEND_SOUND(secondCarbon, sound('sound/weapons/gunshot.ogg'))
			secondCarbon.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20, 75)
		return MINDMACHINE_NO_PODS
	var/mob/living/firstOccupant = firstPod.occupant
	var/mob/living/secondOccupant = secondPod.occupant
	if(!firstOccupant || !secondOccupant)
		playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
		var/mob/living/carbon/firstCarbon = firstPod.occupant
		if(firstCarbon)
			SEND_SOUND(firstCarbon, sound('sound/weapons/gunshot.ogg'))
			firstCarbon.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 75)
		var/mob/living/carbon/secondCarbon = secondPod.occupant
		if(secondCarbon)
			SEND_SOUND(secondCarbon, sound('sound/weapons/gunshot.ogg'))
			secondCarbon.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 75)
		return MINDMACHINE_NO_OCCUPANTS

/obj/machinery/mindmachine/hub/proc/finalize_mindswap()
	if(!firstPod || !secondPod)
		return end_mindswapping(TRUE)

	var/mob/living/firstOccupant = firstPod.occupant
	var/mob/living/secondOccupant = secondPod.occupant
	if(!firstOccupant || !secondOccupant)
		return end_mindswapping(TRUE)

	if(firstOccupant.mind?.has_antag_datum(/datum/antagonist/changeling) && !secondOccupant.mind?.has_antag_datum(/datum/antagonist/changeling))
		playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
		var/mob/living/carbon/secondCarbon = secondPod.occupant
		if(secondCarbon)
			secondCarbon.adjustOrganLoss(ORGAN_SLOT_BRAIN, 75, 99) // You tried to transfer into a changeling's reductant brain.
		return MINDMACHINE_UNKNOWN
	else if (!firstOccupant.mind?.has_antag_datum(/datum/antagonist/changeling) && secondOccupant.mind?.has_antag_datum(/datum/antagonist/changeling))
		playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
		var/mob/living/carbon/firstCarbon = secondPod.occupant
		if(firstCarbon)
			firstCarbon.adjustOrganLoss(ORGAN_SLOT_BRAIN, 75, 99)
		return MINDMACHINE_UNKNOWN

	// If only one is safe, then the other one is going to have a bad time.
	var/firstSafe = FALSE
	var/secondSafe = FALSE
	if(firstOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0) || firstOccupant.key?[1] == "@" || HAS_TRAIT(firstOccupant, TRAIT_MINDSHIELD))
		firstSafe = TRUE
	if(secondOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0) || secondOccupant.key?[1] == "@" || HAS_TRAIT(secondOccupant, TRAIT_MINDSHIELD))
		secondSafe = TRUE
	
	if(firstSafe || secondSafe)
		if(!firstSafe)
			playsound(src, 'sound/machines/synth_yes.ogg', 30, TRUE)
			return MINDMACHINE_TRANSFER_NEARBYANIMAL
		else if(!secondSafe)
			playsound(src, 'sound/machines/synth_yes.ogg', 30, TRUE)
			return MINDMACHINE_TRANSFER_NEARBYANIMAL
		playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE)
		return MINDMACHINE_UNKNOWN

	if(is_type_in_typecache(firstOccupant, blacklisted_mobs) || is_type_in_typecache(secondOccupant, blacklisted_mobs))
		playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE) 
		return MINDMACHINE_UNKNOWN // No side effect.

	if(issilicon(firstOccupant) || issilicon(secondOccupant))
		playsound(src, 'sound/machines/synth_no.ogg', 30, TRUE) 
		return MINDMACHINE_UNKNOWN // No side effect.

	. = handle_mindswap(firstOccupant, secondOccupant)

#define MINDMACHINE_SENTIENT_PAIR 1
#define MINDMACHINE_SENTIENT_SOLO 2
#define MINDMACHINE_SENTIENT_NONE 3

/obj/machinery/mindmachine/hub/proc/determine_mindswap_type(mob/living/firstOccupant, mob/living/secondOccupant)
	if(!firstOccupant.key && !secondOccupant.key)
		return MINDMACHINE_SENTIENT_NONE
	if(firstOccupant.key && secondOccupant.key)
		return MINDMACHINE_SENTIENT_PAIR
	return MINDMACHINE_SENTIENT_SOLO

/obj/machinery/mindmachine/hub/proc/handle_mindswap(mob/living/firstOccupant, mob/living/secondOccupant)
	var/type = determine_mindswap_type(firstOccupant, secondOccupant)
	switch(type)
		if(MINDMACHINE_SENTIENT_NONE)
			if(!isanimal(firstOccupant) || !isanimal(secondOccupant))
				return FALSE
			mindswap_nonsentient(firstOccupant, secondOccupant)
			return TRUE
		if(MINDMACHINE_SENTIENT_SOLO)
			var/sentientOccupant = firstOccupant.key ? firstOccupant : secondOccupant
			var/nonsentientOccupant = firstOccupant.key ? secondOccupant : firstOccupant
			mindswap_sentient(sentientOccupant, nonsentientOccupant)
			return TRUE
		if(MINDMACHINE_SENTIENT_PAIR)
			mindswap_sentient(firstOccupant, secondOccupant)
			return TRUE

/obj/machinery/mindmachine/hub/proc/mindswap_nonsentient(mob/living/simple_animal/firstAnimal, mob/living/simple_animal/secondAnimal)
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

/obj/machinery/mindmachine/hub/proc/mindswap_sentient(mob/living/sentientOccupant, mob/living/otherOccupant)
	if(!otherOccupant.mind)
		otherOccupant.mind_initialize()

	var/datum/mind/sentientMind = sentientOccupant.mind
	var/datum/mind/otherMind = otherOccupant.mind
	var/otherKey = otherMind.key

	sentientMind.transfer_to(otherOccupant)
	otherMind.transfer_to(sentientOccupant)
	if(otherKey)
		sentientOccupant.key = otherKey

	SEND_SOUND(sentientMind, sound('sound/magic/mandswap.ogg'))
	SEND_SOUND(otherMind, sound('sound/magic/mandswap.ogg'))

/obj/machinery/mindmachine/pod
	name = "\improper mind machine pod"
	desc = "A large pod used for mind transfers. \
	Contains two locking systems: One for ensuring occupants do not disturb the transfer process, and another that prevents lower minded creatures from leaving on their own."
	icon_state = "pod_open"
	density = TRUE
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
	if(user.a_intent == INTENT_HELP && I.tool_behaviour == TOOL_CROWBAR && locked)
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
		hub.end_mindswapping(TRUE)
	locked = FALSE
	..(drop)
	playsound(src, 'sound/machines/decon/decon-open.ogg', 25, TRUE)
