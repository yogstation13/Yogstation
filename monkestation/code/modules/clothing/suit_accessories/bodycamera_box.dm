/obj/item/storage/box/bodycamera
	name = "box of bodycameras"
	desc = "A box full of bodycameras."
	icon_state = "secbox"

/obj/item/storage/box/bodycamera/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/bodycam_upgrade(src)
