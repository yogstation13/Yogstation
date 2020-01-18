// Vertical Pipe

/obj/machinery/atmospherics/pipe/upward
	icon = 'icons/obj/atmospherics/pipes/multiz.dmi'
	icon_state = "pipe-1u-2"

	name = "upward pipe bend"
	desc = "A one meter section of regular pipe which bends upward."

	dir = SOUTH
	initialize_directions = SOUTH|UP
	density = 1

	device_type = BINARY

	construction_type = /obj/item/pipe/directional
	pipe_state = "upward"

// this one gets a vertical parallax component
/obj/machinery/atmospherics/pipe/upward/Initialize(mapload)
	AddComponent(/datum/component/vertical_parallax/pipe)
	return ..()

/obj/machinery/atmospherics/pipe/upward/SetInitDirections()
	initialize_directions = dir|UP

/obj/machinery/atmospherics/pipe/upward/update_icon()
	icon_state = "pipe-[nodes[1] ? "1" : "0"]u-[piping_layer]"
	update_layer()
	update_alpha()

/obj/machinery/atmospherics/pipe/downward
	icon = 'icons/obj/atmospherics/pipes/multiz.dmi'
	icon_state = "pipe-1d-2"

	name = "downward pipe bend"
	desc = "A one meter section of regular pipe which bends downward."

	dir = SOUTH
	initialize_directions = SOUTH|DOWN

	device_type = BINARY

	construction_type = /obj/item/pipe/directional
	pipe_state = "downward"

/obj/machinery/atmospherics/pipe/downward/SetInitDirections()
	initialize_directions = dir|DOWN

/obj/machinery/atmospherics/pipe/downward/update_icon()
	icon_state = "pipe-[nodes[1] ? "1" : "0"]d-[piping_layer]"
	update_layer()
	update_alpha()
