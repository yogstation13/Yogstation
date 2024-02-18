// .357 speed loaders

/obj/item/ammo_box/a357
	name = "speed loader (.357 magnum)"
	desc = "A seven-shot speed loader designed for .357 revolvers. High damaging, some innate prowess against armor."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_357MAG
	max_ammo = 7
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/a357/ironfeather
	name = "speed loader (.357 Ironfeather)"
	desc = "A seven-shot speed loader designed for .357 revolvers. \
			These shells fire six pellets which are less damaging than buckshot but slightly better over range."
	icon_state = "357feather"
	ammo_type = /obj/item/ammo_casing/a357/ironfeather

/obj/item/ammo_box/a357/nutcracker
	name = "speed loader (.357 Nutcracker)"
	desc = "A seven-shot speed loader designed for .357 revolver. \
			These rounds lose moderate stopping power but are capable of destroying doors and windows quickly."
	icon_state = "357cracker"
	ammo_type = /obj/item/ammo_casing/a357/nutcracker

/obj/item/ammo_box/a357/metalshock
	name = "speed loader (.357 Metalshock)"
	desc = "A seven-shot speed loader designed for .357 revolvers. \
			These rounds convert some lethality into an electric charge which bounces between targets."
	icon_state = "357shock"
	ammo_type = /obj/item/ammo_casing/a357/metalshock

/obj/item/ammo_box/a357/heartpiercer
	name = "speed loader (.357 Heartpiercer)"
	desc = "A seven-shot speed loader designed for .357 revolvers. \
			These rounds trade lethality for the ability to penetrate through armor and hit two bodies with one shot."
	icon_state = "357piercer"
	ammo_type = /obj/item/ammo_casing/a357/heartpiercer

/obj/item/ammo_box/a357/wallstake
	name = "speed loader (.357 Wallstake)"
	desc = "A seven-shot speed loader designed for .357 revolvers. \
			These blunt rounds trade lethality for the ability to knock people against walls, stunning them momentarily."
	icon_state = "357stake"
	ammo_type = /obj/item/ammo_casing/a357/wallstake

// .44 speed loader

/obj/item/ammo_box/m44
	name = "speed loader (.44 magnum)"
	desc = "A six-shot speed loader designed for .44 revolvers. Massively damaging, wreaks havoc on bodies."
	icon_state = "44"
	ammo_type = /obj/item/ammo_casing/m44
	caliber = CALIBER_44MAG
	max_ammo = 6
	multiple_sprites = AMMO_BOX_PER_BULLET

// .38 special loaders

/obj/item/ammo_box/c38
	name = "speed loader (.38 special)"
	desc = "A six-shot speed loader designed for .38 revolvers."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = CALIBER_38
	max_ammo = 6
	multiple_sprites = AMMO_BOX_PER_BULLET
	materials = list(/datum/material/iron = 20000)

/obj/item/ammo_box/c38/rubber
	name = "speed loader (.38 rubber)"
	desc = "A six-shot speed loader designed for .38 revolvers. Rubber rounds trade lethality for a better ability to incapacitate targets."
	icon_state = "38rubber"
	ammo_type = /obj/item/ammo_casing/c38/rubber

// .32 TRAC speed loader

/obj/item/ammo_box/tra32
	name = "speed loader (.32 TRAC)"
	desc = "A seven-shot speed loader designed for the Caldwell Tracking Revolver. \
			These needle-like rounds deal miniscule damage, but inject a tracking implant upon burrowing into a target's body. Implant lifespan is five minutes."
	icon_state = "32trac"
	ammo_type = /obj/item/ammo_casing/tra32
	caliber = CALIBER_32ACP
	max_ammo = 7
	multiple_sprites = AMMO_BOX_PER_BULLET

// Generic ammo boxes

/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9X19
	max_ammo = 30

/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 20

/obj/item/ammo_box/c10mm/cs
	name = "ammo box (10mm caseless)"
	ammo_type = /obj/item/ammo_casing/caseless/c10mm/cs

/obj/item/ammo_box/c10mm/sp
	name = "ammo box (10mm soporific)"
	ammo_type = /obj/item/ammo_casing/c10mm/sp

/obj/item/ammo_box/c10mm/ap
	name = "ammo box (10mm armor-piercing)"
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/c10mm/hp
	name = "ammo box (10mm hollow-point)"
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/c10mm/inc
	name = "ammo box (10mm incendiary)"
	ammo_type = /obj/item/ammo_casing/c10mm/inc

/obj/item/ammo_box/c10mm/emp
	name = "ammo box (10mm EMP)"
	ammo_type = /obj/item/ammo_casing/c10mm/emp

/obj/item/ammo_box/c45
	name = "ammo box (.45 ACP)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45ACP
	max_ammo = 20

/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40GL
	max_ammo = 4
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	caliber = CALIBER_FOAM
	max_ammo = 40
	materials = list(/datum/material/iron = 500)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot
	materials = list(/datum/material/iron = 50000)

// No-direct ammo boxes, cannot be directly loaded into guns with internal magazines, but can load magazines/cylinders

/obj/item/ammo_box/no_direct/a357
	name = "ammo box (.357 magnum)"
	icon_state = "357box"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 20

/obj/item/ammo_box/no_direct/a357/ironfeather
	name = "ammo box (.357 Ironfeather)"
	ammo_type = /obj/item/ammo_casing/a357/ironfeather

/obj/item/ammo_box/no_direct/a357/nutcracker
	name = "ammo box (.357 Nutcracker)"
	ammo_type = /obj/item/ammo_casing/a357/nutcracker

/obj/item/ammo_box/no_direct/a357/metalshock
	name = "ammo box (.357 Metalshock)"
	ammo_type = /obj/item/ammo_casing/a357/metalshock

/obj/item/ammo_box/no_direct/a357/heartpiercer
	name = "ammo box (.357 Heartpiercer)"
	ammo_type = /obj/item/ammo_casing/a357/heartpiercer

/obj/item/ammo_box/no_direct/a357/wallstake
	name = "ammo box (.357 Wallstake)"
	ammo_type = /obj/item/ammo_casing/a357/wallstake

/obj/item/ammo_box/no_direct/n762
	name = "ammo box (7.62x38mmR)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = CALIBER_762X38R
	max_ammo = 14

/obj/item/ammo_box/no_direct/m308
	name = "ammo box (.308)"
	icon_state = "308box"
	ammo_type = /obj/item/ammo_casing/m308
	caliber = CALIBER_308
	max_ammo = 20

// Mosin stripper clip

/obj/item/ammo_box/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip holding 7.62mm rounds."
	icon_state = "762"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = CALIBER_762X54R
	max_ammo = 5
	multiple_sprites = AMMO_BOX_PER_BULLET

// Arrows boxes

/obj/item/ammo_box/arrow
	name = "ammo box (Arrow)"
	icon_state = "arrowbox_green"
	ammo_type = /obj/item/ammo_casing/reusable/arrow
	max_ammo = 10

/obj/item/ammo_box/arrow/toy
	name = "ammo box (Toy Arrow)"
	ammo_type = /obj/item/ammo_casing/reusable/arrow/toy

/obj/item/ammo_box/arrow/toy/energy
	name = "ammo box (Toy Energy Arrow)"
	icon_state = "arrowbox_red"
	ammo_type = /obj/item/ammo_casing/reusable/arrow/toy/energy

/obj/item/ammo_box/arrow/toy/disabler
	name = "ammo box (Toy Disabler Arrow)"
	icon_state = "arrowbox_teal"
	ammo_type = /obj/item/ammo_casing/reusable/arrow/toy/disabler

/obj/item/ammo_box/arrow/toy/pulse
	name = "ammo box (Toy Pulse Arrow)"
	icon_state = "arrowbox_blue"
	ammo_type = /obj/item/ammo_casing/reusable/arrow/toy/pulse

/obj/item/ammo_box/arrow/toy/xray
	name = "ammo box (Toy X-ray Arrow)"
	icon_state = "arrowbox_green"
	ammo_type = /obj/item/ammo_casing/reusable/arrow/toy/xray

/obj/item/ammo_box/arrow/toy/shock
	name = "ammo box (Toy Shock Arrow)"
	icon_state = "arrowbox_yellow"
	ammo_type = /obj/item/ammo_casing/reusable/arrow/toy/shock

/obj/item/ammo_box/arrow/toy/magic
	name = "ammo box (Toy Magic Arrow)"
	icon_state = "arrowbox_purple"
	ammo_type = /obj/item/ammo_casing/reusable/arrow/toy/magic
