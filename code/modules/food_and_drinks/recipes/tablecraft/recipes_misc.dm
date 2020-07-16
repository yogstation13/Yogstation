
// see code/module/crafting/table.dm

////////////////////////////////////////////////TOAST////////////////////////////////////////////////

/datum/crafting_recipe/food/butteredtoast
	name = "Buttered Toast"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 1,
		/obj/item/reagent_containers/food/snacks/butter = 1
	)
	result = /obj/item/reagent_containers/food/snacks/butteredtoast
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/jelliedyoast
	name = "Jellied Toast"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/cherry
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/slimetoast
	name = "Slime Toast"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/slime
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/twobread
	name = "Two Bread"
	reqs = list(
		/datum/reagent/consumable/ethanol/wine = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2
	)
	result = /obj/item/reagent_containers/food/snacks/twobread
	subcategory = CAT_MISCFOOD

////////////////////////////////////////////////MISC//////////////////////////////////////////////////

/datum/crafting_recipe/food/baguette
	name = "Baguette"
	time = 40
	reqs = list(/datum/reagent/consumable/sodiumchloride = 1,
				/datum/reagent/consumable/blackpepper = 1,
				/obj/item/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/reagent_containers/food/snacks/baguette
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/beans
	name = "Beans"
	time = 40
	reqs = list(/datum/reagent/consumable/ketchup = 5,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 2
	)
	result = /obj/item/reagent_containers/food/snacks/beans
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/branrequests
	name = "Bran Requests Cereal"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/wheat = 1,
		/obj/item/reagent_containers/food/snacks/no_raisin = 1
	)
	result = /obj/item/reagent_containers/food/snacks/branrequests
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/burrito
	name ="Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 2
	)
	result = /obj/item/reagent_containers/food/snacks/burrito
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/candiedapple
	name = "Candied Apple"
	reqs = list(
		/datum/reagent/consumable/caramel = 5,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/reagent_containers/food/snacks/candiedapple
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/carneburrito
	name ="Carne de Asada Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/reagent_containers/food/snacks/carneburrito
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesyburrito
	name ="Cheesy Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cheesyburrito
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesyfries
	name = "Cheesy Fries"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/fries = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cheesyfries
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/poutine
	name = "Poutine"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/fries = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge/cheddar = 1,
		/datum/reagent/consumable/gravy = 10
	)
	result = /obj/item/reagent_containers/food/snacks/poutine
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesynachos
	name ="Cheesy Nachos"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cheesynachos
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/chococoin
	name = "Chocolate Coin"
	reqs = list(
		/obj/item/coin = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/chococoin
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/chocoorange
	name = "Chocolate Orange"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/chocoorange
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/taco
	name ="Classic Taco"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/reagent_containers/food/snacks/taco
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/cubannachos
	name ="Cuban Nachos"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/reagent_containers/food/snacks/grown/chili = 2,
		/obj/item/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cubannachos
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/dolphinandchips
	name = "Dolphin and Chips"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/dolphinmeat = 3,
		/obj/item/reagent_containers/food/snacks/chips = 1
	)
	result = /obj/item/reagent_containers/food/snacks/dolphinandchips
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/dolphincereal
	name = "Dolphin Cereal"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/dolphinmeat = 2,
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/flour = 15
	)
	result = /obj/item/reagent_containers/food/snacks/dolphincereal
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/eggplantparm
	name ="Eggplant Parmigiana"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/reagent_containers/food/snacks/grown/eggplant = 1
	)
	result = /obj/item/reagent_containers/food/snacks/eggplantparm
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/fudgedice
	name = "Fudge Dice"
	reqs = list(
		/obj/item/dice = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fudgedice
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/fuegoburrito
	name ="Fuego Plasma Burrito"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/grown/ghost_chili = 2,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fuegoburrito
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/honeybar
	name = "Honey Nut Bar"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/oat = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/reagent_containers/food/snacks/honeybar
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/loadedbakedpotato
	name = "Loaded Baked Potato"
	time = 40
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/loadedbakedpotato
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/melonfruitbowl
	name ="Melon Fruit Bowl"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/watermelon = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia = 1
	)
	result = /obj/item/reagent_containers/food/snacks/melonfruitbowl
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/melonkeg
	name ="Melon Keg"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 25,
		/obj/item/reagent_containers/food/snacks/grown/holymelon = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 1
	)
	parts = list(/obj/item/reagent_containers/food/drinks/bottle/vodka = 1)
	result = /obj/item/reagent_containers/food/snacks/melonkeg
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/nachos
	name ="Nachos"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/reagent_containers/food/snacks/nachos
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/tacoplain
	name ="Plain Taco"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/taco/plain
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/powercrepe
	name = "Powercrepe"
	time = 40
	reqs = list(
		/obj/item/reagent_containers/food/snacks/flatdough = 1,
		/datum/reagent/consumable/milk = 1,
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/stock_parts/cell/super = 1,
		/obj/item/melee/sabre = 1
	)
	result = /obj/item/reagent_containers/food/snacks/powercrepe
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/ricepudding
	name = "Rice Pudding"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/ricepudding
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/spiderlollipop
	name = "Spider Lollipop"
	reqs = list(/obj/item/stack/rods = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/water = 5,
		/obj/item/reagent_containers/food/snacks/spiderling = 1
	)
	result = /obj/item/reagent_containers/food/snacks/spiderlollipop
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/stuffedlegion
	name = "Stuffed Legion"
	time = 40
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/steak/goliath = 1,
		/obj/item/organ/regenerative_core/legion = 1,
		/datum/reagent/consumable/ketchup = 2,
		/datum/reagent/consumable/capsaicin = 2
	)
	result = /obj/item/reagent_containers/food/snacks/stuffedlegion
	subcategory = CAT_MISCFOOD
