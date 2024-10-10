/datum/chewin_cooking/recipe/hurricane_rice
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/hurricane_rice
	recipe_guide = "Add boiled rice to pan, crack an egg, add vegetables, cook for 15 seconds on high, add soysauce, cook for 5 seconds on high."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),

		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/onion_slice, qmod=0.5),
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/pineappleslice, qmod=0.5),

		list(CHEWIN_USE_STOVE, J_HI, 15 SECONDS , finish_text = "You can smell almost finished fried rice, just needs some seasoning!"),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/soysauce, 3, base=3),
		list(CHEWIN_USE_STOVE, J_HI, 5 SECONDS , finish_text = "You can smell fried rice!"),
	)

/datum/chewin_cooking/recipe/ikareis
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/ikareis
	recipe_guide = "Add boiled rice to pan, some squid ink, add vegetables and sausage, cook for 20 seconds on high."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/canned/squid_ink, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/bell_pepper, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/sausage, qmod=0.5),

		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/onion_slice, qmod=0.5),
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/pineappleslice, qmod=0.5, prod_desc = "Extra sweet!"),
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/grown/chili, qmod=0.5, prod_desc = "Extra spicy!"),

		list(CHEWIN_USE_STOVE, J_HI, 20 SECONDS , finish_text = "You can smell ikareis!"),
	)
