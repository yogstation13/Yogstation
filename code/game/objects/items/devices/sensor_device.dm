/obj/item/sensor_device
	name = "handheld crew monitor" //Thanks to Gun Hog for the name!
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
<<<<<<< HEAD
	slot_flags = ITEM_SLOT_BELT

/obj/item/sensor_device/attack_self(mob/user)
=======
	slot_flags = SLOT_BELT

/obj/item/device/sensor_device/attack_self(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	GLOB.crewmonitor.show(user,src) //Proc already exists, just had to call it
