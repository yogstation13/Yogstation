/obj/item/circuitboard/machine/vendor/screwdriver_act(mob/living/user, obj/item/I)
	var/list/icons = list()
	var/list/inverse = list()
	for(var/V in vending_names_paths)
		var/obj/machinery/vending/n = V
		icons[vending_names_paths[n]] = image(icon = initial(n.icon), icon_state = initial(n.icon_state))
		inverse[vending_names_paths[n]] = n

	var/type = show_radial_menu(user, src, icons, radius = 42)

	if(type)
		set_type(inverse[type])

	return TRUE

/obj/item/circuitboard/machine/pressure
	name = "circuit board (Pressurized reaction vessel)"
	build_path = /obj/machinery/chem/pressure
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/machine/centrifuge
	name = "circuit board (Centrifuge)"
	build_path = /obj/machinery/chem/centrifuge
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stock_parts/scanning_module = 2,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/machine/radioactive
	name = "circuit board (Radioactive molecular reassembler)"
	build_path = /obj/machinery/chem/radioactive
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/capacitor = 5,
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/micro_laser = 3,
							/obj/item/stock_parts/scanning_module = 4,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/machine/bluespace
	name = "circuit board (Bluespace recombobulator)"
	build_path = /obj/machinery/chem/bluespace
	req_components = list(
							/obj/item/stock_parts/matter_bin = 3,
							/obj/item/stock_parts/capacitor = 10,
							/obj/item/stock_parts/manipulator = 5,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/micro_laser = 5,
							/obj/item/stock_parts/scanning_module = 4,
							/obj/item/stack/ore/bluespace_crystal = 3,//this thing is an utter SHIT to make
							/obj/item/stock_parts/cell = 1)