/datum/chewin_cooking/recipe/kimchi
	cooking_container = BOWL
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/kimchi
	recipe_guide = "Mix Cabbage, Chili, and Salt in a bowl."
	step_builder = list(
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/salt, 5, base=3),
	)

/datum/chewin_cooking/recipe/kimchi_inferno
	cooking_container = BOWL
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/inferno_kimchi
	recipe_guide = "Mix Cabbage, Ghost Chili, and Salt in a bowl."
	step_builder = list(
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/ghost_chili, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/salt, 5, base=3),
	)

/datum/chewin_cooking/recipe/garlic_kimchi
	cooking_container = BOWL
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/garlic_kimchi
	recipe_guide = "Mix Cabbage, Garlic, Chili, and Salt in a bowl."
	step_builder = list(
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/garlic, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/salt, 5, base=3),
	)

/datum/chewin_cooking/recipe/kimchi_five
	name = "Kimchi (5 Servings)"
	cooking_container = POT
	food_category = CAT_BULK
	product_type = /obj/item/food/kimchi
	product_count = 5
	recipe_guide = "Mix Cabbage, Chili, and Salt in a bowl."
	step_builder = list(
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/salt, 20, base=3),
	)

/datum/chewin_cooking/recipe/kimchi_inferno_five
	name = "Inferno Kimchi (5 Servings)"
	cooking_container = POT
	food_category = CAT_BULK
	product_count = 5
	product_type = /obj/item/food/inferno_kimchi
	recipe_guide = "Mix Cabbage, Ghost Chili, and Salt in a bowl."
	step_builder = list(
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/ghost_chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/ghost_chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/ghost_chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/ghost_chili, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/salt, 20, base=3),
	)

/datum/chewin_cooking/recipe/garlic_kimchi_five
	name = "Garlic Kimchi (5 Servings)"
	cooking_container = POT
	food_category = CAT_BULK
	product_count = 5
	product_type = /obj/item/food/garlic_kimchi
	recipe_guide = "Mix Cabbage, Garlic, Chili, and Salt in a bowl."
	step_builder = list(
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/cabbage, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/garlic, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/garlic, qmod=0.5),
		list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/garlic, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/salt, 20, base=3),
	)
