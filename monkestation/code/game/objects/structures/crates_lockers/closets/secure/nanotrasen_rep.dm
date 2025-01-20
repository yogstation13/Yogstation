/obj/structure/closet/secure_closet/nanotrasen_representative
	name = "Nanotrasen representative's locker"
	req_access = list(ACCESS_NT_REPRESENTATVE)
	icon_state = "cc"
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet.dmi'

/obj/structure/closet/secure_closet/nanotrasen_representative/PopulateContents()
	..()
	new /obj/item/storage/bag/garment/stolen(src)
	new /obj/item/storage/backpack/satchel/leather(src)
	new /obj/item/storage/photo_album/personal(src)
	new /obj/item/assembly/flash(src)
	new /obj/item/bedsheet/centcom(src)
	new /obj/item/storage/bag/garment/nanotrasen_representative(src)
	new /obj/item/circuitboard/machine/fax(src)
	new /obj/item/storage/photo_album/nt_rep(src)
