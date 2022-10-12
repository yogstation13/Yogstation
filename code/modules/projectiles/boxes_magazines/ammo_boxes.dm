/obj/item/ammo_box/a357
	name = "speed loader (.357)"
	desc = "A seven-shot speed loader designed for .357 revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
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

/obj/item/ammo_box/c38
	name = "speed loader (.38)"
	desc = "A six-shot speed loader designed for .38 revolvers."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	multiple_sprites = AMMO_BOX_PER_BULLET
	materials = list(/datum/material/iron = 20000)

/obj/item/ammo_box/c38/hotshot
	name = "speed loader (.38 Hot Shot)"
	desc = "A six-shot speed loader designed for .38 revolvers. \
			These rounds trade exhaustive properties for an incendiary payload which sets targets ablaze."
	icon_state = "38hot"
	ammo_type = /obj/item/ammo_casing/c38/hotshot

/obj/item/ammo_box/c38/iceblox
	name = "speed loader (.38 Iceblox)"
	desc = "A six-shot speed loader designed for .38 revolvers. \
			These rounds trade exhaustive properties for a cryogenic payload which significantly reduces the body temperature of targets hit."
	icon_state = "38ice"
	ammo_type = /obj/item/ammo_casing/c38/iceblox

/obj/item/ammo_box/c38/gutterpunch
	name = "speed loader (.38 Gutterpunch)"
	desc = "A six-shot speed loader designed for .38 revolvers. \
			These rounds trade exhaustive properties for an emetic payload which induces nausea in targets."
	icon_state = "38gut"
	ammo_type = /obj/item/ammo_casing/c38/gutterpunch

/obj/item/ammo_box/tra32
	name = "speed loader (.32 TRAC)"
	desc = "A seven-shot speed loader designed for the Caldwell Tracking Revolver. \
			These needle-like rounds deal miniscule damage, but inject a tracking implant upon burrowing into a target's body. Implant lifespan is fifteen minutes."
	icon_state = "32trac"
	ammo_type = /obj/item/ammo_casing/tra32
	max_ammo = 7
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 20

/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip."
	icon_state = "762"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mmR)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40
	materials = list(/datum/material/iron = 500)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	materials = list(/datum/material/iron = 50000)
