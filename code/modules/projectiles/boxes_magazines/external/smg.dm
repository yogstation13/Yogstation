/obj/item/ammo_box/magazine/wt550m9
	name = "\improper WT-550 magazine (4.6x30mm)"
	icon_state = "46x30mmt-20"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = "4.6x30mm"
	max_ammo = 22

/obj/item/ammo_box/magazine/wt550m9/update_icon()
	..()
	switch(ammo_count())
		if(19 to 22)
			icon_state = "46x30mmt-20"
		if(15 to 18)
			icon_state = "46x30mmt-16"
		if(11 to 14)
			icon_state = "46x30mmt-12"
		if(7 to 10)
			icon_state = "46x30mmt-8"
		if(3 to 6)
			icon_state = "46x30mmt-4"
		else
			icon_state = "46x30mmt-0"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "\improper WT-550 magazine (Armour Piercing 4.6x30mm)"
	icon_state = "46x30mmtA-20"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/magazine/wt550m9/wtap/update_icon()
	..()
	switch(ammo_count())
		if(19 to 22)
			icon_state = "46x30mmtA-20"
		if(15 to 18)
			icon_state = "46x30mmtA-16"
		if(11 to 14)
			icon_state = "46x30mmtA-12"
		if(7 to 10)
			icon_state = "46x30mmtA-8"
		if(3 to 6)
			icon_state = "46x30mmtA-4"
		else
			icon_state = "46x30mmtA-0"

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "\improper WT-550 magazine (Incendiary 4.6x30mm)"
	icon_state = "46x30mmtI-20"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

/obj/item/ammo_box/magazine/wt550m9/wtic/update_icon()
	..()
	switch(ammo_count())
		if(19 to 22)
			icon_state = "46x30mmtI-20"
		if(15 to 18)
			icon_state = "46x30mmtI-16"
		if(11 to 14)
			icon_state = "46x30mmtI-12"
		if(7 to 10)
			icon_state = "46x30mmtI-8"
		if(3 to 6)
			icon_state = "46x30mmtI-4"
		else
			icon_state = "46x30mmtI-0"

/obj/item/ammo_box/magazine/wt550m9/wtr
	name = "\improper WT-550 magazine(Rubber Rounds 4.6x30mm)"
	icon_state = "46x30mmtR-20"
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber

/obj/item/ammo_box/magazine/wt550m9/wtr/update_icon()
	..()
	switch(ammo_count())
		if(19 to 22)
			icon_state = "46x30mmtR-20"
		if(15 to 18)
			icon_state = "46x30mmtR-16"
		if(11 to 14)
			icon_state = "46x30mmtR-12"
		if(7 to 10)
			icon_state = "46x30mmtR-8"
		if(3 to 6)
			icon_state = "46x30mmtR-4"
		else
			icon_state = "46x30mmtR-0"

/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	icon_state = "uzi9mm-32"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon()
	..()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/smgm9mm
	name = "SMG magazine (9mm)"
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/update_icon()
	..()
	icon_state = "smg9mm-[ammo_count() ? "42" : "0"]"

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (Armour Piercing 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG Magazine (Incendiary 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/inc

/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	icon_state = "c20r45-24"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 24

/obj/item/ammo_box/magazine/smgm45/update_icon()
	..()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45/tommy
	caliber = ".45"
	max_ammo = 50
