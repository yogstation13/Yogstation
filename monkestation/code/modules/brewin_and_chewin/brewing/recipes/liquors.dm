/datum/brewing_recipe/melon_liquor
	reagent_to_brew = /datum/reagent/consumable/ethanol/melon_liquor
	display_name = "Melon Liquor"
	needed_items = list(/obj/item/grown/log = 5)
	needed_crops = list(/obj/item/food/grown/watermelon = 80, /obj/item/food/grown/poppy = 35)
	needed_reagents = list(/datum/reagent/water = 160)
	brewed_amount = 2

	cargo_valuation = 2000
	brew_time = 6 MINUTES

/datum/brewing_recipe/red_candy_liquor
	reagent_to_brew = /datum/reagent/consumable/ethanol/candy_wine
	display_name = "Red Candy Liquor"
	pre_reqs = /datum/reagent/consumable/ethanol/wine
	brewed_amount = 1
	needed_crops = list(/obj/item/food/grown/grapes = 10, /obj/item/food/grown/sunflower = 5, /obj/item/food/grown/harebell = 5)
	needed_reagents = list(/datum/reagent/consumable/sugar = 15)

	cargo_valuation = 7000
	brew_time = 16 MINUTES
