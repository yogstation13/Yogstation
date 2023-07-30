
#define AI_MACHINE_TOO_HOT			"Environment too hot"
#define AI_MACHINE_NO_MOLES			"Environment lacks an atmosphere"

/obj/machinery/ai
	name = "You shouldn't see this!"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE
	var/core_temp = 193.15

/obj/machinery/ai/Initialize(mapload)
	. = ..()
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

/obj/machinery/ai/proc/valid_holder()
	if(stat & (BROKEN|EMPED) || !has_power())
		return FALSE
	if(core_temp > GLOB.ai_os.get_temp_limit())
		return FALSE
	return TRUE

/obj/machinery/ai/proc/has_power()
	return !(stat & (NOPOWER))

/obj/machinery/ai/proc/get_holder_status()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE
	if(core_temp > GLOB.ai_os.get_temp_limit())
		return AI_MACHINE_TOO_HOT
	