
// see code/module/crafting/table.dm

////////////////////////////////////////////////SOUP////////////////////////////////////////////////

/datum/crafting_recipe/food/amanitajelly
	name = "Amanita Jelly"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita = 3
	)
	result = /obj/item/reagent_containers/food/snacks/soup/amanitajelly
	category = CAT_SOUP

/datum/crafting_recipe/food/bloodsoup
	name = "Blood Soup"
	reqs = list(
		/datum/reagent/blood = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato/blood = 2
	)
	result = /obj/item/reagent_containers/food/snacks/soup/blood
	category = CAT_SOUP

/datum/crafting_recipe/food/clownstears
	name = "Clown's Tears"
	reqs = list(
		/datum/reagent/lube = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/stack/ore/bananium = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/clownstears
	category = CAT_SOUP

/datum/crafting_recipe/food/coldchili
	name = "Cold Chili"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/grown/icepepper = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/coldchili
	category = CAT_SOUP

/datum/crafting_recipe/food/dolphinsoup
	name = "Dolphin Soup"
	reqs = list(
		/datum/reagent/blood = 10,
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/dolphinmeat = 2
	)
	result = /obj/item/reagent_containers/food/snacks/soup/dolphinsoup
	category = CAT_SOUP

/datum/crafting_recipe/food/eyeballsoup
	name = "Eyeball Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 2,
		/obj/item/organ/eyes = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/tomato/eyeball
	category = CAT_SOUP

/datum/crafting_recipe/food/hotchili
	name = "Hot chili"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/grown/chili = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/hotchili
	category = CAT_SOUP

/datum/crafting_recipe/food/meatballsoup
	name = "Meatball Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/potato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/meatball
	category = CAT_SOUP

/datum/crafting_recipe/food/milosoup
	name = "Milo Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/soydope = 2,
		/obj/item/reagent_containers/food/snacks/tofu = 2
	)
	result = /obj/item/reagent_containers/food/snacks/soup/milo
	category = CAT_SOUP

/datum/crafting_recipe/food/mushroomsoup
	name = "Mushroom Soup"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/water = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/mushroom
	category = CAT_SOUP

/datum/crafting_recipe/food/mysterysoup
	name = "Mystery Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/badrecipe = 1,
		/obj/item/reagent_containers/food/snacks/tofu = 1,
		/obj/item/reagent_containers/food/snacks/boiledegg = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/mystery
	category = CAT_SOUP

/datum/crafting_recipe/food/nettlesoup
	name = "Nettle Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/nettle = 1,
		/obj/item/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/reagent_containers/food/snacks/boiledegg = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/nettle
	category = CAT_SOUP

/datum/crafting_recipe/food/redbeetsoup
	name = "Red Beet Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/redbeet = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/beet/red
	category = CAT_SOUP

/datum/crafting_recipe/food/slimesoup
	name = "Slime Soup"
	reqs = list(
			/datum/reagent/water = 10,
			/datum/reagent/toxin/slimejelly = 5,
			/obj/item/reagent_containers/glass/bowl = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/slime
	category = CAT_SOUP

/datum/crafting_recipe/food/spacylibertyduff
	name = "Spacy Liberty Duff"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap = 3
	)
	result = /obj/item/reagent_containers/food/snacks/soup/spacylibertyduff
	category = CAT_SOUP

/datum/crafting_recipe/food/stew
	name = "Stew"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 3,
		/obj/item/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/stew
	category = CAT_SOUP

/datum/crafting_recipe/food/sweetpotatosoup
	name = "Sweet Potato Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/potato/sweet = 2
	)
	result = /obj/item/reagent_containers/food/snacks/soup/sweetpotato
	category = CAT_SOUP

/datum/crafting_recipe/food/tomatosoup
	name = "Tomato Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 2
	)
	result = /obj/item/reagent_containers/food/snacks/soup/tomato
	category = CAT_SOUP

/datum/crafting_recipe/food/vegetablesoup
	name = "Vegetable Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/corn = 1,
		/obj/item/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/reagent_containers/food/snacks/grown/potato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/vegetable
	category = CAT_SOUP

/datum/crafting_recipe/food/beetsoup
	name = "White Beet Soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/whitebeet = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/beet
	category = CAT_SOUP

/datum/crafting_recipe/food/wingfangchu
	name = "Wingfangchu"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/xeno = 2
	)
	result = /obj/item/reagent_containers/food/snacks/soup/wingfangchu
	category = CAT_SOUP

/datum/crafting_recipe/food/wishsoup
	name = "Wish Soup"
	reqs = list(
		/datum/reagent/water = 20,
		/obj/item/reagent_containers/glass/bowl = 1
	)
	result= /obj/item/reagent_containers/food/snacks/soup/wish
	category = CAT_SOUP

/datum/crafting_recipe/food/peasoup
	name = "Pea soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/peas = 2,
		/obj/item/reagent_containers/food/snacks/grown/parsnip = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/peasoup
	category = CAT_SOUP

/datum/crafting_recipe/food/saimin
	name = "Saimin"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/egg = 1,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/reagent_containers/food/snacks/grown/onion = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/reagent_containers/food/snacks/soup/saimin
	category = CAT_SOUP
