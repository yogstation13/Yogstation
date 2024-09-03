/obj/item/ammo_box/magazine/mp7
	name = "\improper MP7 magazine (4.6x30mm)"
	desc = "A 45-round 4.6x30mm magazine, designed for the MP7."
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = CALIBER_46X30
	max_ammo = 45

/obj/item/ammo_box/magazine/mp7/update_icon_state()
	. = ..()
	icon_state = "smg9mm[sprite_designation]-[ammo_count() ? "42" : "0"]"
