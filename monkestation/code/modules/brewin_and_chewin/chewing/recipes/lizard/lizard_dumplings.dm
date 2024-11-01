/datum/chewin_cooking/recipe/lizard_dumplings
	cooking_container = POT
	product_type = /obj/item/food/lizard_dumplings
	product_count = 3
	recipe_guide = "Put wrapped potatoes in a pot, steam for 30 seconds on medium."
	step_builder = list(
		list(CHEWIN_ADD_REAGENT, /datum/reagent/water, 15, base=3),

		list(CHEWIN_ADD_ITEM, /obj/item/food/grown/potato, qmod=0.5),

		list(CHEWIN_ADD_REAGENT_CHOICE, list(/datum/reagent/consumable/korta_flour = 2, /datum/reagent/consumable/flour = 0.5), 5, base=4),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/honey, 15, remain_percent = 0.2 , base=4, prod_desc="Extra Sweet!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/capsaicin, 5, remain_percent = 0.2, base=6, prod_desc="Extra Spicy!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/soysauce, 5, remain_percent = 0.2, base=6, prod_desc="Salty!"),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_MED, 30 SECONDS , finish_text = "You can smell fresh cooked dumplings!")

	)

/datum/chewin_cooking/recipe/lizard_dumplings_dozen
	name = "Lizard Dumplings (12 Servings)"
	cooking_container = POT
	product_type = /obj/item/food/lizard_dumplings
	food_category = CAT_BULK
	product_count = 12
	recipe_guide = "Put wrapped potatoes in a pot, steam for 45 seconds on medium."
	step_builder = list(
		list(CHEWIN_ADD_REAGENT, /datum/reagent/water, 25, base=3),

		list(CHEWIN_ADD_ITEM, /obj/item/food/grown/potato, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/grown/potato, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/grown/potato, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/grown/potato, qmod=0.5),

		list(CHEWIN_ADD_REAGENT_CHOICE, list(/datum/reagent/consumable/korta_flour = 2, /datum/reagent/consumable/flour = 0.5), 15, base=3),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/honey, 15, remain_percent = 0.2 , base=4, prod_desc="Extra Sweet!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/capsaicin, 10, remain_percent = 0.2, base=6, prod_desc="Extra Spicy!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/soysauce, 10, remain_percent = 0.2, base=6, prod_desc="Salty!"),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_MED, 45 SECONDS , finish_text = "You can smell fresh cooked dumplings!")

	)
