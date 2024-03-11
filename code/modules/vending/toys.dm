/obj/machinery/vending/donksofttoyvendor
	name = "\improper Donksoft Toy Vendor"
	desc = "Ages 8 and up approved vendor that dispenses toys."
	icon_state = "syndi"
	panel_type = "panel18"
	product_slogans = "Get your cool toys today!;Trigger a security officer today!;Quality toy weapons for cheap prices!;Give them to HoPs for all access!;Give them to HoS to get permabrigged!"
	product_ads = "Feel robust with your toys!;Express your inner child today!;Toy weapons don't kill people, but security does!;Who needs responsibilities when you have toy weapons?;Make your next murder FUN!"
	vend_reply = "Come back for more!"
	circuit = /obj/item/circuitboard/machine/vending/donksofttoyvendor
	products = list(
		/obj/item/gun/ballistic/automatic/toy/unrestricted = 10,
		/obj/item/gun/ballistic/automatic/toy/pistol/unrestricted = 10,
		/obj/item/gun/ballistic/shotgun/toy/unrestricted = 10,
		/obj/item/toy/sword = 10,
		/obj/item/melee/vxtvulhammer/toy = 7,
		/obj/item/ammo_box/foambox = 20,
		/obj/item/toy/foamblade = 10,
		/obj/item/toy/foamblade/baseball = 10,
		/obj/item/toy/syndicateballoon = 10,
		/obj/item/clothing/suit/syndicatefake = 5,
		/obj/item/clothing/head/syndicatefake = 5,
		/obj/item/gun/magic/sickly_blade_toy = 1,
		/obj/item/gun/magic/sickly_blade_toy/rust_toy = 1,
		/obj/item/gun/magic/sickly_blade_toy/ash_toy = 1,
		/obj/item/gun/magic/sickly_blade_toy/flesh_toy =1)
	contraband = list(
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 10,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted = 10,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted = 10,
		/obj/item/gun/water/full = 10,
		/obj/item/toy/katana = 10,
		/obj/item/melee/dualsaber/toy = 5,
		/obj/item/organ/cyberimp/chest/spinalspeed/toy = 5,
	)
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/donksoft
	default_price = 25
	extra_price = 50
	light_mask = "donksoft-light-mask"
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/donksoft
	machine_name = "Donksoft Toy Vendor"
	icon_state = "refill_donksoft"

/obj/machinery/vending/donksofttoyvendor/hugbox
	name = "\improper Hugsoft Toy Vendor"
	desc = "An ages 8 and up approved vendor that dispenses toys. This one feels noticably less fun..."
	circuit = /obj/item/circuitboard/machine/vending/donksofttoyvendor/hugbox
	products = list(
		/obj/item/gun/ballistic/automatic/toy/unrestricted/hugbox = 10,
		/obj/item/gun/ballistic/automatic/toy/pistol/unrestricted/hugbox = 10,
		/obj/item/gun/ballistic/shotgun/toy/unrestricted/hugbox = 10,
		/obj/item/toy/sword = 10,
		/obj/item/melee/vxtvulhammer/toy = 7,
		/obj/item/ammo_box/foambox = 30,
		/obj/item/toy/foamblade = 10,
		/obj/item/toy/foamblade/baseball = 10,
		/obj/item/toy/syndicateballoon = 10,
		/obj/item/clothing/suit/syndicatefake = 5,
		/obj/item/clothing/head/syndicatefake = 5,
		/obj/item/gun/magic/sickly_blade_toy = 1,
		/obj/item/gun/magic/sickly_blade_toy/rust_toy = 1,
		/obj/item/gun/magic/sickly_blade_toy/ash_toy = 1,
		/obj/item/gun/magic/sickly_blade_toy/flesh_toy =1,
		/obj/item/gun/ballistic/shotgun/toy/crossbow/hugbox = 10, // No more contraband section because they cant load riot darts anymore.
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/hugbox = 10,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted/hugbox = 10,
		/obj/item/gun/water/full = 10,
		/obj/item/toy/katana = 10,
		/obj/item/melee/dualsaber/toy = 5,
		/obj/item/organ/cyberimp/chest/spinalspeed/toy = 5
	)
