/obj/machinery/vending/security/infection
	name = "\improper CombatTech"
	desc = "A combat equipment vendor."
	products = list(/obj/item/gun/ballistic/automatic/ar/infection = 5,
					/obj/item/ammo_box/magazine/m556/infection = 5,
					/obj/item/flashlight/seclite = 5,
					/obj/item/gun/ballistic/automatic/pistol/infection = 5,
					/obj/item/ammo_box/magazine/m10mm/infection = 5,
					/obj/item/storage/belt/security/webbing = 5,
					/obj/item/flashlight/flare = 10)
	contraband = list()
	premium = list()
	refill_canister = /obj/item/vending_refill/security/infection

/obj/item/vending_refill/security/infection

/obj/item/storage/backpack/duffelbag/infection/ammo
	name = "ammo duffel bag"
	desc = "A large duffel bag for holding ammo."

/obj/item/storage/backpack/duffelbag/infection/ammo/PopulateContents()
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)

/obj/item/storage/backpack/duffelbag/infection/ammo_lazarus
	name = "lazarus ammo duffel bag"
	desc = "A large duffel bag for holding lazarus ammo."

/obj/item/storage/backpack/duffelbag/infection/ammo_lazarus/PopulateContents()
	new /obj/item/ammo_box/magazine/m556/infection/lazarus(src)
	new /obj/item/ammo_box/magazine/m556/infection/lazarus(src)
	new /obj/item/ammo_box/magazine/m556/infection/lazarus(src)

/obj/item/storage/backpack/duffelbag/infection/ammo_purifier
	name = "purifier ammo duffel bag"
	desc = "A large duffel bag for holding purifier ammo."

/obj/item/storage/backpack/duffelbag/infection/ammo_purifier/PopulateContents()
	new /obj/item/ammo_box/magazine/m556/infection/purifier(src)
	new /obj/item/ammo_box/magazine/m556/infection/purifier(src)
	new /obj/item/ammo_box/magazine/m556/infection/purifier(src)

/obj/item/storage/backpack/duffelbag/infection/pistol_ammo
	name = "pistol ammoduffel bag"
	desc = "A large duffel bag for holding pistol ammo."

/obj/item/storage/backpack/duffelbag/infection/pistol_ammo/PopulateContents()
	new /obj/item/ammo_box/magazine/m10mm/infection(src)
	new /obj/item/ammo_box/magazine/m10mm/infection(src)
	new /obj/item/ammo_box/magazine/m10mm/infection(src)