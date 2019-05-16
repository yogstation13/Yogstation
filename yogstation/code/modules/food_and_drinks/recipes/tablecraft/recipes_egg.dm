/datum/crafting_recipe/food/eggdog
	name = "Living egg/dog hybrid"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/clothing/head/cueball = 1, //Can be found in the clowns vendor
		/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 3, //Has science gone too far?!?!
		/datum/reagent/blood = 30,
		/obj/item/reagent_containers/food/snacks/egg = 12,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	result = /mob/living/simple_animal/pet/eggdog
	subcategory = CAT_EGG