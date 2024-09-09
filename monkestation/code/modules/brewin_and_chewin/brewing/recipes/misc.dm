/datum/brewing_recipe/gin
	reagent_to_brew = /datum/reagent/consumable/ethanol/gin
	display_name = "Gin"
	needed_items = list(/obj/item/grown/log = 5)
	needed_crops = list(/obj/item/food/grown/berries = 40, /obj/item/food/grown/citrus/lemon = 40)
	needed_reagents = list(/datum/reagent/water = 160, /datum/reagent/consumable/sugar = 15)
	brewed_amount = 3

	cargo_valuation = 3200
	brew_time = 6 MINUTES

/datum/brewing_recipe/tequila
	reagent_to_brew = /datum/reagent/consumable/ethanol/tequila
	display_name = "Tequila"
	needed_items = list(/obj/item/grown/log = 5)
	needed_crops = list(/obj/item/food/grown/citrus/lemon = 40, /obj/item/food/grown/citrus/lime = 40, /obj/item/food/grown/pineapple = 10)
	needed_reagents = list(/datum/reagent/water = 50, /datum/reagent/consumable/salt = 5)
	brewed_amount = 2

	cargo_valuation = 2250
	brew_time = 3 MINUTES

/datum/brewing_recipe/patron
	reagent_to_brew = /datum/reagent/consumable/ethanol/patron
	display_name = "Patron"
	needed_crops = list(/obj/item/food/grown/wheat = 80)
	needed_reagents = list(/datum/reagent/water = 30, /datum/reagent/consumable/mintextract = 5)
	brewed_amount = 1

	cargo_valuation = 2000
	brew_time = 1.5 MINUTES

/datum/brewing_recipe/ale
	reagent_to_brew = /datum/reagent/consumable/ethanol/ale
	display_name = "Ale"
	needed_crops = list(/obj/item/food/grown/wheat = 60, /obj/item/food/grown/poppy = 5)
	needed_reagents = list(/datum/reagent/water = 120, /datum/reagent/consumable/honey = 5)
	brewed_amount = 12

	cargo_valuation = 2000
	brew_time = 9 MINUTES

/datum/brewing_recipe/whiskey
	reagent_to_brew = /datum/reagent/consumable/ethanol/whiskey
	display_name = "Whiskey"
	needed_crops = list(/obj/item/food/grown/wheat = 40)
	needed_reagents = list(/datum/reagent/water = 120)
	brewed_amount = 10

	cargo_valuation = 2000
	brew_time = 15 MINUTES

/datum/brewing_recipe/glucose
	reagent_to_brew = /datum/reagent/consumable/nutriment/glucose
	display_name = "Glucose"
	needed_crops = list(/obj/item/food/grown/wheat = 60, /obj/item/food/grown/corn = 30)
	needed_reagents = list(/datum/reagent/water = 120, /datum/reagent/consumable/honey = 5, /datum/reagent/consumable/sugar = 30)
	brewed_amount = 3
	per_brew_amount = 15

	cargo_valuation = 4750
	brew_time = 3 MINUTES
	helpful_hints = "Further brewing can be done when finished."

/datum/brewing_recipe/nothing
	reagent_to_brew = /datum/reagent/consumable/nothing
	pre_reqs = /datum/reagent/consumable/nutriment/glucose
	display_name = "Nothing"
	needed_reagents = list(/datum/reagent/water = 200)
	brewed_amount = 2

	cargo_valuation = 404
	brew_time = 7 MINUTES

/datum/brewing_recipe/cream
	reagent_to_brew = /datum/reagent/consumable/cream
	display_name = "Cream"
	brewed_amount = 3
	needed_crops = list(/obj/item/food/grown/soybeans = 40)
	needed_reagents = list(/datum/reagent/consumable/vinegar = 10, /datum/reagent/consumable/milk = 30)

	cargo_valuation = 1600
	brew_time = 2 MINUTES
	helpful_hints = "Further brewing can be done when finished."
