/obj/machinery/vending/wallgene
	name = "\improper NanoGene"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallgene"
	icon_deny = "wallgene-deny"
	density = FALSE
	products = list(/obj/item/storage/pill_bottle/mannitol = 2,
		            /obj/item/storage/pill_bottle/mutadone = 2,
		            /obj/item/reagent_containers/pill/charcoal = 6,
					/obj/item/clothing/glasses/regular = 5,
					/obj/item/disk/data = 2,
					/obj/item/reagent_containers/food/snacks/monkeycube = 10)
	contraband = list(/obj/item/reagent_containers/glass/bottle/radium = 1,
					  /obj/item/reagent_containers/glass/bottle/mutagen = 2,
	                  /obj/item/reagent_containers/food/snacks/monkeycube/gorilla = 1)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallgene
	default_price = 25
	extra_price = 100
	payment_department = ACCOUNT_SCI

/obj/item/vending_refill/wallgene
	machine_name = "NanoGene"
	icon_state = "refill_wallgene"

