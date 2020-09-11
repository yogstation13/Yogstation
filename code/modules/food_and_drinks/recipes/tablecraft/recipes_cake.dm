
// see code/module/crafting/table.dm

////////////////////////////////////////////////CAKE////////////////////////////////////////////////

/datum/crafting_recipe/food/applecake
	name = "Apple Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/apple
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/birthdaycake
	name = "Birthday Cake"
	reqs = list(
		/obj/item/clothing/head/hardhat/cakehat = 1,
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/birthday
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/braincake
	name = "Brain Cake"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/brain
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/carrotcake
	name = "Carrot Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/carrot
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/cheesecake
	name = "Cheese Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/cheese
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/chocolatecake
	name = "Chocolate Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/chocolate
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/donkcake
	name = "Donk Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/donkpocket/warm = 2,
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/donk
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/lemoncake
	name = "Lemon Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/lemon
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/limecake
	name = "Lime Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/lime
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/cak
	name = "Living Cat/Cake Hybrid"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/reagent_containers/food/snacks/store/cake/birthday = 1,
		/obj/item/reagent_containers/food/snacks/meat/slab = 3,
		/datum/reagent/blood = 30,
		/datum/reagent/consumable/sprinkles = 5,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	result = /mob/living/simple_animal/pet/cat/cak
	subcategory = CAT_CAKE //Cat! Haha, get it? CAT? GET IT???

/datum/crafting_recipe/food/orangecake
	name = "Orange Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/orange
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/pumpkinspicecake
	name = "Pumpkin Spice Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/pumpkinspice
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/slimecake
	name = "Slime Cake"
	reqs = list(
		/obj/item/slime_extract = 1,
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/slimecake
	subcategory = CAT_CAKE