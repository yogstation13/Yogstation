/obj/item/gun/energy/e_gun/advtaser/warden
	name = "brig-restricted hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams. This one has a label claiming it has been designed to be restricted to the brig for escapees."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2

/obj/item/gun/energy/e_gun/advtaser/warden/can_shoot()
	. = ..()
	if (.)
		var/area_of_gun = get_area(src)
		if (!istype(area_of_gun, /area/security))
			if (!istype(area_of_gun, /area/ai_monitored/security/armory))
				return FALSE
	return .
