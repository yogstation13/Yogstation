//Stechkin Pistol

/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "An 8-round 10mm magazine designed for the Stechkin pistol."
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 8
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm Incendiary)"
	icon_state = "9x19pI"
	desc = "An 8-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which trade lethality for ignition of target."
	ammo_type = /obj/item/ammo_casing/c10mm/inc

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm Hollow-Point)"
	icon_state = "9x19pH"
	desc= "An 8-round 10mm magazine designed for the Stechkin pistol. Loaded with hollow-point rounds, which suffer massively against armor but deal intense damage."
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm Armor-Piercing)"
	icon_state = "9x19pA"
	desc= "An 8-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which penetrate armor but are less effective against normal targets."
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m10mm/sp
	name = "pistol magazine (10mm Soporific)"
	icon_state = "9x19pS"
	desc= "An 8-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which administer a small dose of tranquilizer on hit."
	ammo_type = /obj/item/ammo_casing/c10mm/sp

/obj/item/ammo_box/magazine/m10mm/emp
	name = "pistol magazine (10mm EMP)"
	icon_state = "9x19pE"
	desc = "An 8-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which release a small EMP pulse upon hitting a target."
	ammo_type = /obj/item/ammo_casing/c10mm/emp

//Makeshift Pistol

/obj/item/ammo_box/magazine/m10mm/makeshift
	name = "makeshift pistol magazine (10mm)"
	desc = "A hastily made 10mm gun magazine that can only store 4 bullets."
	icon_state = "9x19pM"
	max_ammo = 4
	start_empty = TRUE

//M1911 Pistol

/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	desc = "An 8-round .45 magazine designed for the M1911 pistol."
	icon_state = "45-8"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 8

/obj/item/ammo_box/magazine/m45/update_icon()
	..()
	if (ammo_count() >= 8)
		icon_state = "45-8"
	else
		icon_state = "45-[ammo_count()]"

//Stechkin APS Pistol

/obj/item/ammo_box/magazine/pistolm9mm
	name = "pistol magazine (9mm)"
	desc = "A 15-round 9mm magazine designed for the Stechkin APS Pistol."
	icon_state = "9x19p-8"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/update_icon()
	..()
	icon_state = "9x19p-[ammo_count() ? "8" : "0"]"

//Desert Eagle

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	desc = "A 7-round .50ae magazine designed for the Desert Eagle."
	icon_state = "50ae"
	ammo_type = /obj/item/ammo_casing/a50AE
	caliber = ".50"
	max_ammo = 7
	multiple_sprites = AMMO_BOX_PER_BULLET
