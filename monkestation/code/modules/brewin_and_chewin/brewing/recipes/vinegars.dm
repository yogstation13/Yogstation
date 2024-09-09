/datum/brewing_recipe/vinegar
	reagent_to_brew = /datum/reagent/consumable/vinegar
	display_name = "Vinegar"
	brewed_amount = 3
	needed_crops = list(/obj/item/food/grown/apple = 20, /obj/item/food/grown/pineapple = 10)
	needed_reagents = list(/datum/reagent/water = 30)

	cargo_valuation = 2500
	brew_time = 3 MINUTES
	helpful_hints = "Further brewing can be done when finished."

/datum/brewing_recipe/cheese_wheel
	reagent_to_brew = /datum/reagent/consumable/vinegar
	pre_reqs = /datum/reagent/consumable/cream
	display_name = "Cheese Wheels (Byproduct Vinegar)"
	brewed_amount = 1
	per_brew_amount = 15 //make an excess
	needed_crops = list(/obj/item/food/grown/apple = 20, /obj/item/food/grown/pineapple = 10)
	needed_reagents = list(/datum/reagent/water = 30, /datum/reagent/consumable/milk = 30, /datum/reagent/consumable/vinegar = 5)

	cargo_valuation = 1000
	brew_time = 1 MINUTES

	brewed_item = /obj/item/food/cheese/wheel
	brewed_item_count = 3
	secondary_name = "Cheese Wheel"
	helpful_hints = "The bottles will produced Vinegar."

/datum/brewing_recipe/enzyme
	reagent_to_brew = /datum/reagent/consumable/enzyme
	pre_reqs = /datum/reagent/consumable/vinegar
	display_name = "Universal Enzymes"
	brewed_amount = 1
	needed_crops = list(/obj/item/food/grown/grass = 120, /obj/item/food/grown/pineapple = 30, /obj/item/food/grown/citrus/orange = 30)
	needed_reagents = list(/datum/reagent/water = 30, /datum/reagent/consumable/ethanol = 60)

	cargo_valuation = 7500
	brew_time = 6 MINUTES

