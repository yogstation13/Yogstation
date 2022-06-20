/obj/item/ammo_box/magazine/m10mm/rifle
	name = "rifle magazine (10mm)"
	desc = "A well-worn magazine fitted for the surplus rifle."
	icon_state = "75-8"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 10

/obj/item/ammo_box/magazine/m10mm/rifle/update_icon()
	..()
	if(ammo_count())
		icon_state = "75-8"
	else
		icon_state = "75-0"

/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56mm)"
	icon_state = "5.56m"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "a556"
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/wt650
	name = "WT-650 magazine (5.45mm)"
	icon_state = "wt650"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = "a545"
	max_ammo = 30

/obj/item/ammo_box/magazine/wt650/update_icon()
	..()
	if(ammo_count())
		icon_state = "wt650"
	else
		icon_state = "wt650_empty"
		
/obj/item/ammo_box/magazine/wt650/rubber
	name = "WT-650 rubber magazine (5.45mm)"
	icon_state = "wt650_rubber"
	ammo_type = /obj/item/ammo_casing/a545_rubber
	caliber = "a545"
	max_ammo = 30

/obj/item/ammo_box/magazine/wt650/rubber/update_icon()
	..()
	if(ammo_count())
		icon_state = "wt650_rubber"
	else
		icon_state = "wt650_rubber_empty"
		
/obj/item/ammo_box/magazine/wt650/ap
	name = "WT-650 armor-piercing magazine (5.45mm)"
	icon_state = "wt650_ap"
	ammo_type = /obj/item/ammo_casing/a545_ap
	caliber = "a545"
	max_ammo = 30

/obj/item/ammo_box/magazine/wt650/ap/update_icon()
	..()
	if(ammo_count())
		icon_state = "wt650_ap"
	else
		icon_state = "wt650_ap_empty"
		
/obj/item/ammo_box/magazine/wt650/incendiary
	name = "WT-650 incendiary magazine (5.45mm)"
	icon_state = "wt650_fire"
	ammo_type = /obj/item/ammo_casing/a545_incendiary
	caliber = "a545"
	max_ammo = 30

/obj/item/ammo_box/magazine/wt650/incendiary/update_icon()
	..()
	if(ammo_count())
		icon_state = "wt650_fire"
	else
		icon_state = "wt650_fire_empty"
		
/obj/item/ammo_box/magazine/wt650/laser
	name = "WT-650 laser magazine (5.45mm)."
	desc = "A 5.45mm magazine for the WT-650. This one is specially designed to print more ammo when put into any standard weapon recharger. Convenient!"
	icon_state = "wt650_laser"
	ammo_type = /obj/item/ammo_casing/a545_laser
	caliber = "a545"
	max_ammo = 30

/obj/item/ammo_box/magazine/wt650/laser/update_icon()
	..()
	if(ammo_count())
		icon_state = "wt650_laser"
	else
		icon_state = "wt650_laser_empty"

/obj/item/ammo_box/magazine/wt650/laser/attack_self() //No popping out the "bullets"
	return
