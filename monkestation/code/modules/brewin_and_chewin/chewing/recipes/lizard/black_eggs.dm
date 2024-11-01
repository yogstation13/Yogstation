/datum/chewin_cooking/recipe/black_eggs
	cooking_container = PAN
	product_type = /obj/item/food/black_eggs
	recipe_guide = "Crack eggs into a pan, add some vinegar and blood cook for 15 seconds on low."
	step_builder = list(

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/butter, base=10, reagent_skip=TRUE),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS, finish_text = "The butter melts in the pan!"),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),

		list(CHEWIN_ADD_REAGENT, /datum/reagent/blood, 5, base=3),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/vinegar, 5, base=3),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/blood, 15, remain_percent = 0.2 , base=3, prod_desc="Extra Bloody!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/capsaicin, 5, remain_percent = 0.2, base=6, prod_desc="Extra Spicy!"),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_LO, 15 SECONDS , finish_text = "You can smell scrambled eggs!")

	)

/datum/chewin_cooking/recipe/black_eggs_five
	name = "Black Scrambled Eggs (5 Servings)"
	cooking_container = PAN
	product_type = /obj/item/food/black_eggs
	product_count = 5
	recipe_guide = "Crack eggs into a pan, add some vinegar and blood cook for 25 seconds on low."
	step_builder = list(

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/butter, base=10, reagent_skip=TRUE),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS, finish_text = "The butter melts in the pan!"),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/egg, qmod=0.5),

		list(CHEWIN_ADD_REAGENT, /datum/reagent/blood, 15, base=4),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/vinegar, 15, base=5),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/blood, 30, remain_percent = 0.2 , base=5, prod_desc="Extra Bloody!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/capsaicin, 15, remain_percent = 0.2, base=6, prod_desc="Extra Spicy!"),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_LO, 25 SECONDS , finish_text = "You can smell scrambled eggs!")

	)
