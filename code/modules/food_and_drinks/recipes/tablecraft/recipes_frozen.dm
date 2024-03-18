
/////////////////
//Misc. Frozen.//
/////////////////

/datum/crafting_recipe/food/icecreamsandwich
	name = "Icecream sandwich"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/ice = 5,
		/obj/item/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/reagent_containers/food/snacks/icecreamsandwich
	category = CAT_ICE

/datum/crafting_recipe/food/spacefreezy
	name ="Space freezy"
	reqs = list(
		/datum/reagent/consumable/bluecherryjelly = 5,
		/datum/reagent/consumable/spacemountainwind = 15,
		/obj/item/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/reagent_containers/food/snacks/spacefreezy
	category = CAT_ICE

/datum/crafting_recipe/food/sundae
	name ="Sundae"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/obj/item/reagent_containers/food/snacks/grown/cherries = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sundae
	category = CAT_ICE

/datum/crafting_recipe/food/honkdae
	name ="Honkdae"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/reagent_containers/food/snacks/grown/cherries = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 2,
		/obj/item/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/reagent_containers/food/snacks/honkdae
	category = CAT_ICE

/datum/crafting_recipe/food/taiyaki
	name ="Vanilla Taiyaki"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/cookie = 1,
		/obj/item/reagent_containers/food/snacks/grown/cherries = 1,
		/obj/item/reagent_containers/food/snacks/icecream = 1,
		/datum/reagent/consumable/cooking_oil/fish = 1
	)
	result = /obj/item/reagent_containers/food/snacks/taiyaki
	category = CAT_ICE

/datum/crafting_recipe/food/taiyaki/chocolate
	name ="Chocolate Taiyaki"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/cookie = 1,
		/obj/item/reagent_containers/food/snacks/grown/cherries = 1,
		/obj/item/reagent_containers/food/snacks/icecream = 1,
		/datum/reagent/consumable/cooking_oil/fish = 1,
		/datum/reagent/consumable/coco = 2
	)
	result = /obj/item/reagent_containers/food/snacks/taiyaki/chocolate
	category = CAT_ICE

/datum/crafting_recipe/food/taiyaki/strawberry
	name ="Strawberry Taiyaki"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/cookie = 1,
		/obj/item/reagent_containers/food/snacks/grown/bluecherries = 1,
		/obj/item/reagent_containers/food/snacks/icecream = 1,
		/datum/reagent/consumable/cooking_oil/fish = 1,
		/datum/reagent/consumable/berryjuice = 2
	)
	result = /obj/item/reagent_containers/food/snacks/taiyaki/strawberry
	category = CAT_ICE

/datum/crafting_recipe/food/taiyaki/blue
	name ="Blue Taiyaki"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/cookie = 1,
		/obj/item/reagent_containers/food/snacks/grown/cherries = 1,
		/obj/item/reagent_containers/food/snacks/icecream = 1,
		/datum/reagent/consumable/cooking_oil/fish = 1,
		/datum/reagent/consumable/ethanol/singulo = 2
	)
	result = /obj/item/reagent_containers/food/snacks/taiyaki/blue
	category = CAT_ICE

/datum/crafting_recipe/food/taiyaki/mobflavor
	name ="Blood Taiyaki"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/cookie = 1,
		/obj/item/reagent_containers/food/snacks/grown/bluecherries = 1,
		/obj/item/reagent_containers/food/snacks/icecream = 1,
		/datum/reagent/consumable/cooking_oil/fish = 1,
		/datum/reagent/blood = 2
	)
	result = /obj/item/reagent_containers/food/snacks/taiyaki/mobflavor
	category = CAT_ICE

//////////////////////////SNOW CONES///////////////////////

/datum/crafting_recipe/food/flavorless_sc
	name = "Flavorless snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones
	category = CAT_ICE

/datum/crafting_recipe/food/pineapple_sc
	name = "Pineapple snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/pineapplejuice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/pineapple
	category = CAT_ICE

/datum/crafting_recipe/food/lime_sc
	name = "Lime snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/limejuice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/lime
	category = CAT_ICE

/datum/crafting_recipe/food/lemon_sc
	name = "Lemon snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/lemonjuice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/lemon
	category = CAT_ICE

/datum/crafting_recipe/food/apple_sc
	name = "Apple snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/applejuice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/apple
	category = CAT_ICE

/datum/crafting_recipe/food/grape_sc
	name = "Grape snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/grapejuice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/grape
	category = CAT_ICE

/datum/crafting_recipe/food/orange_sc
	name = "Orange snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/orangejuice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/orange
	category = CAT_ICE

/datum/crafting_recipe/food/blue_sc
	name = "Bluecherry snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/bluecherryjelly = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/blue
	category = CAT_ICE

/datum/crafting_recipe/food/red_sc
	name = "Cherry snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/cherryjelly = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/red
	category = CAT_ICE

/datum/crafting_recipe/food/berry_sc
	name = "Berry snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/berryjuice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/berry
	category = CAT_ICE

/datum/crafting_recipe/food/fruitsalad_sc
	name = "Fruit salad snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/orangejuice = 5,
		/datum/reagent/consumable/limejuice = 5,
		/datum/reagent/consumable/lemonjuice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/fruitsalad
	category = CAT_ICE

/datum/crafting_recipe/food/mime_sc
	name = "Mime snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/nothing = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/mime
	category = CAT_ICE

/datum/crafting_recipe/food/clown_sc
	name = "Clown snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/laughter = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/clown
	category = CAT_ICE

/datum/crafting_recipe/food/soda_sc
	name = "Space Cola snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/space_cola = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/soda
	category = CAT_ICE

/datum/crafting_recipe/food/spacemountainwind_sc
	name = "Space Mountain Wind snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/spacemountainwind = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/spacemountainwind
	category = CAT_ICE

/datum/crafting_recipe/food/pwgrmer_sc
	name = "Pwergamer snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/pwr_game = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/pwrgame
	category = CAT_ICE

/datum/crafting_recipe/food/honey_sc
	name = "Honey snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/honey
	category = CAT_ICE

/datum/crafting_recipe/food/rainbow_sc
	name = "Rainbow snowcone"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/colorful_reagent = 1 //Harder to make
	)
	result = /obj/item/reagent_containers/food/snacks/snowcones/rainbow
	category = CAT_ICE
