/obj/machinery/mindmachine
	name = "\improper Mind Machine"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/machines/mind_machine.dmi'
	active_power_usage = 10000 // Placeholder value.
	density = TRUE

/obj/machinery/mindmachine/hub
	name = "\improper Mind Machine Hub"
	desc = "The main hub of a complete mind machine setup. Placed between two mind pods and used to control and manage the transfer. \
			Houses an experimental bluespace conduit which uses bluespace crystals for charge."
	icon_state = "hub"
	circuit = /obj/item/circuitboard/machine/mindmachine_hub
	/// The first connected mind machine pod.
	var/obj/machinery/mindmachine/pod/firstPod
	/// The second connected mind machine pod.
	var/obj/machinery/mindmachine/pod/secondPod

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
	if(I.tool_behaviour == TOOL_MULTITOOL && user.a_intent == INTENT_HELP)
		var/success = try_connect_pods()
		if(success)
			to_chat(user, span_notice("You successfully connected the [src]."))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

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

/obj/machinery/mindmachine/pod
	name = "\improper Mind Machine Pod"
	desc = "A large pod used for mind transfers. \
	Contains two locking systems: One for ensuring occupants do not disturb the transfer process, and another that prevents lower minded creatures from leaving on their own."
	icon_state = "pod_open"
	density = FALSE
	circuit = /obj/item/circuitboard/machine/mindmachine_pod
	/// The connected mind machine hub.
	var/obj/machinery/mindmachine/hub/hub

/obj/machinery/mindmachine/pod/Destroy()
	hub?.disconnect_pods()
	return ..()

/obj/machinery/mindmachine/pod/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()
