//this is a testing recipe these recipes are for actual multistep things
/datum/chewin_cooking/recipe/bread
	cooking_container = OVEN
	product_type = /obj/item/food/bread/plain
	recipe_guide = "Put dough in an oven, bake for 30 seconds on medium."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/dough, qmod=0.5),
		list(CHEWIN_USE_OVEN, J_LO, 30 SECONDS, , finish_text = "The smell of baked bread oozes out!")
	)
