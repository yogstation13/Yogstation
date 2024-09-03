/datum/supply_pack/misc/cleancanvas
	name = "Canvas Supply Pack"
	desc = "A selection of writing surfaces for the artistically inclined"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/chisel,
					/obj/item/canvas/twentyfour_twentyfour = 2,
					/obj/item/canvas/nineteen_nineteen,
					/obj/item/canvas/twentythree_nineteen,
					/obj/item/canvas/twentythree_twentythree = 2,
					/obj/item/canvas/thirtysix_twentyfour,
					/obj/item/canvas/fortyfive_twentyseven,
					/obj/item/wallframe/painting/large = 2,
					/obj/item/paint_palette,
					/obj/structure/easel)
	crate_name = "Canvas Crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/anvilcrate
	name = "Deluxe Smithing Kit"
	desc = "A kit containing everything you need for smithing, even using custom materials!"
	cost = CARGO_CRATE_VALUE * 40
	contains = list(
		/obj/structure/anvil,
		/obj/structure/machine/assembly_bench,
		/obj/item/circuitboard/machine/material_alloyer,
		/obj/item/circuitboard/machine/electroplater,
		/obj/item/circuitboard/machine/material_analyzer
	)
	crate_name = "Deluxe Smithing Crate"
	crate_type = /obj/structure/closet/crate/large
/datum/supply_pack/misc/anvilcratesmol
	name = "Starter Smithing Kit"
	desc = "A kit containing the basic structures for hobby smithing! Materials not included."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(
		/obj/structure/anvil,
		/obj/structure/machine/assembly_bench
	)
	crate_name = "Basic Smithing Crate"
	crate_type = /obj/structure/closet/crate/large
