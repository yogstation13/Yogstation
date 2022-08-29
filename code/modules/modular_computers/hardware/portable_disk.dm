/obj/item/computer_hardware/hard_drive/portable
	name = "data disk"
	desc = "Removable disk used to store data."
	power_usage = 10
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	critical = 0
	max_capacity = 16
	device_type = MC_SDD

/obj/item/computer_hardware/hard_drive/portable/on_remove(obj/item/modular_computer/MC, mob/user)
	return //this is a floppy disk, let's not shut the computer down when it gets pulled out.

/obj/item/computer_hardware/hard_drive/portable/install_default_programs()
	return // Empty by default

/obj/item/computer_hardware/hard_drive/portable/advanced
	name = "advanced data disk"
	power_usage = 20
	icon_state = "datadisk5"
	max_capacity = 64

/obj/item/computer_hardware/hard_drive/portable/super
	name = "super data disk"
	desc = "Removable disk used to store large amounts of data."
	power_usage = 40
	icon_state = "datadisk3"
	max_capacity = 256

///////////
//Presets//
///////////

/obj/item/computer_hardware/hard_drive/portable/implant_tracker
	name = "Implant Tracker data disk"
	desc = "A removable disk containing a copy of the Implant Tracker program."

/obj/item/computer_hardware/hard_drive/portable/implant_tracker/install_default_programs()
	..()
	store_file(new/datum/computer_file/program/radar/implant(src))

///////////////////
//Syndicate Disks//
///////////////////

/obj/item/computer_hardware/hard_drive/portable/syndicate
	name = "syndicate data disk"
	desc = "Removable disk used to transfer illegal programs and pictures of cats."
	icon_state = "datadisksyndicate"
	max_capacity = 32

/obj/item/computer_hardware/hard_drive/portable/syndicate/ntnet_dos/install_default_programs()
	..()
	store_file(new/datum/computer_file/program/ntnet_dos(src))

/obj/item/computer_hardware/hard_drive/portable/syndicate/bomberman/install_default_programs()
	..()
	var/datum/computer_file/program/bomberman/B = new /datum/computer_file/program/bomberman(src)
	var/datum/bombcode/C = new /datum/bombcode
	B.bombcode = C.code
	store_file(B)

//////////////
//Trap Disks//
//////////////

/obj/item/computer_hardware/hard_drive/portable/syndicate/trap
	var/devastation_range = -1
	var/heavy_impact_range = 1	// Maybe a bit too much
	var/light_impact_range = 3
	var/flash_range = 4

/obj/item/computer_hardware/hard_drive/portable/syndicate/trap/examine(user)
	. = ..()
	if(IS_JOB(user, "Network Admin"))
		. += span_notice("It appears to be rigged with explosives!")

/obj/item/computer_hardware/hard_drive/portable/syndicate/trap/diagnostics(var/mob/user)
	..()
	to_chat(user, "Payload Status: TRIGGERED!") // A little too late
	trigger()

/obj/item/computer_hardware/hard_drive/portable/syndicate/trap/proc/trigger()
	var/turf/T = get_turf(src.loc)
	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	qdel(src)
	return TRUE

/obj/item/computer_hardware/hard_drive/portable/syndicate/trap/on_remove(obj/item/modular_computer/MC, mob/user)
	trigger()
	..()
