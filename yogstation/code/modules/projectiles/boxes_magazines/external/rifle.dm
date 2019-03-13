/obj/item/ammo_box/magazine/kalash762
	name = "kalash magazine (7.62x39mm)"
	icon = 'yogstation/icons/obj/ammo.dmi'
	icon_state = "kalash762"
	ammo_type = /obj/item/ammo_casing/c762x39
	caliber = "7.62x39mm"
	max_ammo = 20

/obj/item/ammo_box/magazine/kalash762/update_icon()
	..()
	if(ammo_count() == 0)
		icon_state = "kalash762-0"
	else
		icon_state = "kalash762"