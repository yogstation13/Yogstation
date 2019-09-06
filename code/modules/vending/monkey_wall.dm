/obj/machinery/vending/wallmonkey
	name = "NanoGene"
	desc = "Wall-mounted Genetics Equipment dispenser."
	icon_state = "wallmonkey"
	icon_deny = "wallmonkey-deny"
	density = FALSE
	products = list(/obj/item/storage/pill_bottle/mannitol = 2,
		            /obj/item/storage/pill_bottle/mutadone = 2,
					/obj/item/clothing/glasses/regular = 5,
					/obj/item/disk/data = 5,
					/obj/item/reagent_containers/food/snacks/monkeycube = 5)
	contraband = list(/obj/item/reagent_containers/food/snacks/monkeycube/gorilla = 2)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmonkey
	default_price = 25
	extra_price = 250
	payment_department = ACCOUNT_SCI

/obj/item/vending_refill/wallmonkey
	machine_name = "NanoGene"
	icon_state = "refill_genetics"