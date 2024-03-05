
// see code/module/crafting/table.dm

////////////////////////////////////////////////MISC//////////////////////////////////////////////////

/datum/crafting_recipe/food/beans
	name = "Beans"
	time = 4 SECONDS
	reqs = list(/datum/reagent/consumable/ketchup = 5,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 2
	)
	result = /obj/item/reagent_containers/food/snacks/beans
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/branrequests
	name = "Bran Requests Cereal"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/wheat = 1,
		/obj/item/reagent_containers/food/snacks/no_raisin = 1
	)
	result = /obj/item/reagent_containers/food/snacks/branrequests
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/burrito
	name ="Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 2
	)
	result = /obj/item/reagent_containers/food/snacks/burrito
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/fivelayerburrito
	name ="Five Layer Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/burrito = 5
	)
	result = /obj/item/reagent_containers/food/snacks/fivelayerburrito
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/candiedapple
	name = "Candied Apple"
	reqs = list(
		/datum/reagent/consumable/caramel = 5,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/reagent_containers/food/snacks/candiedapple
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/carneburrito
	name ="Carne de Asada Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/reagent_containers/food/snacks/carneburrito
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesyburrito
	name ="Cheesy Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cheesyburrito
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesyfries
	name = "Cheesy Fries"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/fries = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cheesyfries
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/poutine
	name = "Poutine"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/fries = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge/cheddar = 1,
		/datum/reagent/consumable/gravy = 10
	)
	result = /obj/item/reagent_containers/food/snacks/poutine
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesynachos
	name ="Cheesy Nachos"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cheesynachos
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/chococoin
	name = "Chocolate Coin"
	reqs = list(
		/obj/item/coin = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/chococoin
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/chocoorange
	name = "Chocolate Orange"
	reqs = list(
		/datum/reagent/consumable/orangejuice = 2,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/chocoorange
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/taco
	name ="Classic Taco"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/reagent_containers/food/snacks/taco
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/cubannachos
	name ="Cuban Nachos"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/reagent_containers/food/snacks/grown/chili = 2,
		/obj/item/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cubannachos
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/eggplantparm
	name ="Eggplant Parmigiana"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/reagent_containers/food/snacks/grown/eggplant = 1
	)
	result = /obj/item/reagent_containers/food/snacks/eggplantparm
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/fudgedice
	name = "Fudge Dice"
	reqs = list(
		/obj/item/dice = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fudgedice
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/fuegoburrito
	name ="Fuego Plasma Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/grown/ghost_chili = 2,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fuegoburrito
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/granola_bar
	name ="Granola Bar"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/oat = 1,
		/obj/item/reagent_containers/food/snacks/grown/peanut = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1,
		/obj/item/reagent_containers/food/snacks/no_raisin = 1,
		/datum/reagent/consumable/sugar = 2
	)
	result = /obj/item/reagent_containers/food/snacks/granola_bar
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/honeybar
	name = "Honey Nut Bar"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/oat = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/reagent_containers/food/snacks/honeybar
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/loadedbakedpotato
	name = "Loaded Baked Potato"
	time = 4 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/loadedbakedpotato
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/melonfruitbowl
	name ="Melon Fruit Bowl"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/watermelon = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia = 1
	)
	result = /obj/item/reagent_containers/food/snacks/melonfruitbowl
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/melonkeg
	name ="Melon Keg"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 25,
		/obj/item/reagent_containers/food/snacks/grown/holymelon = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 1
	)
	parts = list(/obj/item/reagent_containers/food/drinks/bottle/vodka = 1)
	result = /obj/item/reagent_containers/food/snacks/melonkeg
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/nachos
	name ="Nachos"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/reagent_containers/food/snacks/nachos
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/onigiri
	name ="Onigiri"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/seaweedsheet = 1,
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/onigiri
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/pickle
	name ="Pickle"
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/sodiumchloride = 2,
		/obj/item/reagent_containers/food/snacks/grown/cucumber = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pickle
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/tacoplain
	name ="Plain Taco"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/taco/plain
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/powercrepe
	name = "Powercrepe"
	time = 4 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/datum/reagent/consumable/milk = 1,
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/stock_parts/cell/super = 1,
		/obj/item/melee/sabre = 1
	)
	result = /obj/item/reagent_containers/food/snacks/powercrepe
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/ricepudding
	name = "Rice Pudding"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/ricepudding
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/spiderlollipop
	name = "Spider Lollipop"
	reqs = list(/obj/item/stack/rods = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/water = 5,
		/obj/item/reagent_containers/food/snacks/spiderling = 1
	)
	result = /obj/item/reagent_containers/food/snacks/spiderlollipop
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/stuffedlegion
	name = "Stuffed Legion"
	time = 4 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/steak/goliath = 1,
		/obj/item/organ/regenerative_core/legion = 1,
		/datum/reagent/consumable/ketchup = 2,
		/datum/reagent/consumable/capsaicin = 2
	)
	result = /obj/item/reagent_containers/food/snacks/stuffedlegion
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/candy_strawberry
	name = "Strawberry Flavored Candy"
	time = 2 SECONDS
	reqs = list(
		/datum/reagent/blood = 5, //Close enough to strawberries
		/datum/reagent/consumable/sugar = 5,
		/obj/item/paper = 1 //This is normal paper used as wrapping paper, its intentional
	)
	tool_paths = list(/obj/item/toy/crayon)
	result = /obj/item/reagent_containers/food/snacks/candy_strawberry
	category = CAT_MISCFOOD


/datum/crafting_recipe/food/royalcheese
	name = "Royal Cheese"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/cheesewheel/cheddar = 1,
		/obj/item/clothing/head/crown = 1,
		/datum/reagent/medicine/strange_reagent = 5,
		/datum/reagent/toxin/mutagen = 5
	)
	result = /obj/item/reagent_containers/food/snacks/royalcheese
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/chipsandsalsa
	name = "Chips and Salsa"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/chips = 1, //yogs, no cornchips
		/obj/item/reagent_containers/food/snacks/grown/chili = 1,
		/obj/item/reagent_containers/food/snacks/grown/onion = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/chipsandsalsa
	category = CAT_MISCFOOD
	
/datum/crafting_recipe/food/pineapple_rice
	name = "Hawaiian Pineapple Rice"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/pineapple = 1,
		/datum/reagent/consumable/rice = 5
	)
	result = /obj/item/reagent_containers/food/snacks/pineapple_rice
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/pineapple_friedrice
	name = "Hawaiian Pineapple Fried Rice"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/pineapple = 1,
		/datum/reagent/consumable/rice = 5,
		/obj/item/reagent_containers/food/snacks/pineappleslice/grilled = 1,
		/obj/item/reagent_containers/food/snacks/grown/chili = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/datum/reagent/consumable/lemonjuice = 1,
		/datum/reagent/consumable/limejuice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pineapple_friedrice
	category = CAT_MISCFOOD
