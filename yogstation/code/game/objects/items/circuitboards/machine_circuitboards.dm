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

/obj/item/circuitboard/machine/disposal_bluespace
	name = "Disposals Teleporter Attachment (Machine Board)"
	build_path = /obj/machinery/disposal_bluespace
	needs_anchored = FALSE
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)
