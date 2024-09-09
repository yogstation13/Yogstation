/obj/item/circuitboard/machine/brm
	name = "Boulder Retrieval Matrix"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/bouldertech/brm
	req_components = list(
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/refinery
	name = "Boulder Refinery"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/bouldertech/refinery
	req_components = list(
		/obj/item/reagent_containers/cup/beaker = 1,
		/obj/item/assembly/igniter/condenser = 1,
		/datum/stock_part/manipulator = 2,
		/datum/stock_part/matter_bin = 1,
	)

/obj/item/circuitboard/machine/smelter
	name = "Boulder Smelter"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/bouldertech/refinery/smelter
	req_components = list(
		/obj/item/assembly/igniter = 1,
		/datum/stock_part/manipulator = 2,
		/datum/stock_part/matter_bin = 2,
	)

/obj/item/circuitboard/machine/big_manipulator
	name = "Big Manipulator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/big_manipulator
	req_components = list(
		/datum/stock_part/manipulator = 1,
		)

/obj/item/circuitboard/machine/assembler
	name = "Assembler"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/assembler
	req_components = list(
		/datum/stock_part/manipulator = 1,
		)
