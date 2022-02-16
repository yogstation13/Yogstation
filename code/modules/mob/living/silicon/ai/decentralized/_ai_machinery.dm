
/obj/machinery/ai
	name = "You shouldn't see this!"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE

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
	
	if(env.return_temperature() > AI_TEMP_LIMIT || !env.heat_capacity())
		return FALSE
	return TRUE
