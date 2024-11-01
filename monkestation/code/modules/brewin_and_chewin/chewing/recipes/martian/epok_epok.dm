/datum/chewin_cooking/recipe/ti_hoeh_koe
	cooking_container = PAN
	food_category = CAT_STOVETOP
	product_type = /obj/item/food/epok_epok
	step_builder = list(
		list(CHEWIN_ADD_ITEM, /obj/item/food/doughslice, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/meat/cutlet/chicken, qmod=0.5),
		list(CHEWIN_USE_STOVE, J_MED, 10 SECONDS, finish_text="The chicken starts to cook."),
		list(CHEWIN_ADD_ITEM, /obj/item/food/grown/potato/wedges, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/boiledegg, qmod=0.5),
		list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/curry_powder, 3, base=3),
		list(CHEWIN_USE_STOVE, J_LO, 10 SECONDS),
	)
