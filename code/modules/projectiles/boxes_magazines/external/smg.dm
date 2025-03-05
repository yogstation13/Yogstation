/obj/item/ammo_box/magazine/wt550m9
	name = "wt550 magazine (4.6x30mm)"
	icon_state = "46x30mmt-20"
	base_icon_state = "46x30mmt"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = CALIBER_46X30MM
	max_ammo = 20

//MONKESTATION ADDITION START
/obj/item/ammo_box/magazine/wt550m9/starts_empty
	start_empty = TRUE
//MONKESTATION ADDITION END

/obj/item/ammo_box/magazine/wt550m9/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "wt550 magazine (Armour Piercing 4.6x30mm)"
	icon_state = "46x30mmtA-20"
	base_icon_state = "46x30mmtA"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/magazine/wt550m9/wtap/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "wt550 magazine (Incendiary 4.6x30mm)"
	icon_state = "46x30mmtI-20"
	base_icon_state = "46x30mmtI"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

/obj/item/ammo_box/magazine/wt550m9/wtic/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_box/magazine/plastikov9mm
	name = "PP-95 magazine (9mm)"
	icon_state = "9x19-50"
	base_icon_state = "9x19"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 50

/obj/item/ammo_box/magazine/plastikov9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? 50 : 0]"

/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	icon_state = "uzi9mm-32"
	base_icon_state = "uzi9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_box/magazine/smgm9mm
	name = "SMG magazine (9mm)"
	icon_state = "smg9mm"
	base_icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (Armour Piercing 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG Magazine (Incendiary 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/fire

/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	icon_state = "c20r45-24"
	base_icon_state = "c20r45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45
	max_ammo = 42  ///monke edit 24 -> 42

/obj/item/ammo_box/magazine/smgm45/update_icon_state()
	. = ..()
	//monke edit start
	var/old_ammo = 24 // From the old 24 ammo count.
	var/icon_steps = 2 // Number of steps each icon changed. If 2 with 24 ammo then 24->22->20 etc
	var/scaled_ammo = round((ammo_count() / max_ammo) * old_ammo, icon_steps) // Required offest without altering icons.
	if(ammo_count() > 0 && ammo_count() < 2) // Force last bullet icon till the last bullet is actually used.
		scaled_ammo = icon_steps // icon_steps is usually also your last icon before 0
	icon_state = "[base_icon_state]-[scaled_ammo]"
	//monke edit end

/obj/item/ammo_box/magazine/smgm45/ap
	name = "SMG magazine (Armour Piercing .45)"
	ammo_type = /obj/item/ammo_casing/c45/ap

/obj/item/ammo_box/magazine/smgm45/incen
	name = "SMG magazine (Incendiary .45)"
	ammo_type = /obj/item/ammo_casing/c45/inc

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45
	max_ammo = 50
