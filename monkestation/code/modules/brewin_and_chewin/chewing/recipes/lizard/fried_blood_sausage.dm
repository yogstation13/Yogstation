/datum/chewin_cooking/recipe/fried_blood_sausage
	cooking_container = PAN
	product_type = /obj/item/food/fried_blood_sausage
	recipe_guide = "Put blood sausages in a pan, cook for 30 seconds on medium."
	step_builder = list(

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/butter, base=10, reagent_skip=TRUE),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS, finish_text = "The butter melts in the pan!"),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_ITEM, /obj/item/food/raw_tiziran_sausage, qmod=0.5),

		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/korta_flour, 5, base=3),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/blood, 15, remain_percent = 0.2 , base=3, prod_desc="Extra Bloody!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/honey, 15, remain_percent = 0.2 , base=4, prod_desc="Extra Sweet!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/capsaicin, 5, remain_percent = 0.2, base=6, prod_desc="Extra Spicy!"),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_MED, 30 SECONDS , finish_text = "You can smell fried blood sausage!")

	)

/datum/chewin_cooking/recipe/fried_blood_sausage_five
	name = "Fried Blood Sausages (5 Servings)"
	cooking_container = PAN
	product_type = /obj/item/food/fried_blood_sausage
	food_category = CAT_BULK
	product_count = 5
	recipe_guide = "Put five blood sausages in a pan, cook for 45 seconds on medium."
	step_builder = list(

		CHEWIN_BEGIN_OPTION_CHAIN,
		list(CHEWIN_ADD_ITEM_OPTIONAL, /obj/item/food/butter, base=10, reagent_skip=TRUE),
		list(CHEWIN_USE_STOVE_OPTIONAL, J_LO, 10 SECONDS, finish_text = "The butter melts in the pan!"),
		CHEWIN_END_OPTION_CHAIN,

		list(CHEWIN_ADD_ITEM, /obj/item/food/raw_tiziran_sausage, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/raw_tiziran_sausage, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/raw_tiziran_sausage, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/raw_tiziran_sausage, qmod=0.5),
		list(CHEWIN_ADD_ITEM, /obj/item/food/raw_tiziran_sausage, qmod=0.5),

		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/korta_flour, 20, base=3),

		CHEWIN_BEGIN_EXCLUSIVE_OPTIONS,
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/blood, 30, remain_percent = 0.2 , base=3, prod_desc="Extra Bloody!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/honey, 30, remain_percent = 0.2 , base=4, prod_desc="Extra Sweet!"),
		list(CHEWIN_ADD_REAGENT_OPTIONAL, /datum/reagent/consumable/capsaicin, 10, remain_percent = 0.2, base=6, prod_desc="Extra Spicy!"),
		CHEWIN_END_EXCLUSIVE_OPTIONS,

		list(CHEWIN_USE_STOVE, J_MED, 56 SECONDS , finish_text = "You can smell fried blood sausages!")

	)
