/datum/chewin_cooking/recipe/bulgogi_noodles
	name = "Bulgogi Noodles"
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/bulgogi_noodles
	recipe_guide = "Cook ingredients in a pan."
	step_builder = list(

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/butter, base=10, reagent_skip=TRUE),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS, finish_text = "The butter melts in the pan!"),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_ITEM, /obj/item/food/spaghetti/boilednoodles),
		list(CHEWIN_ADD_ITEM, /obj/item/food/meat/cutlet),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/apple),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/garlic),
		list(CHEWIN_ADD_ITEM, /obj/item/food/onion_slice),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/nutriment/soup/teriyaki, 4),
		list(CHEWIN_USE_STOVE, J_MED, 20 SECONDS)  // Cook on medium for 20 seconds
	)

/datum/chewin_cooking/recipe/martian_fried_noodles
	name = "Martian Fried Noodles"
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/martian_fried_noodles
	recipe_guide = "Cook ingredients in a pan."
	step_builder = list(

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/butter, base=10, reagent_skip=TRUE),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS, finish_text = "The butter melts in the pan!"),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_ITEM, /obj/item/food/spaghetti/boilednoodles),
		list(CHEWIN_ADD_ITEM, /obj/item/food/meat/cutlet),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/peanut),
		list(CHEWIN_ADD_ITEM, /obj/item/food/onion_slice),

		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/soysauce, 3),
		list(CHEWIN_USE_STOVE, J_MED, 10 SECONDS),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/red_bay, 3),

		list(CHEWIN_USE_STOVE, J_LO, 10 SECONDS)
	)


/datum/chewin_cooking/recipe/simple_fried_noodles
	name = "Fried Noodles"
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/simple_fried_noodles
	recipe_guide = "Cook ingredients in a pan."
	step_builder = list(

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/butter, base=10, reagent_skip=TRUE),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS, finish_text = "The butter melts in the pan!"),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_ITEM, /obj/item/food/spaghetti/boilednoodles),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/soysauce, 3),

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/egg, prod_desc = "With a hint of egg!"),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS),
		CHEWIN_END_OPTION_CHAIN,

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/onion_slice, prod_desc = "With some onion."),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 5 SECONDS),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/salt, 2, prod_desc = "A dash of salt was added."),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/sugar, 4, prod_desc = "A bit of sweetness was added."),


		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/chili, qmod=0.2, reagent_skip=TRUE, prod_desc = "Extra spicy!", food_buff = /datum/status_effect/food/sweaty),
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/pineapple, qmod=0.2, reagent_skip=TRUE, prod_desc = "Mild and Sweet."),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_MED, 10 SECONDS),
	)
