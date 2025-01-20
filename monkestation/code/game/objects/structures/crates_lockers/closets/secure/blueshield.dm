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
	new /obj/item/storage/photo_album/blueshield(src)
