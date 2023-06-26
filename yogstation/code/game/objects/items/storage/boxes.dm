/obj/item/storage/box/goatcubes
	name = "goat cube box"
	desc = "Goat Tech Industries' latest creation to help make experimenting on goats easier. Just add water!"
	icon_state = "monkeycubebox"
	illustration = null

/obj/item/storage/box/goatcubes/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 4
	STR.can_hold = typecacheof(list(/obj/item/reagent_containers/food/snacks/monkeycube))

/obj/item/storage/box/goatcubes/PopulateContents()
	for(var/i in 2 to 4)
		new /obj/item/reagent_containers/food/snacks/monkeycube/goat(src)
