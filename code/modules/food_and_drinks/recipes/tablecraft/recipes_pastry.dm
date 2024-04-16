
// see code/module/crafting/table.dm

////////////////////////////////////////////////DONUTS////////////////////////////////////////////////

/datum/crafting_recipe/food/chaosdonut
	name = "Chaos Donut"
	reqs = list(
		/datum/reagent/consumable/frostoil = 5,
		/datum/reagent/consumable/capsaicin = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/chaos
	category = CAT_PASTRY

/datum/crafting_recipe/food/cherryjellydonut
	name = "Cherry Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly/cherryjelly
	category = CAT_PASTRY

/datum/crafting_recipe/food/donut
	time = 1.5 SECONDS
	name = "Donut"
	reqs = list(
		/datum/reagent/consumable/sugar = 1,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut
	category = CAT_PASTRY

/datum/crafting_recipe/food/jellydonut
	name = "Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly
	category = CAT_PASTRY

datum/crafting_recipe/food/donut/meat
	time = 1.5 SECONDS
	name = "Meat Donut"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/slab = 1,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/meat
	category = CAT_PASTRY

/datum/crafting_recipe/food/peanut_butter_cookie
	name = "Peanut Butter Cookie"
	reqs = list(
		/datum/reagent/consumable/peanut_butter = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cookie/peanut_butter
	category = CAT_PASTRY

/datum/crafting_recipe/food/raw_brownie_batter
	name = "Raw Brownie Batter"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/egg = 2,
		/datum/reagent/consumable/coco = 5,
		/obj/item/reagent_containers/food/snacks/butterslice = 4
	)
	result = /obj/item/reagent_containers/food/snacks/raw_brownie_batter
	category = CAT_PASTRY

/datum/crafting_recipe/food/slimejellydonut
	name = "Slime Jelly Donut"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly
	category = CAT_PASTRY

/datum/crafting_recipe/food/donut/laugh
	name = "Sweet Pea Donut"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/reagent_containers/food/snacks/donut = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/laugh
	category = CAT_PASTRY

/datum/crafting_recipe/food/donut/vegan
	name = "Vegan Donut"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tofu = 1,
		/obj/item/reagent_containers/food/snacks/donut = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/vegan
	category = CAT_PASTRY

/datum/crafting_recipe/food/donut/jelly/laugh
	name = "Sweet Pea Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/reagent_containers/food/snacks/donut/jelly = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly/laugh
	category = CAT_PASTRY

/datum/crafting_recipe/food/donut/slimejelly/laugh
	name = "Sweet Pea Jelly Donut"
	reqs = list(
		/datum/reagent/consumable/laughsyrup = 3,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/laugh
	category = CAT_PASTRY

/datum/crafting_recipe/food/donut/spaghetti
	name = "Spagh-O-Nut"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donut/spaghetti
	category = CAT_PASTRY

/datum/crafting_recipe/food/donut/spaghetti/jelly
	name = "'Jelly' Spagh-O-Nut"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/datum/reagent/consumable/ketchup = 5
	)
	result = /obj/item/reagent_containers/food/snacks/donut/spaghetti/jelly
	category = CAT_PASTRY
////////////////////////////////////////////////WAFFLES AND PANCAKES////////////////////////////////////////////////

/datum/crafting_recipe/food/bbpancakes
	name = "Blueberry Pancake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pancakes/blueberry
	category = CAT_PASTRY

/datum/crafting_recipe/food/ccpancakes
	name = "Chocolate Chip Pancake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pancakes/chocolatechip
	category = CAT_PASTRY

/datum/crafting_recipe/food/cinpancakes
	name = "Cinnamon Pancake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/datum/reagent/consumable/cinnamon = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pancakes/cinnamon
	category = CAT_PASTRY

/datum/crafting_recipe/food/pancakes
	name = "Pancake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pancakes
	category = CAT_PASTRY

/datum/crafting_recipe/food/rofflewaffles
	name = "Roffle Waffles"
	reqs = list(
		/datum/reagent/drug/mushroomhallucinogen = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/reagent_containers/food/snacks/rofflewaffles
	category = CAT_PASTRY

/datum/crafting_recipe/food/soylentgreen
	name = "Soylent Green"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 2,
		/obj/item/reagent_containers/food/snacks/meat/slab/human = 2
	)
	result = /obj/item/reagent_containers/food/snacks/soylentgreen
	category = CAT_PASTRY

/datum/crafting_recipe/food/soylenviridians
	name = "Soylent Viridians"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 2,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soylenviridians
	category = CAT_PASTRY

/datum/crafting_recipe/food/waffles
	time = 1.5 SECONDS
	name = "Waffles"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/reagent_containers/food/snacks/waffles
	category = CAT_PASTRY

////////////////////////////////////////////////DONK POCKETS////////////////////////////////////////////////

/datum/crafting_recipe/food/donkpocket
	time = 15
	name = "Original Donkpocket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket
	category = CAT_PASTRY

/datum/crafting_recipe/food/dankpocket
	time = 15
	name = "Dank-pocket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/cannabis = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket/dank
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/spicy
	time = 15
	name = "Spicy Donkpocket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1,
		/obj/item/reagent_containers/food/snacks/grown/chili = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket/spicy
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/teriyaki
	time = 15
	name = "Teriyaki Donkpocket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1,
		/datum/reagent/consumable/soysauce = 3
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket/teriyaki
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/pizza
	time = 15
	name = "Pizza Donkpocket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket/pizza
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/honk
	time = 15
	name = "Honkpocket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 2,
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket/honk
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/meaty
	time = 15
	name = "Meatpocket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/slab = 1,
		/obj/item/reagent_containers/food/snacks/meat/raw_cutlet = 2,
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket/meaty
	category = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/berry
	time = 15
	name = "Berry Donkpocket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries = 1,
		/datum/reagent/consumable/sugar = 3
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket/berry
	category = CAT_PASTRY

////////////////////////////////////////////////MUFFINS AND CUPCAKES////////////////////////////////////////////////

/datum/crafting_recipe/food/berrymuffin
	name = "Berry Muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries = 1
	)
	result = /obj/item/reagent_containers/food/snacks/muffin/berry
	category = CAT_PASTRY

/datum/crafting_recipe/food/bluecherrycupcake
	name = "Blue Cherry Cupcake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/bluecherries = 1
	)
	result = /obj/item/reagent_containers/food/snacks/bluecherrycupcake
	category = CAT_PASTRY

/datum/crafting_recipe/food/booberrymuffin
	name = "Booberry Muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries = 1,
		/obj/item/ectoplasm = 1
	)
	result = /obj/item/reagent_containers/food/snacks/muffin/booberry
	category = CAT_PASTRY

/datum/crafting_recipe/food/chawanmushi
	name = "Chawanmushi"
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/reagent_containers/food/snacks/boiledegg = 2,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/reagent_containers/food/snacks/chawanmushi
	category = CAT_PASTRY

/datum/crafting_recipe/food/cherrycupcake
	name = "Cherry Cupcake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/cherries = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cherrycupcake
	category = CAT_PASTRY

/datum/crafting_recipe/food/honeybun
	name = "Honey Bun"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/reagent_containers/food/snacks/honeybun
	category = CAT_PASTRY

/datum/crafting_recipe/food/muffin
	time = 1.5 SECONDS
	name = "Muffin"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/muffin
	category = CAT_PASTRY

////////////////////////////////////////////OTHER////////////////////////////////////////////

/datum/crafting_recipe/food/chococornet
	name = "Chocolate Cornet"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/reagent_containers/food/snacks/chococornet
	category = CAT_PASTRY

/datum/crafting_recipe/food/churro
	name = "Churro"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/cinnamon = 5
	)
	result = /obj/item/reagent_containers/food/snacks/churro
	category = CAT_PASTRY

/datum/crafting_recipe/food/cinnamonroll
	name = "Cinnamon Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/cinnamon = 5
	)
	result = /obj/item/reagent_containers/food/snacks/cinnamonroll
	category = CAT_PASTRY

/datum/crafting_recipe/food/spookycoffin
	name = "Coffin Cookie"
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/datum/reagent/consumable/coffee = 5
	)
	result = /obj/item/reagent_containers/food/snacks/sugarcookie/spookycoffin
	category = CAT_PASTRY

/datum/crafting_recipe/food/cracker
	time = 1.5 SECONDS
	name = "Cracker"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/cracker
	category = CAT_PASTRY

/datum/crafting_recipe/food/fortunecookie
	time = 1.5 SECONDS
	name = "Fortune Cookie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/paper = 1
	)
	parts =	list(
		/obj/item/paper = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fortunecookie
	category = CAT_PASTRY

/datum/crafting_recipe/food/khachapuri
	name = "Khachapuri"
	reqs = list(
		/datum/reagent/consumable/eggyolk = 5,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/store/bread/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/khachapuri
	category = CAT_PASTRY

/datum/crafting_recipe/food/meatbun
	name = "Meat Bun"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/reagent_containers/food/snacks/bun = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/reagent_containers/food/snacks/meatbun
	category = CAT_PASTRY

/datum/crafting_recipe/food/oatmealcookie
	name = "Oatmeal Cookie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/oatmealcookie
	category = CAT_PASTRY

/datum/crafting_recipe/food/plumphelmetbiscuit
	time = 1.5 SECONDS
	name = "Plump Helmet Biscuit"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	category = CAT_PASTRY

/datum/crafting_recipe/food/poppypretzel
	time = 1.5 SECONDS
	name = "Poppy Pretzel"
	reqs = list(
		/obj/item/seeds/poppy = 1,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/poppypretzel
	category = CAT_PASTRY

/datum/crafting_recipe/food/raisincookie
	name = "Raisin Cookie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/no_raisin = 1,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/raisincookie
	category = CAT_PASTRY

/datum/crafting_recipe/food/raw_croissant
	name = "Raw Croissant"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rawpastrybase = 1,
		/datum/reagent/consumable/sugar = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 2
	)
	result = /obj/item/reagent_containers/food/snacks/raw_croissant
	category = CAT_PASTRY

/datum/crafting_recipe/food/spookyskull
	name = "Skull Cookie"
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/datum/reagent/consumable/milk = 5
	)
	result = /obj/item/reagent_containers/food/snacks/sugarcookie/spookyskull
	category = CAT_PASTRY

/datum/crafting_recipe/food/sugarcookie
	time = 1.5 SECONDS
	name = "Sugar Cookie"
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/pastrybase = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sugarcookie
	category = CAT_PASTRY

/datum/crafting_recipe/food/jaffacake
	name = "Jaffa Cake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pastrybase = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1,
		/datum/reagent/consumable/orangejuice = 2
	)
	result = /obj/item/reagent_containers/food/snacks/jaffacake
	category = CAT_PASTRY
