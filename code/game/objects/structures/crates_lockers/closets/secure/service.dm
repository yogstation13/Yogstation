/obj/structure/closet/secure_closet/bartender
	name = "bartender's closet"
	desc = "It's a secure storage unit for the bartender's supplies."
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "barkeep"
	req_access = list(ACCESS_BAR)
/obj/structure/closet/secure_closet/bartender/PopulateContents()
	..()
	var/static/items_inside = list(
		/obj/item/clothing/accessory/waistcoat = 2,
		/obj/item/reagent_containers/glass/rag = 2,
		/obj/item/reagent_containers/food/drinks/beer/light = 4) //now in closet rather than on a table
	generate_items_inside(items_inside,src)
