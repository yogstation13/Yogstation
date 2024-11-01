/datum/chewin_cooking/recipe/sambal
    name = "Sambal"
    cooking_container = BOWL
    product_type = /obj/item/food/sambal
    recipe_guide = "Mix all ingredients in a bowl."
    step_builder = list(
        list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/chili),
        list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/garlic),
        list(CHEWIN_ADD_PRODUCE, /obj/item/food/grown/onion),
        list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/sugar, 3),
        list(CHEWIN_ADD_REAGENT, /datum/reagent/consumable/limejuice, 3)
    )
