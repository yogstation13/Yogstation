/datum/brewing_recipe/light_beer
	reagent_to_brew = /datum/reagent/consumable/ethanol/beer/light
	display_name = "Light Beer"
	needed_crops = list(/obj/item/food/grown/wheat = 40, /obj/item/food/grown/poppy = 5)
	needed_reagents = list(/datum/reagent/water = 60)

	cargo_valuation = 1750
	brew_time = 2 MINUTES
	brewed_amount = 12
	helpful_hints = "Can be brewed again into regular beer"

/datum/brewing_recipe/beer
	reagent_to_brew = /datum/reagent/consumable/ethanol/beer
	pre_reqs = /datum/reagent/consumable/ethanol/beer/light
	display_name = "Beer"
	needed_crops = list(/obj/item/food/grown/wheat = 10, /obj/item/food/grown/poppy = 5)
	needed_reagents = list(/datum/reagent/water = 60)

	cargo_valuation = 2250
	brew_time = 2 MINUTES
	brewed_amount = 6
