/obj/item/vending_refill/fishing
	icon_state = "refill_fishing"

/obj/machinery/vending/fishing
	name = "\improper Tackle Box 2000"	
	desc = "Fishing peaked in 2000!"
	icon = 'yogstation/icons/obj/vending.dmi'
	icon_state = "fishing"
	icon_deny = "fishing-deny"
	product_slogans = "Don't tell my wife which bank I went to!;Fish fear me. Women love me.;If you want me to listen to you... talk about FISHING!;Good things come to those who bait.;Why did the lizard cross the road?"
	vend_reply = "Go get 'em, tiger!"
	products = list(/obj/item/twohanded/fishingrod = 3,
					/obj/item/reagent_containers/food/snacks/bait/apprentice = 15,
					/obj/item/reagent_containers/food/snacks/bait/journeyman = 10,
					/obj/item/clothing/head/fishing = 3,
					/obj/item/clothing/suit/fishing = 3,
					/obj/item/clothing/gloves/fishing = 3,
					/obj/item/clothing/shoes/fishing = 3
					)
	contraband = list(/obj/item/reagent_containers/food/snacks/bait/type = 3)
	premium = list(/obj/item/reagent_containers/food/snacks/bait/master = 5)
	refill_canister = /obj/item/vending_refill/fishing

	default_price = 5
	extra_price = 10
	payment_department = ACCOUNT_SRV
