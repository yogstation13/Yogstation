
#define AI_MACHINE_TOO_HOT			"Environment too hot"
#define AI_MACHINE_NO_MOLES			"Environment lacks an atmosphere"

/obj/machinery/ai
	name = "You shouldn't see this!"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE

	var/datum/ai_network/network

/obj/machinery/ai/Initialize(mapload)
	. = ..()
	
	SSair.atmos_machinery += src 
	connect_to_network()
	
/obj/machinery/ai/Destroy()
	. = ..()
	disconnect_from_network()
	SSair.atmos_machinery -= src 

/obj/machinery/ai/proc/valid_holder()
	if(!network)
		return FALSE
	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE
	
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return FALSE
	var/total_moles = env.total_moles()
	if(istype(T, /turf/open/space) || total_moles < 10)
		return FALSE
	
	if(env.return_temperature() > network.get_temp_limit() || !env.heat_capacity())
		return FALSE
	return TRUE

/obj/machinery/ai/proc/get_holder_status()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE
	if(!network)
		return FALSE
	
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return AI_MACHINE_NO_MOLES
	var/total_moles = env.total_moles()
	if(istype(T, /turf/open/space) || total_moles < 10)
		return AI_MACHINE_NO_MOLES
	
	if(env.return_temperature() > network.get_temp_limit() || !env.heat_capacity())
		return AI_MACHINE_TOO_HOT
	

/obj/machinery/ai/proc/connect_to_network()
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/ethernet_cable/C = T.get_ai_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	if(!C || !C.network)
		return FALSE

	C.network.add_machine(src)
	return TRUE

// remove and disconnect the machine from its current powernet
/obj/machinery/ai/proc/disconnect_from_network()
	if(!network)
		return FALSE
	network.remove_machine(src)
	return TRUE

// attach a wire to a power machine - leads from the turf you are standing on
//almost never called, overwritten by all power machines but terminal and generator
/obj/machinery/ai/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ethernet_coil))
		var/obj/item/stack/ethernet_coil/coil = W
		var/turf/T = user.loc
		if(T.intact || !isfloorturf(T))
			return
		if(get_dist(src, user) > 1)
			return
		coil.place_turf(T, user)
	else
		return ..()
