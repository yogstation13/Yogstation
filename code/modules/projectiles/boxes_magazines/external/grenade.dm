/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75)"
	icon_state = "75-8"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = "75"
	max_ammo = 8

/obj/item/ammo_box/magazine/m75/update_icon()
	..()
	if(ammo_count())
		icon_state = "75-8"
	else
		icon_state = "75-0"
