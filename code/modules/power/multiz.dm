/obj/machinery/power/deck_relay //This bridges powernets betwen Z levels
	name = "Multi-deck power adapter"
	desc = "A huge bundle of double insulated cabling which seems to run up into the ceiling."
	icon = 'icons/obj/power.dmi'
	icon_state = "cablerelay-off"
	///The relay that's below us (for bridging powernets)
	var/obj/machinery/power/deck_relay/below
	///The relay that's above us (for bridging powernets)
	var/obj/machinery/power/deck_relay/above
	anchored = TRUE
	density = FALSE

/obj/machinery/power/deck_relay/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(find_relays)), 30)
	//Wait a bit so we can find the one below, then get powering
	addtimer(CALLBACK(src, PROC_REF(refresh)), 50)

/obj/machinery/power/deck_relay/attackby(obj/item/I,mob/user)
	if(default_unfasten_wrench(user, I))
		return FALSE
	. = ..()

/obj/machinery/power/deck_relay/process()
	if(!anchored)
		icon_state = "cablerelay-off"
		if(above) //Lose connections
			above.below = null
		if(below)
			below.above = null
		return
	refresh() //Sometimes the powernets get lost, so we need to keep checking.
	if(powernet && (powernet.avail <= 0))		// is it powered?
		icon_state = "cablerelay-off"
	else
		icon_state = "cablerelay-on"
	if(!below || QDELETED(below) || !above || QDELETED(above))
		icon_state = "cablerelay-off"
		find_relays()

///Allows you to scan the relay with a multitool to see stats.
/obj/machinery/power/deck_relay/multitool_act(mob/user, obj/item/I)
	if(powernet && (powernet.avail > 0))		// is it powered?
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
	if(!powernet || below.powernet != powernet)
		icon_state = "cablerelay-off"
		to_chat(user, "<span class='danger'>Powernet connection lost. Attempting to re-establish. Ensure the relays below this one are connected too.</span>")
		find_relays()
		addtimer(CALLBACK(src, PROC_REF(refresh)), 20) //Wait a bit so we can find the one below, then get powering
	return TRUE

///Handles re-acquiring + merging powernets found by find_relays()
/obj/machinery/power/deck_relay/proc/refresh()
	if(above)
		above.merge(src)
	if(below)
		below.merge(src)

/obj/machinery/power/deck_relay/proc/merge(obj/machinery/power/deck_relay/relay)
	if(!relay)
		return
	var/turf/merge_from = get_turf(relay)
	var/turf/merge_to = get_turf(src)
	var/obj/structure/cable/cable_merge_from = merge_from.get_cable_node()
	var/obj/structure/cable/cable_merge_to = merge_to.get_cable_node()
	if(cable_merge_from && cable_merge_to)
		merge_powernets(cable_merge_to.powernet, cable_merge_from.powernet)//Bridge the powernets.

///Locates relays that are above and below this object
/obj/machinery/power/deck_relay/proc/find_relays()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return FALSE
	below = null //in case we're re-establishing
	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	if(C && C.powernet)
		C.powernet.add_machine(src) //Nice we're in.
		powernet = C.powernet
	below = locate(/obj/machinery/power/deck_relay) in (GET_TURF_BELOW(T))
	above = locate(/obj/machinery/power/deck_relay) in (GET_TURF_ABOVE(T))
	if(below || above)
		icon_state = "cablerelay-on"
	return TRUE
