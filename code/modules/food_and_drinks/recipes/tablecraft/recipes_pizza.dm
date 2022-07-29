
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIZZA!!!////////////////////////////////////////////////

/datum/crafting_recipe/food/arnold
	name = "Arnold Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/meat/raw_cutlet = 3,
		/obj/item/ammo_casing/c9mm = 8,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/arnold/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/dankpizza
	name = "Dank Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/dank/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/donkpocketpizza
	name = "Donkpocket Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/donkpocket/warm = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/donkpocket/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/pineapplepizza
	name = "Hawaiian Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/meat/raw_cutlet = 2,
		/obj/item/reagent_containers/food/snacks/pineappleslice = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/pineapple/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/margheritapizza
	name = "Margherita Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 4,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/margherita/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/meatpizza
	name = "Meat Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/meat/raw_cutlet = 4,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/meat/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/mushroompizza
	name = "Mushroom Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom = 5
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/mushroom/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/sassysagepizza
	name = "Sassysage Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/raw_meatball = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/sassysage/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/seafoodpizza
	name = "Tuna Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/fish/tuna = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/seafood/raw
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/vegetablepizza
	name = "Vegetable Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/corn = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/vegetable/raw
	subcategory = CAT_PIZZA
