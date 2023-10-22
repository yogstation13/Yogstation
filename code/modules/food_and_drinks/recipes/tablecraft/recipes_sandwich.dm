
// see code/datums/recipe.dm
// see code/module/crafting/table.dm

////////////////////////////////////////////////SANDWICHES////////////////////////////////////////////////

/datum/crafting_recipe/food/grilledcheesesandwich
	name = "Cheese Sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/reagent_containers/food/snacks/grilledcheese
	category = CAT_SANDWICH

/datum/crafting_recipe/food/slimesandwich
	name = "Jelly Sandwich"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2
	)
	result = /obj/item/reagent_containers/food/snacks/jellysandwich/slime
	category = CAT_SANDWICH

/datum/crafting_recipe/food/cherrysandwich
	name = "Jelly Sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2
	)
	result = /obj/item/reagent_containers/food/snacks/jellysandwich/cherry
	category = CAT_SANDWICH

/datum/crafting_recipe/food/notasandwich
	name = "Not a Sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/clothing/mask/fakemoustache = 1
	)
	result = /obj/item/reagent_containers/food/snacks/notasandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/pbb_sandwich
	name = "Peanut Butter and Banana Sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2,
		/datum/reagent/consumable/peanut_butter = 5,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pbb_sandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/pbj_sandwich
	name = "Peanut Butter and Jelly Sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2,
		/datum/reagent/consumable/peanut_butter = 5,
		/datum/reagent/consumable/cherryjelly = 5
	)
	result = /obj/item/reagent_containers/food/snacks/pbj_sandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2,
		/obj/item/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sandwich
	category = CAT_SANDWICH
