/obj/machinery/smartfridge
	/// The tgui theme to use. Default is null, which means the Nanotrasen theme is used.
	var/tgui_theme = null

/obj/machinery/smartfridge/ui_static_data(mob/user)
	return list("ui_theme" = tgui_theme)

/obj/machinery/smartfridge/assault
	name = "smart chemical storage"
	desc = "A refrigerated storage unit for curing a few dire aliments."

/obj/machinery/smartfridge/assault/preloaded
	initial_contents = list(
		/obj/item/reagent_containers/pill/epinephrine = 12,
		/obj/item/reagent_containers/pill/multiver = 5,
		/obj/item/reagent_containers/cup/bottle/epinephrine = 1,
		/obj/item/reagent_containers/cup/bottle/multiver = 1,
		/obj/item/reagent_containers/cup/bottle/formaldehyde,
		/obj/item/reagent_containers/cup/beaker/large/synthflesh = 2,
		/obj/item/reagent_containers/cup/beaker/large/plasma = 2,)
