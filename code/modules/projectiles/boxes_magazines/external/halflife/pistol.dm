/obj/item/ammo_box/magazine/usp9mm
	name = "pistol magazine (9mm)"
	desc = "A 18-round 9mm magazine designed for the USP Match pistol."
	icon_state = "9x19p-10"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9X19
	max_ammo = 18

/obj/item/ammo_box/magazine/usp9mm/update_icon_state()
	. = ..()
	icon_state = "9x19p-[ammo_count() ? "10" : "0"]"
