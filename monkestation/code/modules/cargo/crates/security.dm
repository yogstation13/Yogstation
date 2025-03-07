/datum/supply_pack/security/armory/secway
	name = "Secway Crate"
	desc = "Sail through the halls like the badass mallcop of your dreams with the finest in overweight officer transportation technology!"
	cost = CARGO_CRATE_VALUE * 10
	contraband = TRUE
	contains = list(/obj/vehicle/ridden/secway,
					/obj/item/key/security)
	crate_name = "secway crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/security/armory/combatknives
	name = "Combat Knives Crate"
	desc = "Three combat knives guaranteed to fit snugly inide any Nanotrasen standard boot. Warranty void if you stab your own ankle."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/knife/combat = 3)
	crate_name = "combat knife crate"

/datum/supply_pack/security/paco
	name = "FS HG .35 Auto \"Paco\" weapon crate"
	desc = "Did security slip and lose their handguns? in that case, this crate contains three \"Paco\" handguns with three magazines of rubber."
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/paco/no_mag = 3,
		/obj/item/ammo_box/magazine/m35/rubber = 3,
		)
	crate_name = "\improper \"Paco\" handgun crate"

/datum/supply_pack/security/pacoammo
	name = "FS HG .35 Auto \"Paco\" non-lethal ammo crate"
	desc = "Short on ammo? No worries, this crate contains three .35 Auto rubber magazines, and the respective ammunition packet."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/m35/rubber = 3,
		/obj/item/ammo_box/c35/rubber = 1,
		)
	crate_name = ".35 Auto Non-Lethal Ammo crate"

/datum/supply_pack/security/armory/pacoammo
	name = "FS HG .35 Auto \"Paco\" lethal ammo crate"
	desc = "Short on ammo? No worries, this crate contains three lethally loaded .35 Auto magazines, and the respective ammunition packet."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/ammo_box/magazine/m35 = 3,
		/obj/item/ammo_box/c35 = 1,
		)
	crate_name = ".35 Auto Lethal Ammo crate"

/datum/supply_pack/security/blueshirt
	name = "Blue Shirt Uniform Crate"
	desc = "Contains an alternative outfit for the station's private security force. Has enough outfits for five security officers. Originally produced for a now defunct research station."
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_SECURITY
	contains = list(
		/obj/item/clothing/head/helmet/blueshirt = 5,
		/obj/item/clothing/suit/armor/vest/blueshirt = 5,
		/obj/item/clothing/under/rank/security/officer/blueshirt = 5,
	)
	crate_name = "\improper Blue Shirt uniform crate"

/datum/supply_pack/security/taser
	name = "Taser Crate"
	desc = "Contains three tasers, ready to tase criminals."
	cost = CARGO_CRATE_VALUE * 3
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/gun/energy/taser = 3)
	crate_name = "taser crate"

/datum/supply_pack/security/advtaser
	name = "Hybrid Taser Crate"
	desc = "Contains three hybrid tasers, ready for tase and stun action!"
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/gun/energy/e_gun/advtaser= 3)
	crate_name = "hybrid taser crate"
