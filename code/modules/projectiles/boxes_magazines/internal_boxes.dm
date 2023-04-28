//stuff that isn't magazines that also aren't ammo boxes

/obj/item/ammo_container/a357
	name = "speed loader (.357)"
	desc = "A seven-shot speed loader designed for .357 revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 7
	multiple_sprites = AMMO_CONTAINER_PER_BULLET

// Cannot be directly loaded into guns with internal magazines, but can load magazines/cylinders
/obj/item/ammo_container/no_direct/a357
	name = "ammo box (.357)"
	icon_state = "357box"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 20

/obj/item/ammo_container/no_direct/a357/ironfeather
	name = "ammo box (.357 Ironfeather)"
	ammo_type = /obj/item/ammo_casing/a357/ironfeather

/obj/item/ammo_container/no_direct/a357/nutcracker
	name = "ammo box (.357 Nutcracker)"
	ammo_type = /obj/item/ammo_casing/a357/nutcracker

/obj/item/ammo_container/no_direct/a357/metalshock
	name = "ammo box (.357 Metalshock)"
	ammo_type = /obj/item/ammo_casing/a357/metalshock

/obj/item/ammo_container/no_direct/a357/heartpiercer
	name = "ammo box (.357 Heartpiercer)"
	ammo_type = /obj/item/ammo_casing/a357/heartpiercer

/obj/item/ammo_container/no_direct/a357/wallstake
	name = "ammo box (.357 Wallstake)"
	ammo_type = /obj/item/ammo_casing/a357/wallstake

/obj/item/ammo_container/no_direct/n762
	name = "ammo box (7.62x38mmR)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = "n762"
	max_ammo = 14

/obj/item/ammo_container/a357/ironfeather
	name = "speed loader (.357 Ironfeather)"
	desc = "A seven-shot speed loader designed for .357 revolvers. \
			These shells fire six pellets which are less damaging than buckshot but slightly better over range."
	icon_state = "357feather"
	ammo_type = /obj/item/ammo_casing/a357/ironfeather

/obj/item/ammo_container/a357/nutcracker
	name = "speed loader (.357 Nutcracker)"
	desc = "A seven-shot speed loader designed for .357 revolver. \
			These rounds lose moderate stopping power but are capable of destroying doors and windows quickly."
	icon_state = "357cracker"
	ammo_type = /obj/item/ammo_casing/a357/nutcracker

/obj/item/ammo_container/a357/metalshock
	name = "speed loader (.357 Metalshock)"
	desc = "A seven-shot speed loader designed for .357 revolvers. \
			These rounds convert some lethality into an electric charge which bounces between targets."
	icon_state = "357shock"
	ammo_type = /obj/item/ammo_casing/a357/metalshock

/obj/item/ammo_container/a357/heartpiercer
	name = "speed loader (.357 Heartpiercer)"
	desc = "A seven-shot speed loader designed for .357 revolvers. \
			These rounds trade lethality for the ability to penetrate through armor and hit two bodies with one shot."
	icon_state = "357piercer"
	ammo_type = /obj/item/ammo_casing/a357/heartpiercer

/obj/item/ammo_container/a357/wallstake
	name = "speed loader (.357 Wallstake)"
	desc = "A seven-shot speed loader designed for .357 revolvers. \
			These blunt rounds trade lethality for the ability to knock people against walls, stunning them momentarily."
	icon_state = "357stake"
	ammo_type = /obj/item/ammo_casing/a357/wallstake

/obj/item/ammo_container/c38
	name = "speed loader (.38)"
	desc = "A six-shot speed loader designed for .38 revolvers."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 6
	multiple_sprites = AMMO_CONTAINER_PER_BULLET
	materials = list(/datum/material/iron = 20000)

/obj/item/ammo_container/c38/hotshot
	name = "speed loader (.38 Hot Shot)"
	desc = "A six-shot speed loader designed for .38 revolvers. \
			These rounds trade some damage for an incendiary payload which sets targets ablaze."
	icon_state = "38hot"
	ammo_type = /obj/item/ammo_casing/c38/hotshot

/obj/item/ammo_container/c38/iceblox
	name = "speed loader (.38 Iceblox)"
	desc = "A six-shot speed loader designed for .38 revolvers. \
			These rounds trade some damage for a cryogenic payload which significantly reduces the body temperature of targets hit."
	icon_state = "38ice"
	ammo_type = /obj/item/ammo_casing/c38/iceblox

/obj/item/ammo_container/c38/gutterpunch
	name = "speed loader (.38 Gutterpunch)"
	desc = "A six-shot speed loader designed for .38 revolvers. \
			These rounds trade some damage for an emetic payload which induces nausea in targets."
	icon_state = "38gut"
	ammo_type = /obj/item/ammo_casing/c38/gutterpunch

/obj/item/ammo_container/tra32
	name = "speed loader (.32 TRAC)"
	desc = "A seven-shot speed loader designed for the Caldwell Tracking Revolver. \
			These needle-like rounds deal miniscule damage, but inject a tracking implant upon burrowing into a target's body. Implant lifespan is five minutes."
	icon_state = "32trac"
	ammo_type = /obj/item/ammo_casing/tra32
	caliber = "32trac"
	max_ammo = 7
	multiple_sprites = AMMO_CONTAINER_PER_BULLET
