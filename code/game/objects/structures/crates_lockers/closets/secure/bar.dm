/obj/structure/closet/secure_closet/bar
	name = "secure closet"
	req_access = list(ACCESS_BAR)
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	door_anim_time = 0 // no animation

/obj/structure/closet/secure_closet/bar/PopulateContents()
	..()
	var/static/items_inside = list(
		/obj/item/clothing/accessory/waistcoat = 2,
		/obj/item/reagent_containers/glass/rag = 2,
		/obj/item/reagent_containers/food/drinks/beer/light = 4) //now in closet rather than on a table
	generate_items_inside(items_inside,src)
