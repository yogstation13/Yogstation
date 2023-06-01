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
	// yes default products because vending machines need them to work
	products = list(/obj/item/hypospray = 55,
					/obj/item/hypospray_upgrade/quickload = 55,
					/obj/item/reagent_containers/glass/bottle/vial/libital = 60,
					/obj/item/reagent_containers/glass/bottle/vial/aiuri = 60,
					/obj/item/reagent_containers/glass/bottle/vial/charcoal = 60,
					/obj/item/reagent_containers/glass/bottle/vial/perfluorodecalin = 60,
					/obj/item/reagent_containers/glass/bottle/vial/epi = 60,
					/obj/item/reagent_containers/glass/bottle/vial/styptic = 60,
					/obj/item/reagent_containers/glass/bottle/vial/silver_sulfadiazine = 60,
					/obj/item/reagent_containers/glass/bottle/vial/sal_acid = 60,
					/obj/item/reagent_containers/glass/bottle/vial/oxandrolone = 60,
					/obj/item/reagent_containers/glass/bottle/vial/calomel = 60,
					/obj/item/reagent_containers/glass/bottle/vial/salbutamol = 60,
					/obj/item/reagent_containers/glass/bottle/vial/coagulant = 60,
					/obj/item/storage/firstaid/hypospray/basic = 55,
					/obj/item/storage/firstaid/hypospray/advanced = 55,
					/obj/item/storage/firstaid/hypospray/brute = 53,
					/obj/item/storage/firstaid/hypospray/burn = 53,
					/obj/item/storage/firstaid/hypospray/toxin = 53,
					/obj/item/storage/firstaid/hypospray/oxygen = 53)
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	default_price = 50
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallhypo
	payment_department = ACCOUNT_MED

/obj/item/vending_refill/wallhypo
	machine_name = "HypoMed"
	icon_state = "refill_medical"
