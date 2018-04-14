/obj/structure/closet/wardrobe/tcomms
	name = "signal tech wardrobe"
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "sigtech"
	icon_door = "sigtech"

/obj/structure/closet/wardrobe/tcomms/PopulateContents()
	..()
	contents = list()
	new /obj/item/storage/backpack/duffelbag/engineering(src)
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/storage/backpack/satchel/eng(src)
	new /obj/item/clothing/suit/hooded/wintercoat/engineering/tcomms(src)
	new /obj/item/clothing/under/yogs/rank/signal_tech(src)
	new /obj/item/clothing/shoes/workboots(src)