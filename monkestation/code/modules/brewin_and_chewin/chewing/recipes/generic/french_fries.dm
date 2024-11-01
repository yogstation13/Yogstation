/datum/chewin_cooking/recipe/fries
	cooking_container = DF_BASKET
	product_type = /obj/item/food/fries
	recipe_guide = "Put potato wedges in a fryer, fry for 30 seconds."
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/grown/potato/wedges, qmod=0.5),
		list(CHEWIN_USE_FRYER, J_HI, 10 SECONDS , finish_text = "The fries look gold and crispy!")
	)
