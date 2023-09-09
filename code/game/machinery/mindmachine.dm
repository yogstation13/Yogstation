#define MINDMACHINE_NO_PODS "No connected pods."
#define MINDMACHINE_NO_OCCUPANTS "Not enough occupants." // Both pods are not full.
#define MINDMACHINE_NO_CHARGE "Not enough charge." // Cost is higher than charges.
#define MINDMACHINE_NOT_LIVING_TYPE "Inorganic objects not accepted." // Something that isn't a `/mob/living` is an occupant.
#define MINDMACHINE_RESIST_MIND "An occupant has mind resistance." // Mind resistance (or special exception).
#define MINDMACHINE_TOTAL_LOW_IQ "Unable to swap upward." // No swapping from non-sentient animal to non-sentient human.
#define MINDMACHINE_SUCCESS "Success!"

/obj/machinery/mindmachine
	name = "\improper mind machine"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/machines/mind_machine.dmi'
	active_power_usage = 10000 // Placeholder value.
	density = TRUE

/obj/machinery/mindmachine/hub
	name = "\improper mind machine hub"
	desc = "The main hub of a complete mind machine setup. Placed between two mind pods and used to control and manage the transfer. \
			Houses an experimental bluespace conduit which uses bluespace crystals for charge."
	icon_state = "hub"
	circuit = /obj/item/circuitboard/machine/mindmachine_hub
	/// A list of mobs that cannot be swapped to/from.
	var/list/blacklisted_mobs = typecacheof(list(
		/mob/living/simple_animal/slaughter,
		/mob/living/simple_animal/hostile/retaliate/goat/king
		/mob/living/simple_animal/hostile/megafauna
	))
	/// The first connected mind machine pod.
	var/obj/machinery/mindmachine/pod/firstPod
	/// The second connected mind machine pod.
	var/obj/machinery/mindmachine/pod/secondPod
	/// How much charges does this hub have?
	var/charges = 0
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

/obj/machinery/mindmachine/hub/attackby(obj/item/I, mob/user, params)
	// Connection
	if(user.a_intent == INTENT_HELP && I.tool_behaviour == TOOL_MULTITOOL)
		var/success = try_connect_pods()
		if(success)
			to_chat(user, span_notice("You successfully connected the [src]."))
		return
	// Charge Increase
	var/charge_increase = try_increase_charge(I, user)
	if(!isnull(charge_increase)) // Not null = interaction.
		if(charge_increase)
			to_chat(user, span_notice("You increased [src]'s charge by [charge_increase] charges."))
			playsound(src, 'sound/machines/ping.ogg', 100)
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
	if(!firstPod || !secondPod)
		user.balloon_alert(user, "not connected")
		playsound(src, 'sound/machines/synth_no.ogg', 10, TRUE)
		return
	if(!firstPod.occupant || !secondPod.occupant)
		user.balloon_alert(user, "not enough occupants")
		playsound(src, 'sound/machines/synth_no.ogg', 10, TRUE)
		return
	var/string_response = try_mindswap()
	visible_message(span_warning("[string_response]"))

/obj/machinery/mindmachine/hub/AltClick(mob/user)
	// DEBUGGING ONLY: REMOVE AT THE END
	var/string_response = try_mindswap()
	visible_message(span_warning("[string_response]"))

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

/obj/machinery/mindmachine/hub/proc/try_increase_charge(obj/item/I, mob/user)
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
	
	if(!increase_per)
		return // Intentional null.
	if(!user.temporarilyRemoveItemFromInventory(I))
		to_chat(user, span_warning("[I] is stuck to your hand!"))
		return FALSE
	var/obj/item/stack/stack_item = I // Only accepting stacks for now.
	if(!stack_item)
		return FALSE
	var/amt = stack_item.get_amount()
	if(amt >= 1 && stack_item.use(amt)) // Going to take it all.
		var/final_increase = increase_per * amt
		charges += final_increase
		return final_increase
	return FALSE

/obj/machinery/mindmachine/hub/proc/try_mindswap()
	// Basic Checks
	if(!firstPod || !secondPod)
		return MINDMACHINE_NO_PODS
	if(!firstPod.occupant || !secondPod.occupant)
		return MINDMACHINE_NO_OCCUPANTS
	if(cost > charges)
		return MINDMACHINE_NO_CHARGE
	var/mob/living/firstOccupant = firstPod.occupant
	var/mob/living/secondOccupant = secondPod.occupant
	if(firstOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0) || secondOccupant.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		return MINDMACHINE_RESIST_MIND
	if(firstOccupant.key?[1] == "@" || secondOccupant.key?[1] == "@")
		return MINDMACHINE_RESIST_MIND
	if(is_type_in_typecache(firstOccupant, blacklisted_mobs) || is_type_in_typecache(secondOccupant, blacklisted_mobs))
		return MINDMACHINE_RESIST_MIND
	if(issilicon(firstOccupant) || issilicon(secondOccupant)) // TODO: Allow silicons to mindswap at T4 parts. However, disallow swapping with unused boris shells!
		return MINDMACHINE_RESIST_MIND
	// Checks from wizard's mind swapping:
	if(firstOccupant.mind?.has_antag_datum(/datum/antagonist/wizard) || secondOccupant.mind?.has_antag_datum(/datum/antagonist/wizard))
		return MINDMACHINE_RESIST_MIND
	if(firstOccupant.mind?.has_antag_datum(/datum/antagonist/cult) || secondOccupant.mind?.has_antag_datum(/datum/antagonist/cult))
		return MINDMACHINE_RESIST_MIND	
	if(firstOccupant.mind?.has_antag_datum(/datum/antagonist/changeling) || secondOccupant.mind?.has_antag_datum(/datum/antagonist/changeling))
		return MINDMACHINE_RESIST_MIND
	if(firstOccupant.mind?.has_antag_datum(/datum/antagonist/rev) || secondOccupant.mind?.has_antag_datum(/datum/antagonist/rev))
		return MINDMACHINE_RESIST_MIND

	// Non-Sentient vs. Non-Sentient
	if(!firstOccupant.key && !secondOccupant.key)
		if(!isanimal(firstOccupant) || !isanimal(secondOccupant))
			return MINDMACHINE_TOTAL_LOW_IQ // Only accepting animal to animal transfers.
		var/mob/living/simple_animal/firstAnimal = firstOccupant
		var/mob/living/simple_animal/secondAnimal = secondOccupant
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
		charges -= cost
		return MINDMACHINE_SUCCESS

	// Sentient vs. Sentient:
	if(firstOccupant.key && secondOccupant.key)
		// Now the mind transferring:
		var/datum/mind/firstMind = firstOccupant.mind
		var/datum/mind/secondMind = secondOccupant.mind
		var/secondKey = secondMind.key

		firstMind.transfer_to(secondOccupant)
		secondMind.transfer_to(firstOccupant)
		if(secondKey)
			firstOccupant.key = secondKey

		SEND_SOUND(firstOccupant, sound('sound/magic/mandswap.ogg'))
		SEND_SOUND(secondOccupant, sound('sound/magic/mandswap.ogg'))

		charges -= cost
		return MINDMACHINE_SUCCESS
	
	// Sentient vs. Non-Sentient
	var/mob/living/sentientOccupant
	var/mob/living/nonsentientOccupant
	if(firstOccupant.key)
		sentientOccupant = firstOccupant
		nonsentientOccupant = secondOccupant
	else
		sentientOccupant = secondOccupant
		nonsentientOccupant = firstOccupant
	
	if(!nonsentientOccupant.mind)
		nonsentientOccupant.mind_initialize()

	var/datum/mind/sentientMind = sentientOccupant.mind
	var/datum/mind/nonsentientMind = nonsentientOccupant.mind
	var/nonsentientKey = nonsentientMind.key

	sentientMind.transfer_to(nonsentientOccupant)
	nonsentientMind.transfer_to(sentientOccupant)
	if(nonsentientKey)
		sentientOccupant.key = nonsentientKey

	SEND_SOUND(sentientMind, sound('sound/magic/mandswap.ogg'))
	SEND_SOUND(nonsentientMind, sound('sound/magic/mandswap.ogg'))

	charges -= cost
	return MINDMACHINE_SUCCESS

/obj/machinery/mindmachine/pod
	name = "\improper mind machine pod"
	desc = "A large pod used for mind transfers. \
	Contains two locking systems: One for ensuring occupants do not disturb the transfer process, and another that prevents lower minded creatures from leaving on their own."
	icon_state = "pod_open"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/mindmachine_pod
	/// The connected mind machine hub.
	var/obj/machinery/mindmachine/hub/hub

/obj/machinery/mindmachine/pod/Initialize(mapload)
	. = ..()
	occupant_typecache = GLOB.typecache_living

/obj/machinery/mindmachine/pod/update_icon_state()
	switch(state_open)
		if(TRUE)
			icon_state = "pod_open"
		else
			icon_state = "pod_closed"
	return ..()

/obj/machinery/mindmachine/pod/Destroy()
	hub?.disconnect_pods()
	return ..()

/obj/machinery/mindmachine/pod/attackby(obj/item/I, mob/user, params)
	if(!occupant)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
			return
		if(default_deconstruction_crowbar(I))
			return
	return ..()

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
	if(panel_open)
		to_chat(user, span_notice("Close the maintenance panel first."))
		return
	if(do_after(user, 3 SECONDS, dropped))
		if(dropped == user)
			user.visible_message(span_warning("[user] enters the [src] and closes the door behind [user.p_them()]!"))
		else
			dropped.visible_message(span_warning("[user] puts [dropped] into the [src]."))
		close_machine(dropped)

/obj/machinery/mindmachine/pod/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
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
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!")) // TODO: Change this up away from sleeper's code.
	open_machine()

/obj/machinery/mindmachine/pod/close_machine(atom/movable/target)
	..(target)
	playsound(src, 'sound/machines/decon/decon-close.ogg', 25, TRUE)

/obj/machinery/mindmachine/pod/open_machine(drop)
	..(drop)
	playsound(src, 'sound/machines/decon/decon-open.ogg', 25, TRUE)
