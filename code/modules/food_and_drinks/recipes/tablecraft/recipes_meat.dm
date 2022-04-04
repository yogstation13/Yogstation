// see code/module/crafting/table.dm

////////////////////////////////////////////////KEBAB//////////////////////////////////////////////////

/datum/crafting_recipe/food/doubleratkebab
	name = "Double Rat Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/deadmouse = 2
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/rat/double
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/humankebab
	name = "Human Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/meat/steak/plain/human = 2
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/human
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/kebab
	name = "Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/meat/steak = 2
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/monkey
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/tailkebab
	name = "Lizard Tail Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/organ/tail/lizard = 1
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/tail
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/ratkebab
	name = "Rat Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/deadmouse = 1
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/rat
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/tofukebab
	name = "Tofu Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/tofu = 2
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/tofu
	subcategory = CAT_MEAT

////////////////////////////////////////////////FISH////////////////////////////////////////////////

/datum/crafting_recipe/food/sashimi
	name = "Carp Sashimi"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/reagent_containers/food/snacks/spidereggs = 1,
		/obj/item/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sashimi
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/cubancarp
	name = "Cuban Carp"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/reagent_containers/food/snacks/grown/chili = 1,
		/obj/item/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cubancarp
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/fishandchips
	name = "Fish and Chips"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/fries = 1,
		/obj/item/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fishandchips
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/fishfingers
	name = "Fish Fingers"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/reagent_containers/food/snacks/bun = 1,
		/obj/item/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fishfingers
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Unagi
	name = "Sushi Unagi"
	reqs = list(
		/obj/item/fish/electric_eel = 1,
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Unagi
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Tai
	name = "Sushi Tai"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/catfishmeat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tai
	subcategory = CAT_MEAT

/datum/crafting_recipe/Tai_maki
	name = "Tai Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/catfishmeat = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/Tai_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_TobikoEgg
	name = "Tobiko and Egg Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sushi_Tobiko = 1,
		/obj/item/reagent_containers/food/snacks/egg = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_TobikoEgg
	subcategory = CAT_MEAT

/datum/crafting_recipe/TobikoEgg_maki
	name = "Tobiko and Egg Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sushi_Tobiko = 4,
		/obj/item/reagent_containers/food/snacks/egg = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/TobikoEgg_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Tobiko
	name = "Sushi Tobiko"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/fish_eggs/shark = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tobiko
	subcategory = CAT_MEAT

/datum/crafting_recipe/Tobiko_maki
	name = "Tobiko Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/fish_eggs/shark = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/Tobiko_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Masago
	name = "Sushi Masago"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Masago
	subcategory = CAT_MEAT

/datum/crafting_recipe/Masago_maki
	name = "Masago Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/Masago_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Inari
	name = "Sushi Inari"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/fried_tofu = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Inari
	subcategory = CAT_MEAT

/datum/crafting_recipe/Inari_maki
	name = "Inari Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/fried_tofu = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/Inari_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Tamago
	name = "Sushi Tamago"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/egg = 1,
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tamago
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonsteak = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon
	subcategory = CAT_MEAT

/datum/crafting_recipe/SmokedSalmon_maki
	name = "Smoked Salmon Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonsteak = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/SmokedSalmon_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/SmokedSalmon_maki
	name = "Smoked Salmon Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonsteak = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/SmokedSalmon_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Sake
	name = "Sake Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonmeat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Sake
	subcategory = CAT_MEAT

/datum/crafting_recipe/Sake_maki
	name = "Sake Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonmeat = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/Sake_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Ikura
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Ikura
	subcategory = CAT_MEAT

/datum/crafting_recipe/Ikura_maki
	name = "Ikura Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/Ikura_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/sushi_Ebi
	name = "Sushi Ebi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp = 1
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Ebi
	subcategory = CAT_MEAT

/datum/crafting_recipe/Ebi_maki
	name = "Ebi Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp = 4
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/Ebi_maki
	subcategory = CAT_MEAT

/datum/crafting_recipe/fish_skewer
	name = "Fish Skewer"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat = 2,
		/obj/item/stack/rods = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fish_skewer
	subcategory = CAT_MEAT

/datum/crafting_recipe/shrimp_skewer
	name = "Shrimp Skewer"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/shrimp = 4,
		/obj/item/stack/rods = 1
	)
	result = /obj/item/reagent_containers/food/snacks/shrimp_skewer
	subcategory = CAT_MEAT

/datum/crafting_recipe/fishburger
	name = "Fishburger"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/bun = 1,
		/obj/item/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fishburger
	subcategory = CAT_MEAT
////////////////////////////////////////////////OTHER////////////////////////////////////////////////

/datum/crafting_recipe/food/nugget
	name = "Chicken Nugget"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/nugget
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/cornedbeef
	name = "Corned Beef and Cabbage"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/obj/item/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 2
	)
	result = /obj/item/reagent_containers/food/snacks/cornedbeef
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/enchiladas
	name = "Enchiladas"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/grown/chili = 2,
		/obj/item/reagent_containers/food/snacks/tortilla = 2
	)
	result = /obj/item/reagent_containers/food/snacks/enchiladas
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/bearsteak
	name = "Filet Migrawr"
	reqs = list(
		/datum/reagent/consumable/ethanol/manly_dorf = 5,
		/obj/item/reagent_containers/food/snacks/meat/steak/bear = 1
	)
	tools = list(/obj/item/lighter)
	result = /obj/item/reagent_containers/food/snacks/bearsteak
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/pigblanket
	name = "Pig in a Blanket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/bun = 1,
		/obj/item/reagent_containers/food/snacks/butter = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pigblanket
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/rawkhinkali
	name = "Raw Khinkali"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/doughslice = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1
	)
	result =  /obj/item/reagent_containers/food/snacks/rawkhinkali
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/ricepork
	name = "Rice and Pork"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2
	)
	result = /obj/item/reagent_containers/food/snacks/salad/ricepork
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/sausage
	name = "Raw Sausage"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/raw_meatball = 1,
		/obj/item/reagent_containers/food/snacks/meat/raw_cutlet = 2
	)
	result = /obj/item/reagent_containers/food/snacks/raw_sausage
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/stewedsoymeat
	name = "Stewed Soymeat"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/soydope = 2,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/stewedsoymeat
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/meatclown
	name = "Meat Clown"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/steak/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/reagent_containers/food/snacks/meatclown
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/gumbo
	name = "Black eyed gumbo"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/grown/peas = 1,
		/obj/item/reagent_containers/food/snacks/grown/chili = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/gumbo
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/fishfry
	name = "Fish fry"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/corn = 1,
		/obj/item/reagent_containers/food/snacks/grown/peas =1,
		/obj/item/reagent_containers/food/snacks/carpmeat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fishfry
	subcategory = CAT_MEAT
