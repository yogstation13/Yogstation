/obj/machinery/anesthetic_machine
	name = "F-9000 Portable Gas Tank Cart"
	desc = "A portable cart that can hold a gas tank and distribute the gas using a breath mask."
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "breath_machine"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/item/clothing/mask/breath/machine/attached_mask
	var/obj/item/tank/attached_tank = null
	var/is_roundstart = FALSE
	var/mask_out = FALSE

/obj/machinery/anesthetic_machine/roundstart
	is_roundstart = TRUE

/obj/machinery/anesthetic_machine/Initialize(mapload)
	. = ..()
	attached_mask = new /obj/item/clothing/mask/breath/machine(src)
	attached_mask.machine_attached = src
	if(is_roundstart)
		var/obj/item/tank/T = new /obj/item/tank/internals/anesthetic(src)
		attached_tank = T
	update_appearance(UPDATE_ICON)

/obj/machinery/anesthetic_machine/update_overlays()
	. = ..()
	if(mask_out)
		. += "mask_off"
	else
		. += "mask_on"
	if(attached_tank)
		. += "tank_on"

/obj/machinery/anesthetic_machine/examine(mob/user)
	. = ..()
	if(attached_tank)
		. += span_notice("[attached_tank] is attached to it.")

/obj/machinery/anesthetic_machine/attack_hand(mob/living/user)
	. = ..()
	if(retract_mask())
		visible_message(span_notice("[user] retracts the mask back into the [src]."))
	else if(attached_tank)// If attached tank, remove it.
		attached_tank.forceMove(loc)
		to_chat(user, span_notice("You remove the [attached_tank]."))
		attached_tank = null
		update_appearance(UPDATE_ICON)
		if(mask_out)
			retract_mask()

/obj/machinery/anesthetic_machine/AltClick(mob/user)
	. = ..()
	if(attached_tank && mask_out)
		to_chat(user, span_warning("Disconnect the tank from the person first!"))
		return
	else
		visible_message(span_warning("[user] attempts to detach the breath mask from [src]."), span_notice("You attempt to detach the breath mask from [src]."))
		if(!do_after(user, 5 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
			to_chat(user, span_warning("You fail to detach the breath mask from [src]!"))
			return
		visible_message(span_warning("[user] detaches the breath mask from [src]."), span_notice("You detach the breath mask from [src]."))
		if(attached_tank)
			attached_tank.forceMove(loc)
		attached_mask.forceMove(loc)
		new /obj/machinery/iv_drip(loc)
		qdel(src)
		

/obj/machinery/anesthetic_machine/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/tank))
		if(attached_tank) // If there is an attached tank, remove it and drop it on the floor
			attached_tank.forceMove(loc)
		I.forceMove(src) // Put new tank in, set it as attached tank
		visible_message(span_warning("[user] inserts [I] into [src]."))
		attached_tank = I
		update_appearance(UPDATE_ICON)
		return
	return ..()

/obj/machinery/anesthetic_machine/proc/retract_mask()
	if(mask_out)
		if(iscarbon(attached_mask.loc)) // If mask is on a mob
			var/mob/living/carbon/M = attached_mask.loc
			M.transferItemToLoc(attached_mask, src, TRUE)
			M.close_externals()
		else
			attached_mask.forceMove(src)
		mask_out = FALSE
		update_appearance(UPDATE_ICON)
		return TRUE
	return FALSE

/obj/machinery/anesthetic_machine/MouseDrop(mob/living/carbon/target)
	. = ..()
	if(!iscarbon(target))
		return
	if(src.Adjacent(target) && usr.Adjacent(target))
		if(attached_tank && !mask_out)
			usr.visible_message(span_warning("[usr] attempts to attach the [src] to [target]."), span_notice("You attempt to attach the [src] to [target]."))
			if(do_after(usr, 5 SECONDS, target, timed_action_flags = IGNORE_HELD_ITEM))
				if(!target.equip_to_appropriate_slot(attached_mask))
					to_chat(usr, span_warning("You are unable to attach the [src] to [target]!"))
					return
				else
					usr.visible_message(span_warning("[usr] attaches the [src] to [target]."), span_notice("You attach the [src] to [target]."))
					target.open_internals(attached_tank, TRUE)
					mask_out = TRUE
					START_PROCESSING(SSmachines, src)
					update_appearance(UPDATE_ICON)
		else
			to_chat(usr, span_warning("[mask_out ? "The machine is already in use!" : "The machine has no attached tank!"]"))

/obj/machinery/anesthetic_machine/process()
	if(!mask_out) // If not on someone, stop processingI c
		return PROCESS_KILL

	if(get_dist(src, get_turf(attached_mask)) > 1) // If too far away, detach
		to_chat(attached_mask.loc, span_warning("The [attached_mask] is ripped off of your face!"))
		retract_mask()
		return PROCESS_KILL

/obj/machinery/anesthetic_machine/Destroy()
	if(mask_out)
		retract_mask()
	qdel(attached_mask)
	new /obj/item/clothing/mask/breath(src)
	. = ..()

/obj/item/clothing/mask/breath/machine
	var/obj/machinery/anesthetic_machine/machine_attached
	clothing_flags = MASKINTERNALS | MASKEXTENDRANGE

/obj/item/clothing/mask/breath/machine/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/clothing/mask/breath/machine/dropped(mob/user)
	. = ..()
	if(loc != machine_attached) // If not already in machine, go back in when dropped (dropped is called on unequip)
		to_chat(user, span_notice("The mask snaps back into the [machine_attached]."))
		machine_attached.retract_mask()
