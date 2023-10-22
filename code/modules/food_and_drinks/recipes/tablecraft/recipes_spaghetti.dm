
// see code/module/crafting/table.dm

////////////////////////////////////////////////SPAGHETTI////////////////////////////////////////////////

/datum/crafting_recipe/food/beefnoodle
	name = "Beef Noodle"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/reagent_containers/food/snacks/spaghetti/beefnoodle
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/butternoodles
	name = "Butter Noodles"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 3
	)
	result = /obj/item/reagent_containers/food/snacks/spaghetti/butternoodles
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/chowmein
	name = "Chow Mein"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 2,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1
	)
	result = /obj/item/reagent_containers/food/snacks/spaghetti/chowmein
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/copypasta
	name = "Copypasta"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato = 2
	)
	result = /obj/item/reagent_containers/food/snacks/spaghetti/copypasta
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/falfredo
	name = "Fettuccine Alfredo"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge/parmesan = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 2,
		/datum/reagent/consumable/cream = 5
	)
	result = /obj/item/reagent_containers/food/snacks/spaghetti/falfredo
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/lasagna
	name = "Lasagna"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 2,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/meat/steak/plain = 2,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/lasagna
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/tomatopasta
	name = "Spaghetti"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 2
	)
	result = /obj/item/reagent_containers/food/snacks/spaghetti/pastatomato
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/spaghettimeatball
	name = "Spaghetti and Meatballs"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 2
	)
	result = /obj/item/reagent_containers/food/snacks/spaghetti/meatballspaghetti
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/spesslaw
	name = "Spesslaw"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 4
	)
	result = /obj/item/reagent_containers/food/snacks/spaghetti/spesslaw
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/pizzaghetti
	name = "Pizzaghetti"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzaslice/margherita = 3,
		/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato  = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizzaghetti
	category = CAT_SPAGHETTI
