/obj/machinery/light/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_light)

/obj/machinery/light/proc/clean_light(O,strength)
	if(strength < CLEAN_TYPE_BLOOD)
		return
	bulb_colour = initial(bulb_colour)
	update()
