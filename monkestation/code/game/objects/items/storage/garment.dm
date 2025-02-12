/obj/item/storage/bag/garment/brig_physician
	name = "brig physician's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the brig physician."

/obj/item/storage/bag/garment/brig_physician/PopulateContents()
	new /obj/item/clothing/under/rank/security/brig_physician(src)
	new /obj/item/clothing/under/rank/security/brig_physician/skirt(src)
	new /obj/item/clothing/under/rank/security/scrubs/sec(src)
	new /obj/item/clothing/head/utility/surgerycap/sec(src)
	new /obj/item/clothing/suit/toggle/labcoat/brig_physician(src)
	new /obj/item/clothing/shoes/sneakers/secred(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)

/obj/item/storage/bag/garment/blueshield
	name = "blueshield's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the blueshield."

/obj/item/storage/bag/garment/blueshield/PopulateContents()
	new /obj/item/clothing/suit/hooded/wintercoat/nova/blueshield(src)
	new /obj/item/clothing/head/beret/blueshield(src)
	new /obj/item/clothing/head/beret/blueshield/navy(src)
	new /obj/item/clothing/under/rank/blueshield(src)
	new /obj/item/clothing/under/rank/blueshield/skirt(src)
	new /obj/item/clothing/under/rank/blueshield/turtleneck(src)
	new /obj/item/clothing/under/rank/blueshield/turtleneck/skirt(src)
	new /obj/item/clothing/suit/armor/vest/blueshield(src)
	new /obj/item/clothing/suit/armor/vest/blueshield/jacket(src)
	new /obj/item/clothing/neck/mantle/bsmantle(src)

/obj/item/storage/belt/security/blueshield/PopulateContents()
		new /obj/item/grenade/flashbang(src)
		new /obj/item/assembly/flash/handheld(src)
		new /obj/item/reagent_containers/spray/pepper(src)
		new /obj/item/restraints/handcuffs(src)
