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

/obj/structure/closet/secure_closet/blueshield
	name = "blueshield's locker"
	icon_state = "bs"
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet.dmi'
	req_access = list(ACCESS_BLUESHIELD)

/obj/structure/closet/secure_closet/blueshield/New()
	..()
	new /obj/item/storage/briefcase/secure(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/storage/medkit/frontier/stocked(src)
	new /obj/item/storage/bag/garment/blueshield(src)
	new /obj/item/mod/control/pre_equipped/blueshield(src)
	new /obj/item/sensor_device/blueshield(src)
	new /obj/item/radio/headset/headset_bs(src)
	new /obj/item/radio/headset/headset_bs/alt(src)
