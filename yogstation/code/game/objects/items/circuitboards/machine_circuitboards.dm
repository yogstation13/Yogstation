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

/obj/item/circuitboard/machine/fishing
	name = "Fishing Machine (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/fishing
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 3,
		/obj/item/stock_parts/matter_bin = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chummer
	name = "Chummer (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/chummer
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE
