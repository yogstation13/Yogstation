/datum/chewin_cooking/recipe/katsu
	cooking_container = DF_BASKET
	product_type = /obj/item/food/katsu_fillet
	recipe_guide = "Put raw cutlets with some reispan bread slices in a fryer, fry for 20 seconds."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/meat/rawcutlet, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/breadslice/reispan, qmod=0.5),
		list(CHEWIN_USE_FRYER, J_HI, 20 SECONDS)
	)

/datum/chewin_cooking/recipe/katsu_curry
	name = "Katsu Curry"
	cooking_container = BOWL
	product_type = /obj/item/food/salad/katsu_curry
	recipe_guide = "Melt some butter in a bowl, add some rice, curry sauce and katsu."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/butter, qmod=0.5),
		list(CHEWIN_USE_STOVE, J_LO, 10 SECONDS, finish_text = "The butter melts in the bowl!"),

		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/soysauce, 5, base=3),

		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/katsu_fillet, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/nutriment/soup/curry_sauce, 5, base=3),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/chili, qmod=0.2, reagent_skip=TRUE, prod_desc = "Extra spicy!", food_buff = /datum/status_effect/food/sweaty),
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/pineapple, qmod=0.2, reagent_skip=TRUE, prod_desc = "Mild and Sweet."),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_LO, 20 SECONDS),
	)

/datum/chewin_cooking/recipe/katsu_curry_large
	name = "Katsu Curry (5 Servings)"
	cooking_container = POT
	food_category = CAT_BULK
	product_count = 5
	product_type = /obj/item/food/salad/katsu_curry
	recipe_guide = "Melt some butter in a pot, add some rice, curry sauce and katsu, cook on low in the stove for 1 minute. Serves 5"
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/butter, qmod=0.5),
		list(CHEWIN_USE_STOVE, J_LO, 10 SECONDS, finish_text = "The butter melts in the pot!"),

		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/soysauce, 15, base=3),

		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/katsu_fillet, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/katsu_fillet, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/katsu_fillet, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/nutriment/soup/curry_sauce, 25, base=3),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/chili, qmod=0.2, reagent_skip=TRUE, prod_desc = "Extra spicy!"),
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/pineapple, qmod=0.2, reagent_skip=TRUE, prod_desc = "Mild and Sweet."),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_LO, 1 MINUTES),
	)

/datum/chewin_cooking/recipe/yakisoba_katsu
	name = "Yakisoba Curry"
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/salad/yakisoba_katsu
	recipe_guide = "Melt some butter in a pan, add some noodles, vegetables, worcestershire and katsu."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/butter, qmod=0.5),
		list(CHEWIN_USE_STOVE, J_LO, 10 SECONDS, finish_text = "The butter melts in the bowl!"),

		list(CHEWIN_ADD_ITEM, /obj/item/food/spaghetti/boilednoodles, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/worcestershire, 5, base=3),

		list(CHEWIN_ADD_ITEM, /obj/item/food/katsu_fillet, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/onion_slice, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/carrot , qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage , qmod=0.5),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/chili, qmod=0.2, reagent_skip=TRUE, prod_desc = "Extra spicy!", food_buff = /datum/status_effect/food/sweaty),
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/pineapple, qmod=0.2, reagent_skip=TRUE, prod_desc = "Mild and Sweet."),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_LO, 20 SECONDS),
	)
