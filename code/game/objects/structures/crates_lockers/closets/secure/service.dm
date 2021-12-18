/obj/structure/closet/secure_closet/bartender
	name = "bartender's closet"
	desc = "It's a secure storage unit for the bartender's supplies."
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "barkeep"
	req_access = list(ACCESS_BAR)
/obj/structure/closet/secure_closet/bartender/PopulateContents()
	..()
	var/static/items_inside = list(
		/obj/item/clothing/head/that = 2,
		/obj/item/radio/headset/headset_srv = 2,
		/obj/item/clothing/under/sl_suit = 2,
		/obj/item/clothing/under/rank/bartender = 2,
		/obj/item/clothing/accessory/waistcoat = 2,
		/obj/item/clothing/head/soft/black = 2,
		/obj/item/clothing/shoes/sneakers/black = 2,
		/obj/item/reagent_containers/glass/rag = 2,
		/obj/item/storage/box/beanbag = 1,
		/obj/item/clothing/suit/armor/vest/alt = 1,
		/obj/item/circuitboard/machine/dish_drive = 1,
		/obj/item/clothing/glasses/sunglasses/reagent = 1,
		/obj/item/clothing/neck/petcollar = 1,
		/obj/item/storage/belt/bandolier = 1,
		/obj/item/gun/ballistic/shotgun/doublebarrel = 1) //now in closet rather than on a table
	generate_items_inside(items_inside,src)