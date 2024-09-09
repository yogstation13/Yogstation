/datum/brewing_recipe/lizard_wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/lizardwine
	display_name = "Lizard Wine"
	needed_items  = list(/obj/item/organ/external/tail/lizard = 1)
	needed_crops = list(/obj/item/food/grown/poppy = 5)
	needed_reagents = list(/datum/reagent/water = 50, /datum/reagent/consumable/ethanol = 100)
	brewed_amount = 3

	cargo_valuation = 10000
	brew_time = 10 MINUTES

/datum/brewing_recipe/wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/wine
	display_name = "Wine"
	needed_items  = list(/obj/item/grown/log = 5)
	needed_crops = list(/obj/item/food/grown/grapes = 60)
	needed_reagents = list(/datum/reagent/water = 160, /datum/reagent/consumable/sugar = 15)
	brewed_amount = 2

	cargo_valuation = 3000
	brew_time = 6 MINUTES
	helpful_hints = "Further brewing can be done when finished."

/datum/brewing_recipe/vermouth
	reagent_to_brew = /datum/reagent/consumable/ethanol/vermouth
	display_name = "Vermouth"
	pre_reqs = /datum/reagent/consumable/ethanol/wine
	needed_items  = list(/obj/item/grown/log = 7)
	needed_crops = list(/obj/item/food/grown/grapes = 60, /obj/item/food/grown/berries = 15)
	needed_reagents = list(/datum/reagent/water = 160)
	brewed_amount = 3

	cargo_valuation = 5000
	brew_time = 8 MINUTES

/datum/brewing_recipe/poison_wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/poison_wine
	display_name = "Fungal Wine (poison)"
	pre_reqs = /datum/reagent/consumable/ethanol/wine
	brewed_amount = 1
	needed_items  = list(/obj/item/grown/log = 5)
	needed_crops = list(/obj/item/food/grown/grapes = 10, /obj/item/food/grown/mushroom/plumphelmet = 5)
	needed_reagents = list(/datum/reagent/toxin/amatoxin = 15)

	cargo_valuation = 9000
	brew_time = 16 MINUTES
