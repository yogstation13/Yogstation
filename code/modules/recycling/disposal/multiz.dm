/obj/structure/disposalpipe/upward
	name = "upward disposal pipe"
	icon_state = "pipe-up"
	initialize_dirs = DISP_DIR_UP
	density = 1

// this one gets a vertical parallax component
/obj/structure/disposalpipe/upward/Initialize(mapload)
	AddComponent(/datum/component/vertical_parallax/disposal)
	return ..()

/obj/structure/disposalpipe/downward
	name = "downward disposal pipe"
	icon_state = "pipe-down"
	initialize_dirs = DISP_DIR_DOWN

/obj/structure/disposalpipe/vertical
	name = "vertical disposal pipe"
	icon_state = "cap"
	initialize_dirs = DISP_DIR_UP | DISP_DIR_NONE | DISP_DIR_DOWN
	density = 1

// this one gets a vertical parallax component too
/obj/structure/disposalpipe/vertical/Initialize(mapload)
	AddComponent(/datum/component/vertical_parallax/disposal)
	return ..()
