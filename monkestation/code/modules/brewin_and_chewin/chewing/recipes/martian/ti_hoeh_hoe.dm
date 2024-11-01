/datum/chewin_cooking/recipe/ti_hoeh_koe
	cooking_container = BOWL
	product_type = /obj/item/food/kebab/ti_hoeh_koe
	recipe_guide = "Mix Rice, salted peanuts, herbs and optionally blood in a bowl."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledrice, qmod=0.5),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/chili, qmod=0.2, reagent_skip=TRUE, prod_desc = "Extra spicy!", food_buff = /datum/status_effect/food/sweaty),
		list(CHEWIN_ADD_PRODUCE_OPTIONAL, /obj/item/food/grown/pineapple, qmod=0.2, reagent_skip=TRUE, prod_desc = "Mild and Sweet."),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/blood, 5, base=3),

		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/herbs, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/peanuts/salted, qmod=0.5),
	)
