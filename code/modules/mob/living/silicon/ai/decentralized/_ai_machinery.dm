
#define AI_MACHINE_TOO_HOT				"Environment too hot"
#define AI_MACHINE_NO_MOLES				"Environment lacks an atmosphere"
#define AI_MACHINE_NO_NETWORK			"Lacks a network connection"
#define AI_MACHINE_BROKEN_NOPOWER_EMPED	"Either broken, out of power or EMPed"

/obj/machinery/ai
	name = "You shouldn't see this!"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE
	///Temperature of the ai core itself, this will share with air in the enviroment
	var/core_temp = 193.15

	var/datum/ai_network/network

/obj/machinery/ai/Initialize(mapload)
	. = ..()
	connect_to_ai_network()
	START_PROCESSING(SSmachines, src)
	SSair.start_processing_machine(src)

//Cooling happens here
/obj/machinery/ai/process_atmos()
	var/turf/T = get_turf(src)
	if(!T)
		return
	if(isspaceturf(T))
		return
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return
	var/new_temp = env.temperature_share(AI_HEATSINK_COEFF, core_temp, AI_HEATSINK_CAPACITY)
	core_temp = new_temp
	
/obj/machinery/ai/Destroy()
	. = ..()
	SSair.stop_processing_machine(src)
	STOP_PROCESSING(SSmachines, src)
	disconnect_from_ai_network()

/obj/machinery/ai/proc/valid_holder()
	if(!network)
		return FALSE
	if(stat & (BROKEN|EMPED) || !has_power())
		return FALSE
	if(core_temp > network.get_temp_limit())
		return FALSE
	return TRUE

/obj/machinery/ai/proc/has_power()
	return !(stat & (NOPOWER))

/obj/machinery/ai/proc/get_holder_status()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return AI_MACHINE_BROKEN_NOPOWER_EMPED
	if(!network)
		return AI_MACHINE_NO_NETWORK
	if(core_temp > network.get_temp_limit())
		return AI_MACHINE_TOO_HOT
	

/obj/machinery/ai/proc/connect_to_ai_network()
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/ethernet_cable/C = T.get_ai_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	if(!C || !C.network)
		return FALSE

	C.network.add_machine(src)
	return TRUE

// remove and disconnect the machine from its current powernet
/obj/machinery/ai/proc/disconnect_from_ai_network()
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
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE || !isfloorturf(T))
			return
		if(get_dist(src, user) > 1)
			return
		coil.place_turf(T, user)
	else
		return ..()

/obj/ai_smoke
	name = "smoke"
	desc = "Very hot!"

/obj/ai_smoke/Initialize(mapload)
	. = ..()
	particles = new /particles/smoke/ai()

/obj/ai_smoke/Destroy(force)
	QDEL_NULL(particles)
	. = ..()

/particles/smoke/ai
	grow = 0.1
	height = 75
	lifespan = 1.25 SECONDS
	position = list(0, 0, 0)
	velocity = list(0, 0.15, 0)
