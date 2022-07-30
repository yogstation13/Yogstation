/obj/item/gun/energy/e_gun/advtaser/mounted
	name = "mounted taser"
	desc = "An arm mounted dual-mode weapon that fires electrodes and disabler shots."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "taser"
	item_state = "taser"
	force = 5
	selfcharge = 1
	can_flashlight = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses neural signals instead

/obj/item/gun/energy/e_gun/advtaser/mounted/dropped()//if somebody manages to drop this somehow...
	..()

/obj/item/gun/energy/disabler/cyborg/mounted
	name = "mounted disabler"
	desc = "An arm mounted weapon that fires disabler shots."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "taser"
	item_state = "armcannonstun4"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cyborg/weak)
	force = 5
	selfcharge = 1
	slowcharge = TRUE
	can_flashlight = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses neural signals instead

/obj/item/gun/energy/disabler/cyborg/mounted/dropped()//if somebody manages to drop this somehow...
	..()

/obj/item/gun/energy/laser/mounted
	name = "mounted laser"
	desc = "An arm mounted cannon that fires lethal lasers."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "laser"
	item_state = "laser"
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	force = 5
	selfcharge = 1
	can_charge = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/energy/laser/mounted/dropped()
	..()

/obj/item/gun/energy/laser/mounted/weak
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/mounted)
	slowcharge = TRUE

/obj/item/gun/energy/laser/mounted/weak/dropped()
	..()
