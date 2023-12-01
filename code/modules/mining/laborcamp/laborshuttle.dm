/obj/machinery/computer/shuttle/labour
	name = "labour shuttle console"
	desc = "Used to call and send the labour camp shuttle."
	circuit = /obj/item/circuitboard/computer/labour_shuttle
	shuttleId = "labourcamp"
	possible_destinations = "labourcamp_home;labourcamp_away"
	req_access = list(ACCESS_BRIG)


/obj/machinery/computer/shuttle/labour/one_way
	name = "prisoner shuttle console"
	desc = "A one-way shuttle console, used to summon the shuttle to the labour camp."
	possible_destinations = "labourcamp_away"
	circuit = /obj/item/circuitboard/computer/labour_shuttle/one_way
	req_access = list( )

/obj/machinery/computer/shuttle/labour/one_way/launch_check(mob/user)
	. = ..()
	if(!.)
		return FALSE
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle("labourcamp")
	if(!M)
		to_chat(user, span_warning("Cannot locate shuttle!"))
		return FALSE
	var/obj/docking_port/stationary/S = M.get_docked()
	if(S?.name == "labourcamp_away")
		to_chat(user, span_warning("Shuttle is already at the outpost!"))
		return FALSE
	return TRUE
