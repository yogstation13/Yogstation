/datum/crafting_recipe/food/bait

/datum/crafting_recipe/food/bait/apprentice
	name = "Apprentice Bait"
	reqs = list(
		/datum/reagent/water = 2,
		/datum/reagent/consumable/flour = 5,
		/obj/item/reagent_containers/food/snacks/grown/corn = 1
	)
	result = /obj/item/reagent_containers/food/snacks/bait/apprentice
	subcategory = CAT_BAIT

/datum/crafting_recipe/food/bait/journeyman
	name = "Journeyman Bait"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/bait/apprentice = 2,
		/datum/reagent/blood = 5
	)
	result = /obj/item/reagent_containers/food/snacks/bait/journeyman
	subcategory = CAT_BAIT

/datum/crafting_recipe/food/bait/master
	name = "Master Bait"
	reqs = list(
		/datum/reagent/toxin/plasma = 5,
		/obj/item/reagent_containers/food/snacks/bait/journeyman = 2,
		/obj/item/reagent_containers/food/snacks/fish/shrimp = 1
	)
	result = /obj/item/reagent_containers/food/snacks/bait/master
	subcategory = CAT_BAIT

/datum/crafting_recipe/food/bait/wild
	name = "Wild Bait"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/bait/worm = 1,
		/obj/item/stack/medical/gauze/improvised = 1
	)
	result = /obj/item/reagent_containers/food/snacks/bait/type/wild
	subcategory = CAT_BAIT

