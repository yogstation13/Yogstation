/obj/structure/closet/secure_closet/corrections_officer
	name = "corrections officer riot gear"
	icon = 'monkestation/code/modules/blueshift/icons/unique/closet.dmi'
	icon_state = "riot"
	req_access = list(ACCESS_SECURITY)
	door_anim_time = 0 //Somebody resprite or remove this 'riot' locker. It's evil.

/obj/structure/closet/secure_closet/corrections_officer/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/riot(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/clothing/shoes/jackboots/peacekeeper(src)
	new /obj/item/clothing/head/helmet/toggleable/riot(src)
	new /obj/item/shield/riot(src)


/obj/structure/closet/secure_closet/nanotrasen_consultant
	name = "nanotrasen consultant's locker"
	req_access = list(ACCESS_CENT_GENERAL)
	icon_state = "cc"
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet.dmi'

/obj/structure/closet/secure_closet/nanotrasen_consultant/PopulateContents()
	..()
	new /obj/item/storage/bag/garment/stolen(src)
	new /obj/item/storage/backpack/satchel/leather(src)
	new /obj/item/storage/photo_album/personal(src)
	new /obj/item/assembly/flash(src)
	new /obj/item/bedsheet/centcom(src)
	new /obj/item/storage/bag/garment/nanotrasen_representative(src)
	new /obj/item/circuitboard/machine/fax(src)

/obj/structure/closet/preopen
	opened = TRUE
