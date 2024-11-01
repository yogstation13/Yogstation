/datum/chewin_cooking/recipe/setagaya_curry
	name = "Setagaya curry"
	cooking_container = BOWL
	product_type = /obj/item/food/salad/setagaya_curry
	recipe_guide = "Melt some butter in a bowl, add some rice, vegetables, curry powder and cook."
	step_builder = list(

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/butter, base=10, reagent_skip=TRUE),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS, finish_text = "The butter melts in the bowl!"),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/potato, qmod=0.5),
		list(CHEWIN_USE_STOVE, J_LO, 5 SECONDS, finish_text = "The potatoes soften."),

		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/carrot, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/onion, qmod=0.5),
		list(CHEWIN_USE_STOVE, J_LO, 5 SECONDS, finish_text = "The vegetables soften."),

		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/apple, qmod=0.5),
		list(CHEWIN_ADD_REAGENT_CHOICE, list(/datum/reagent/consumable/honey = 3, /datum/reagent/consumable/sugar = 1), 3, base=4),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/ketchup, 3, base=3),

		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/chocolatebar, qmod=2),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/coffee, 3, base=3),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/ethanol/wine, 3, base=3),

		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/curry_powder, 3, base=3),


		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/chili, qmod=0.2, reagent_skip=TRUE, prod_desc = "Extra spicy!", food_buff = /datum/status_effect/food/sweaty),
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/pineapple, qmod=0.2, reagent_skip=TRUE, prod_desc = "Mild and Sweet."),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_ADD_ITEM, /obj/item/food/meat/slab, qmod=0.5),
		list(CHEWIN_USE_STOVE, J_LO, 10 SECONDS),
	)
