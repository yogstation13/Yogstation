/datum/chewin_cooking/recipe/surimi
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/food/surimi
	recipe_guide = "Put raw fish onto a cutting board and slice."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/fishmeat, qmod=0.5),
		list(CHEWIN_USE_TOOL, TOOL_KNIFE, 5)
	)

/datum/chewin_cooking/recipe/surimi_bulk
	name = "Surimi (5 Servings)"
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/food/surimi
	recipe_guide = "Put raw fish onto a cutting board and slice."
	product_count = 5
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/fishmeat, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/fishmeat, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/fishmeat, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/fishmeat, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/fishmeat, qmod=0.5),
		list(CHEWIN_USE_TOOL, TOOL_KNIFE, 5)
	)
