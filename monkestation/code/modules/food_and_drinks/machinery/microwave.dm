/obj/machinery/microwave
	var/dont_eject_after_done = FALSE
	var/can_eject = TRUE

/obj/machinery/microwave/eject(force = FALSE)
	if (!can_eject && !force)
		return
	. = ..()


/obj/machinery/microwave/on_deconstruction()
	eject(force = TRUE)
	return ..()

/obj/machinery/microwave/after_finish_loop(dontopen = FALSE)
	set_light(0)
	soundloop.stop()
	if (!dontopen)
		open()
	else
		update_appearance()
