/datum/chewin_cooking/recipe/sandwich_basic
	cooking_container = CUTTING_BOARD
	product_type = /obj/item/food/sandwich
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/breadslice, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/meat/cutlet, qmod=0.5, desc="It has meat in it.", result_desc="There is meat between the bread."),
		list(CHEWIN_ADD_ITEM, /obj/item/food/breadslice, qmod=0.5)
	)
