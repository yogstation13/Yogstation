
#define AI_MACHINE_TOO_HOT			"Environment too hot"
#define AI_MACHINE_NO_MOLES			"Environment lacks an atmosphere"

/obj/machinery/ai
	name = "You shouldn't see this!"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE

/obj/machinery/ai/Initialize(mapload)
	. = ..()
	
	SSair.atmos_machinery += src 
	
/obj/machinery/ai/Destroy()
	. = ..()
	
	SSair.atmos_machinery -= src 

/obj/machinery/ai/proc/valid_holder()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE
	
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return FALSE
	var/total_moles = env.total_moles()
	if(istype(T, /turf/open/space) || total_moles < 10)
		return FALSE
	
	if(env.return_temperature() > GLOB.ai_os.get_temp_limit() || !env.heat_capacity())
		return FALSE
	return TRUE

/obj/machinery/ai/proc/get_holder_status()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE
	
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return AI_MACHINE_NO_MOLES
	var/total_moles = env.total_moles()
	if(istype(T, /turf/open/space) || total_moles < 10)
		return AI_MACHINE_NO_MOLES
	
	if(env.return_temperature() > GLOB.ai_os.get_temp_limit() || !env.heat_capacity())
		return AI_MACHINE_TOO_HOT
	