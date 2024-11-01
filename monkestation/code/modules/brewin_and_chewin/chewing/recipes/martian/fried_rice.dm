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

/datum/chewin_cooking/recipe/ketchup_fried_rice
	name = "Ketchup Fried Rice"
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/ketchup_fried_rice
	recipe_guide = "Cook ingredients in a pan."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice),
		list(CHEWIN_ADD_ITEM, /obj/item/food/onion_slice),
		list(CHEWIN_ADD_ITEM, /obj/item/food/sausage/american),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/carrot),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/peas),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/ketchup, 5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/worcestershire, 2),
		list(CHEWIN_USE_STOVE, J_MED, 20 SECONDS)  // Cook on medium for 20 seconds
	)


/datum/chewin_cooking/recipe/mediterranean_fried_rice
	name = "Mediterranean Fried Rice"
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/mediterranean_fried_rice
	recipe_guide = "Cook ingredients in a pan."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice),
		list(CHEWIN_ADD_ITEM, /obj/item/food/onion_slice),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/herbs),
		list(CHEWIN_ADD_ITEM, /obj/item/food/cheese/firm_cheese_slice),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/olive),
		list(CHEWIN_ADD_ITEM, /obj/item/food/meatball),
		list(CHEWIN_USE_STOVE, J_MED, 20 SECONDS)  // Cook on medium for 20 seconds
	)


/datum/chewin_cooking/recipe/egg_fried_rice
	name = "Egg Fried Rice"
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/egg_fried_rice
	recipe_guide = "Cook ingredients in a pan."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/soysauce, 3),
		list(CHEWIN_USE_STOVE, J_MED, 20 SECONDS)  // Cook on medium for 20 seconds
	)


/datum/chewin_cooking/recipe/bibimbap
	name = "Bibimbap"
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/bibimbap
	recipe_guide = "Cook ingredients in a pan."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cucumber),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/mushroom/chanterelle),
		list(CHEWIN_ADD_ITEM, /obj/item/food/meat/cutlet),
		list(CHEWIN_ADD_ITEM, /obj/item/food/kimchi),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg),
		list(CHEWIN_USE_STOVE, J_MED, 20 SECONDS)  // Cook on medium for 20 seconds
	)
