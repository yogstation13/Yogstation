/obj/machinery/vending/plushvendor
	name = "\improper Plushie Vendor"
	desc = "A vending machine filled with trusty companions."
	icon = 'monkestation/icons/obj/vending.dmi'
	icon_state = "plushie"
	panel_type = "panel4"
	product_slogans = "For when the cold empty expanse of space is too much to bear!;Plushies made only from the highest quality material.;Collect them all and never be alone again!; Too cute to handle!"
	product_ads = "The most reliable buddies!;They love the inside of your backpack!;Objectively the best toy!;Who needs people when you have plushies?"
	vend_reply = "Have fun with your new friend!"
	light_mask = "plushie-light-mask"

	product_categories = list(
		list(
			"name" = "Classic",
			"icon" = "hand-sparkles",
			"products" = list(
				/obj/item/toy/plush/carpplushie = 1,
				/obj/item/toy/plush/slimeplushie = 1,
				/obj/item/toy/plush/lizard_plushie/greyscale = 1,
				/obj/item/toy/plush/snakeplushie = 1,
				/obj/item/toy/plush/plasmamanplushie = 1,
				/obj/item/toy/plush/moth = 1,
				/obj/item/toy/plush/pkplush = 1,
				/obj/item/toy/plush/beeplushie = 1,
			),
		),
		list(
			"name" = "Deluxe",
			"icon" = "star",
			"products" = list(
				/obj/item/toy/plush/lizard_plushie = 1,
				/obj/item/toy/plush/lizard_plushie/green = 1,
				/obj/item/toy/plush/lizard_plushie/space/green = 1,
				/obj/item/toy/plush/awakenedplushie = 1,
				/obj/item/toy/plush/goatplushie = 1,
				/obj/item/toy/plush/rouny = 1,
				/obj/item/toy/plush/abductor = 1,
				/obj/item/toy/plush/abductor/agent = 1,
				/obj/item/toy/plush/greek_cucumber = 1,
			),
		),
		list(
			"name" = "Special",
			"icon" = "diamond",
			"products" = list(),
		),
	)
	premium = list(
		/obj/item/toy/plush/bubbleplush = 1,
		/obj/item/toy/plush/ratplush = 1,
		/obj/item/toy/plush/narplush = 1,
		/obj/item/toy/plush/whiny_plushie = 1,
		/obj/item/toy/plush/shark = 1,
	)
	refill_canister = /obj/item/vending_refill/plushvendor
	default_price = PAYCHECK_COMMAND * 3 //should be expensive
	extra_price = PAYCHECK_COMMAND * 5
	payment_department = NO_FREEBIES

/obj/machinery/vending/plushvendor/build_products_from_categories() //snowflake code to randomize plushies, breaks icon spreadsheets for random products
	var/obj/item/vending_refill/R = locate() in component_parts
	if(!R.product_categories && !R.contraband)
		var/list/lobplush = subtypesof(/obj/item/toy/plush/lobotomy)
		var/list/novaplush = subtypesof(/obj/item/toy/plush/nova)
		for(var/i in 1 to 8)
			contraband[pick_n_take(lobplush)] = 1
			product_categories[3]["products"][pick_n_take(novaplush)] = 1
	else
		product_categories = R.product_categories.Copy()
		contraband = R.contraband.Copy()
	. = ..()

/obj/item/vending_refill/plushvendor
	machine_name = "\improper Plushie Vendor"
	icon_state = "refill_plush"
