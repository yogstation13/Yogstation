
// see code/module/crafting/table.dm

////////////////////////////////////////////////EGG RECIPES////////////////////////////////////////////////

/datum/crafting_recipe/food/chocolateegg
	name = "Chocolate Egg"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledegg = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/chocolateegg
	subcategory = CAT_EGG

/datum/crafting_recipe/food/eggsbenedict
	name = "Eggs Benedict"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/friedegg = 1,
		/obj/item/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/benedict
	subcategory = CAT_EGG

/datum/crafting_recipe/food/eggbowl
	name = "Egg Bowl"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/boiledegg = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/corn = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/eggbowl
	subcategory = CAT_EGG

/datum/crafting_recipe/food/wrap
	name = "Egg Wrap"
	reqs = list(/datum/reagent/consumable/soysauce = 10,
		/obj/item/reagent_containers/food/snacks/friedegg = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/reagent_containers/food/snacks/eggwrap
	subcategory = CAT_EGG

/datum/crafting_recipe/food/friedegg
	name = "Fried Egg"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/reagent_containers/food/snacks/egg = 1
	)
	result = /obj/item/reagent_containers/food/snacks/friedegg
	subcategory = CAT_EGG

/datum/crafting_recipe/food/spidereggsham
	name = "Green Eggs and Ham"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/reagent_containers/food/snacks/spidereggs = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/spider = 2
	)
	result = /obj/item/reagent_containers/food/snacks/spidereggsham
	subcategory = CAT_EGG

/datum/crafting_recipe/food/eggdog
	name = "Living Egg/Dog Hybrid"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/clothing/head/cueball = 1, //Can be found in the clown's vendor
		/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 3,
		/datum/reagent/blood = 30,
		/obj/item/reagent_containers/food/snacks/egg = 12,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	result = /mob/living/simple_animal/pet/dog/eggdog
	subcategory = CAT_EGG

/datum/crafting_recipe/food/omelette
	name = "Omelette Du Fromage"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/egg = 2,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/reagent_containers/food/snacks/omelette
	subcategory = CAT_EGG