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

/obj/item/circuitboard/machine/coffeemaker
	name = "Coffeemaker (Machine Board)"
	build_path = /obj/machinery/coffeemaker
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/machine/coffeemaker/impressa
	name = "Impressa Coffeemaker"
	build_path = /obj/machinery/coffeemaker/impressa
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/glass/beaker= 2,
		/obj/item/stock_parts/capacitor/adv = 1,
		/obj/item/stock_parts/micro_laser/high = 2,
	)
