<<<<<<< HEAD
/obj/item/beacon
=======
/obj/item/device/beacon
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "\improper tracking beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	item_state = "beacon"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/enabled = TRUE
	var/renamed = FALSE

<<<<<<< HEAD
/obj/item/beacon/Initialize()
=======
/obj/item/device/beacon/Initialize()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	if (enabled)
		GLOB.teleportbeacons += src
	else 
		icon_state = "beacon-off"

<<<<<<< HEAD
/obj/item/beacon/Destroy()
	GLOB.teleportbeacons.Remove(src)
	return ..()

/obj/item/beacon/attack_self(mob/user)
=======
/obj/item/device/beacon/Destroy()
	GLOB.teleportbeacons.Remove(src)
	return ..()

/obj/item/device/beacon/attack_self(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	enabled = !enabled
	if (enabled)
		icon_state = "beacon"
		GLOB.teleportbeacons += src
	else 
		icon_state = "beacon-off"
		GLOB.teleportbeacons.Remove(src)
	to_chat(user, "<span class='notice'>You [enabled ? "enable" : "disable"] the beacon.</span>")
	return

<<<<<<< HEAD
/obj/item/beacon/attackby(obj/item/W, mob/user)
=======
/obj/item/device/beacon/attackby(obj/item/W, mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(istype(W, /obj/item/pen)) // needed for things that use custom names like the locator
		var/new_name = stripped_input(user, "What would you like the name to be?")
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(new_name)
			name = new_name
			renamed = TRUE
		return
	else	
		return ..()
