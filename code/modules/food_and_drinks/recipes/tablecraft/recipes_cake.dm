
// see code/module/crafting/table.dm

////////////////////////////////////////////////CAKE////////////////////////////////////////////////

/datum/crafting_recipe/food/applecake
	name = "Apple Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/apple
	category = CAT_CAKE

/datum/crafting_recipe/food/birthdaycake
	name = "Birthday Cake"
	reqs = list(
		/obj/item/clothing/head/hardhat/cakehat = 1,
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/birthday
	category = CAT_CAKE

/datum/crafting_recipe/food/braincake
	name = "Brain Cake"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/brain
	category = CAT_CAKE

/datum/crafting_recipe/food/carrotcake
	name = "Carrot Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/carrot
	category = CAT_CAKE

/datum/crafting_recipe/food/cheesecake
	name = "Cheese Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/cheese
	category = CAT_CAKE

/datum/crafting_recipe/food/chocolatecake
	name = "Chocolate Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/chocolate
	category = CAT_CAKE

/datum/crafting_recipe/food/chocolatecheesecake
	name = "Chocolate Cheese Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/chocolate = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/chocolatecheese
	category = CAT_CAKE

/datum/crafting_recipe/food/clowncake
	name = "Clown Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/sundae = 2,
		/obj/item/reagent_containers/food/snacks/grown/banana = 5
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/clown_cake
	category = CAT_CAKE
	always_available = FALSE

/datum/crafting_recipe/food/donkcake
	name = "Donk Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/donkpocket/warm = 2,
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/donk
	category = CAT_CAKE

/datum/crafting_recipe/food/lemoncake
	name = "Lemon Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/lemon
	category = CAT_CAKE

/datum/crafting_recipe/food/limecake
	name = "Lime Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/lime
	category = CAT_CAKE

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
	category = CAT_CAKE //Cat! Haha, get it? CAT? GET IT???

/datum/crafting_recipe/food/orangecake
	name = "Orange Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/orange
	category = CAT_CAKE

/datum/crafting_recipe/food/pumpkinspicecake
	name = "Pumpkin Spice Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/pumpkinspice
	category = CAT_CAKE

/datum/crafting_recipe/food/slimecake
	name = "Slime Cake"
	reqs = list(
		/obj/item/slime_extract = 1,
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/slimecake
	category = CAT_CAKE

/datum/crafting_recipe/food/vanillacake
	name = "Vanilla Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/vanillapod = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/vanilla_cake
	category = CAT_CAKE
	always_available = FALSE

/datum/crafting_recipe/food/weddingcake
	name = "Wedding Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain = 3,
		/datum/reagent/consumable/sugar = 100
	)
	result = /obj/item/reagent_containers/food/snacks/store/cake/wedding
	category = CAT_CAKE
