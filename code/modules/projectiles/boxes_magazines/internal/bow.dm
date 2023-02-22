/obj/item/ammo_box/magazine/internal/bow
	name = "bow... magazine?" //shouldnt see this item
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	caliber = "arrow"
	max_ammo = 1
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/bow/energy
	ammo_type = /obj/item/ammo_casing/caseless/arrow/energy
	start_empty = FALSE
	var/list/selectable_types = list(/obj/item/ammo_casing/caseless/arrow/energy, /obj/item/ammo_casing/caseless/arrow/energy/disabler)

/obj/item/ammo_box/magazine/internal/bow/energy/advanced
	selectable_types = list(/obj/item/ammo_casing/caseless/arrow/energy, /obj/item/ammo_casing/caseless/arrow/energy/disabler, /obj/item/ammo_casing/caseless/arrow/energy/xray)

/obj/item/ammo_box/magazine/internal/bow/energy/syndicate
	selectable_types = list(/obj/item/ammo_casing/caseless/arrow/energy, /obj/item/ammo_casing/caseless/arrow/energy/xray)

/obj/item/ammo_box/magazine/internal/bow/energy/clockcult
	ammo_type = /obj/item/ammo_casing/caseless/arrow/energy/clockbolt
	selectable_types = list(/obj/item/ammo_casing/caseless/arrow/energy/clockbolt)
	
/obj/item/ammo_box/magazine/arrow
	name = "crossbow magazine"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	icon_state = ".50mag"
	caliber = "arrow"
	max_ammo = 5
