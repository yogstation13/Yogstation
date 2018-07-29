/datum/maploader/create_atom(path, crds, stationroom = FALSE)
	. = ..()
	if(stationroom && istype(., /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/atmosmac = .
		atmosmac.on_construction(atmosmac.pipe_color, atmosmac.piping_layer)
