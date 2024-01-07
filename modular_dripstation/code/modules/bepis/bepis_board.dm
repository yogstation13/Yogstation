/datum/design/board/bepis
	name = "B.E.P.I.S. Board"
	desc = "The circuit board for a B.E.P.I.S."
	id = "bepis"
	build_path = /obj/item/circuitboard/machine/bepis
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/obj/item/circuitboard/machine/bepis
	name = "BEPIS Chamber"
	icon_state = "supply"
	build_path = /obj/machinery/rnd/bepis
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/scanning_module = 1)