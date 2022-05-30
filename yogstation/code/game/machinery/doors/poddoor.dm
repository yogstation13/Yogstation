/obj/machinery/door/poddoor/multi_tile
	name = "large pod door"
	layer = CLOSED_DOOR_LAYER
	closingLayer = CLOSED_DOOR_LAYER

/obj/machinery/door/poddoor/multi_tile/New()
	. = ..()
	apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/poddoor/multi_tile/open()
	if(..())
		apply_opacity_to_my_turfs(opacity)


/obj/machinery/door/poddoor/multi_tile/close()
	if(..())
		apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/poddoor/multi_tile/Destroy()
	apply_opacity_to_my_turfs(0)
	return ..()

//Multi-tile poddoors don't turn invisible automatically, so we change the opacity of the turfs below instead one by one.
/obj/machinery/door/poddoor/multi_tile/proc/apply_opacity_to_my_turfs(var/new_opacity)
	for(var/turf/T in locs)
		T.opacity = new_opacity
		T.has_opaque_atom = new_opacity
		T.reconsider_lights()
		T.air_update_turf()
	update_freelook_sight()

/obj/machinery/door/poddoor/multi_tile/four_tile_ver/
	icon = 'yogstation/icons/obj/doors/1x4blast_vert.dmi'
	bound_height = 128
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/three_tile_ver/
	icon = 'yogstation/icons/obj/doors/1x3blast_vert.dmi'
	bound_height = 96
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/two_tile_ver/
	icon = 'yogstation/icons/obj/doors/1x2blast_vert.dmi'
	bound_height = 64
	dir = NORTH

/obj/machinery/door/poddoor/multi_tile/four_tile_hor/
	icon = 'yogstation/icons/obj/doors/1x4blast_hor.dmi'
	bound_width = 128
	dir = EAST

/obj/machinery/door/poddoor/multi_tile/three_tile_hor/
	icon = 'yogstation/icons/obj/doors/1x3blast_hor.dmi'
	bound_width = 96
	dir = EAST

/obj/machinery/door/poddoor/multi_tile/two_tile_hor/
	icon = 'yogstation/icons/obj/doors/1x2blast_hor.dmi'
	bound_width = 64
	dir = EAST
