/obj/item/ammo_box/magazine/mm712x82
	name = "box magazine (7.12x82mm)"
	icon_state = "a762-50"
	ammo_type = /obj/item/ammo_casing/mm712x82
	caliber = "mm71282"
	max_ammo = 50

/obj/item/ammo_box/magazine/mm712x82/hollow
	name = "box magazine (Hollow-Point 7.12x82mm)"
	icon_state = "a762H-50"
	ammo_type = /obj/item/ammo_casing/mm712x82/hollow

/obj/item/ammo_box/magazine/mm712x82/ap
	name = "box magazine (Armor Penetrating 7.12x82mm)"
	icon_state = "a762A-50"
	ammo_type = /obj/item/ammo_casing/mm712x82/ap

/obj/item/ammo_box/magazine/mm712x82/incen
	name = "box magazine (Incendiary 7.12x82mm)"
	icon_state = "a762I-50"
	ammo_type = /obj/item/ammo_casing/mm712x82/incen

/obj/item/ammo_box/magazine/mm712x82/update_icon()
	..()
	icon_state = "a762-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/mm712x82/hollow/update_icon()
	..()
	icon_state = "a762H-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/mm712x82/ap/update_icon()
	..()
	icon_state = "a762A-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/mm712x82/incen/update_icon()
	..()
	icon_state = "a762I-[round(ammo_count(),10)]"
