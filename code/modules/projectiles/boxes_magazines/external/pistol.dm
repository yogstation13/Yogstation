//Stechkin Pistol

/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "An 10-round 10mm magazine designed for the Stechkin pistol."
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 10
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/m10mm/cs
	name = "pistol magazine (10mm Caseless)"
	icon_state = "9x19pC"
	desc = "An 10-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which are engineered without casings, but suffer damage and speed as a result."
	ammo_type = /obj/item/ammo_casing/caseless/c10mm/cs

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm Incendiary)"
	icon_state = "9x19pI"
	desc = "An 10-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which trade lethality for ignition of target."
	ammo_type = /obj/item/ammo_casing/c10mm/inc

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm Hollow-Point)"
	icon_state = "9x19pH"
	desc= "An 10-round 10mm magazine designed for the Stechkin pistol. Loaded with hollow-point rounds, which suffer massively against armor but deal intense damage."
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm Armor-Piercing)"
	icon_state = "9x19pA"
	desc= "An 10-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which penetrate armor but are less effective against normal targets."
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m10mm/sp
	name = "pistol magazine (10mm Soporific)"
	icon_state = "9x19pS"
	desc= "An 10-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which administer a small dose of tranquilizer on hit."
	ammo_type = /obj/item/ammo_casing/c10mm/sp

/obj/item/ammo_box/magazine/m10mm/emp
	name = "pistol magazine (10mm EMP)"
	icon_state = "9x19pE"
	desc = "An 10-round 10mm magazine designed for the Stechkin pistol. Loaded with rounds which release a small EMP pulse upon hitting a target."
	ammo_type = /obj/item/ammo_casing/c10mm/emp

//Makeshift Pistol

/obj/item/ammo_box/magazine/m10mm/makeshift
	name = "makeshift pistol magazine (10mm)"
	desc = "A hastily made 10mm gun magazine that can only store 4 bullets."
	icon_state = "9x19pM"
	icon_state_preview = "9x19pM-0"
	max_ammo = 4
	start_empty = TRUE

//M1911 Pistol

/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45 ACP)"
	desc = "An 8-round .45 ACP magazine designed for the M1911 pistol."
	icon_state = "45-8"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45ACP
	max_ammo = 8

/obj/item/ammo_box/magazine/m45/update_icon_state()
	. = ..()
	if (ammo_count() >= 8)
		icon_state = "45-8"
	else
		icon_state = "45-[ammo_count()]"

//Stechkin APS Pistol

/obj/item/ammo_box/magazine/pistolm9mm
	name = "pistol magazine (9mm)"
	desc = "A 15-round 9mm magazine designed for the Stechkin APS Pistol."
	icon_state = "9x19p-10"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9X19
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/update_icon_state()
	. = ..()
	icon_state = "9x19p-[ammo_count() ? "10" : "0"]"

//Desert Eagle

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50 AE)"
	desc = "A 7-round .50 AE magazine designed for the Desert Eagle."
	icon_state = "50ae-7"
	ammo_type = /obj/item/ammo_casing/a50AE
	caliber = CALIBER_50AE
	max_ammo = 7

/obj/item/ammo_box/magazine/m50/update_icon_state()
	. = ..()
	if (ammo_count() >= 7)
		icon_state = "50ae-7"
	else
		icon_state = "50ae-[ammo_count()]"

//Vatra M38 Pistol

/obj/item/ammo_box/magazine/v38
	name = "handgun magazine (.38 special)"
	desc = "A 8-round .38 special magazine designed for the Vatra M38 pistol."
	icon_state = "v38-8"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = CALIBER_38
	max_ammo = 8

/obj/item/ammo_box/magazine/v38/update_icon_state()
	. = ..()
	if (ammo_count() >= 8)
		icon_state = "v38[sprite_designation]-8"
	else
		icon_state = "v38[sprite_designation]-[ammo_count()]"

/obj/item/ammo_box/magazine/v38/rubber
	name = "handgun magazine (.38 rubber)"
	desc = "A 8-round .38 rubber magazine designed for the Vatra M38 pistol. Not great against armor."
	icon_state = "v38R-8"
	ammo_type = /obj/item/ammo_casing/c38/rubber
	sprite_designation = "R"

/obj/item/ammo_box/magazine/v38/ap
	name = "handgun magazine (.38 armor-piercing)"
	desc = "A 8-round .38 armor-piercing magazine designed for the Vatra M38 pistol. Less damaging, but doesn't suffer against armor."
	icon_state = "v38A-8"
	ammo_type = /obj/item/ammo_casing/c38/ap
	sprite_designation = "A"

/obj/item/ammo_box/magazine/v38/frost
	name = "handgun magazine (.38 frost)"
	desc = "A 8-round .38 frost magazine designed for the Vatra M38 pistol. Less effective against armor, but chills bodies."
	icon_state = "v38F-8"
	ammo_type = /obj/item/ammo_casing/c38/frost
	sprite_designation = "F"

/obj/item/ammo_box/magazine/v38/talon
	name = "handgun magazine (.38 talon)"
	desc = "A 8-round .38 talon magazine designed for the Vatra M38 pistol. Not as directly lethal, but painful while causing blood loss."
	icon_state = "v38T-8"
	ammo_type = /obj/item/ammo_casing/c38/talon
	sprite_designation = "T"

/obj/item/ammo_box/magazine/v38/bluespace
	name = "handgun magazine (.38 bluespace)"
	desc = "A 8-round .38 bluespace magazine designed for the Vatra M38 pistol. Less damaging, but incredibly fast."
	icon_state = "v38B-8"
	ammo_type = /obj/item/ammo_casing/c38/bluespace
	sprite_designation = "B"

// Bolt Pistol

/obj/item/ammo_box/magazine/boltpistol
	name = "bolt pistol magazine"
	icon = 'icons/obj/guns/grimdark.dmi'
	icon_state = "bpistolmag"
	desc = "A 10-round magazine holding specialty .75 bolt rounds."
	max_ammo = 10
	ammo_type = /obj/item/ammo_casing/boltpistol

/obj/item/ammo_box/magazine/boltpistol/admin
	desc = "A 10-round magazine holding specialty .75 bolt rounds. This one feels strangely powerful..."
	ammo_type = /obj/item/ammo_casing/boltpistol/admin
