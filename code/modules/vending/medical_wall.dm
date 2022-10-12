/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	tiltable = FALSE
	density = FALSE
	products = list(/obj/item/reagent_containers/syringe = 3,
					/obj/item/reagent_containers/pill/patch/styptic = 5,
					/obj/item/reagent_containers/pill/patch/silver_sulf = 5,
					/obj/item/reagent_containers/pill/charcoal = 2,
					/obj/item/healthanalyzer/wound = 2,
					/obj/item/stack/medical/bone_gel = 2)
	contraband = list(/obj/item/reagent_containers/pill/tox = 2,
					/obj/item/reagent_containers/pill/morphine = 2)
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = 25
	extra_price = 100
	payment_department = ACCOUNT_MED

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"

/obj/machinery/vending/wallhypo
	name = "\improper HypoMed"
	desc = "Wall-mounted Hypospray Equipment dispenser."
	icon_state = "wallhypo"
	icon_deny = "wallhypo-deny"
	tiltable = FALSE
	density = FALSE
	// No default products, all of this shit costs money
	premium = list(	/obj/item/hypospray = 5,
					/obj/item/hypospray_upgrade/quickload = 5,
					/obj/item/reagent_containers/glass/bottle/vial/libital = 10,
					/obj/item/reagent_containers/glass/bottle/vial/aiuri = 10,
					/obj/item/reagent_containers/glass/bottle/vial/charcoal = 10,
					/obj/item/reagent_containers/glass/bottle/vial/perfluorodecalin = 10,
					/obj/item/reagent_containers/glass/bottle/vial/epi = 10,
					/obj/item/reagent_containers/glass/bottle/vial/styptic = 10,
					/obj/item/reagent_containers/glass/bottle/vial/silver_sulfadiazine = 10,
					/obj/item/reagent_containers/glass/bottle/vial/sal_acid = 10,
					/obj/item/reagent_containers/glass/bottle/vial/oxandrolone = 10,
					/obj/item/reagent_containers/glass/bottle/vial/calomel = 10,
					/obj/item/reagent_containers/glass/bottle/vial/salbutamol = 10,
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

/obj/item/vending_refill/wallhypo
	machine_name = "HypoMed"
	icon_state = "refill_medical"
