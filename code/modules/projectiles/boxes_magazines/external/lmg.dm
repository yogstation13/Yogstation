//L6 SAW

/obj/item/ammo_box/magazine/mm712x82
	name = "box magazine (7.12x82mm)"
	desc = "A 50-round box magazine designed for the L6 Saw."
	icon_state = "a762-50"
	ammo_type = /obj/item/ammo_casing/mm712x82
	caliber = "mm71282"
	max_ammo = 50

/obj/item/ammo_box/magazine/mm712x82/hollow
	name = "box magazine (Hollow-Point 7.12x82mm)"
	desc = "A 50-round box magazine designed for the L6 Saw. \
			These rounds suffer against armor but can massively wound bare limbs."
	icon_state = "a762H-50"
	ammo_type = /obj/item/ammo_casing/mm712x82/hollow
	sprite_designation = "H"

/obj/item/ammo_box/magazine/mm712x82/ap
	name = "box magazine (Armor-Piercing 7.12x82mm)"
	desc = "A 50-round box magazine designed for the L6 Saw. \
			These rounds deal less damage but penetrate cleanly through the best protective equipment."
	icon_state = "a762A-50"
	ammo_type = /obj/item/ammo_casing/mm712x82/ap
	sprite_designation = "A"

/obj/item/ammo_box/magazine/mm712x82/incen
	name = "box magazine (Incendiary 7.12x82mm)"
	desc = "A 50-round box magazine designed for the L6 Saw. \
			These rounds deal less damage but ignite targets."
	icon_state = "a762I-50"
	ammo_type = /obj/item/ammo_casing/mm712x82/inc
	sprite_designation = "I"

/obj/item/ammo_box/magazine/mm712x82/update_icon()
	..()
	icon_state = "a762[sprite_designation]-[round(ammo_count(),10)]"
