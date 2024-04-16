//4-Way Manifold

/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-3"

	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes."

	initialize_directions = ALL_CARDINALS

	device_type = QUATERNARY

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"

	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_MANIFOLD4W,\
		pipe_interference_group = "atmos-[piping_layer]"\
	)

/obj/machinery/atmospherics/pipe/manifold4w/New(mapload)
	icon_state = ""
	return ..()

/obj/machinery/atmospherics/pipe/manifold4w/set_init_directions()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/manifold4w/update_overlays()
	. = ..()
	var/mutable_appearance/center = mutable_appearance(icon, "manifold4w_center")
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	. += center

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += get_pipe_image(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))

	update_layer()
	update_alpha()
