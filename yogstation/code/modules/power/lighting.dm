/obj/machinery/light/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/redirect, list(COMSIG_COMPONENT_CLEAN_ACT= CALLBACK(src, .proc/clean_light)))

/obj/machinery/light/proc/clean_light(strength)
	if(strength < CLEAN_STRENGTH_BLOOD)
		return
	bulb_colour = initial(bulb_colour)
	update()
