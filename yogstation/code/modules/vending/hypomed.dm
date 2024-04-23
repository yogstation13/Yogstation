/obj/machinery/vending/wallhypo
	name = "\improper HypoMed"
	desc = "Wall-mounted Hypospray Equipment dispenser."
	icon = 'yogstation/icons/obj/vending.dmi'
	icon_state = "wallhypo"
	icon_deny = "wallhypo-deny"
	panel_type = "panel-wall"
	tiltable = FALSE
	density = FALSE
	// No default products, all of this shit costs money
	premium = list(	/obj/item/hypospray = 5,
					/obj/item/reagent_containers/glass/bottle/vial/libital = 10,
					/obj/item/reagent_containers/glass/bottle/vial/aiuri = 10,
					/obj/item/reagent_containers/glass/bottle/vial/styptic = 10,
					/obj/item/reagent_containers/glass/bottle/vial/silver_sulfadiazine = 10,
					/obj/item/reagent_containers/glass/bottle/vial/charcoal = 10,
					/obj/item/reagent_containers/glass/bottle/vial/perfluorodecalin = 10,
					/obj/item/reagent_containers/glass/bottle/vial/epi = 10,
					/obj/item/reagent_containers/glass/bottle/vial/coagulant = 10,
					/obj/item/storage/firstaid/hypospray/basic = 5,
					/obj/item/storage/firstaid/hypospray/advanced = 5,
					/obj/item/storage/firstaid/hypospray/brute = 3,
					/obj/item/storage/firstaid/hypospray/burn = 3,
					/obj/item/storage/firstaid/hypospray/toxin = 3,
					/obj/item/storage/firstaid/hypospray/oxygen = 3)
	extra_price = 50
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallhypo
	payment_department = ACCOUNT_MED
	light_mask = "wall-light-mask"

/obj/item/vending_refill/wallhypo
	machine_name = "HypoMed"
	icon_state = "refill_medical"
