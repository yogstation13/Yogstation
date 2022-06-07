
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIES////////////////////////////////////////////////

/datum/crafting_recipe/food/amanitapie
	name = "Amanita Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/amanita_pie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/applepie
	name = "Apple Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/applepie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/bananacreampie
	name = "Banana Cream Pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		 /obj/item/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/cream
	subcategory = CAT_PIE

/datum/crafting_recipe/food/bearypie
	name = "Beary Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries = 1,
		/obj/item/reagent_containers/food/snacks/meat/steak/bear = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/bearypie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/berryclafoutis
	name = "Berry Clafoutis"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/berryclafoutis
	subcategory = CAT_PIE

/datum/crafting_recipe/food/blumpkinpie
	name = "Blumpkin Pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/blumpkin = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/blumpkinpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/buttcinnpie
	name = "Butterscotch Cinnamon Pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/datum/reagent/consumable/cinnamon = 5
	)
	result = /obj/item/reagent_containers/food/snacks/pie/buttcinnpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/cherrypie
	name = "Cherry Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		 /obj/item/reagent_containers/food/snacks/grown/cherries = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/cherrypie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/dulcedebatata
	name = "Dulce de Batata"
	reqs = list(
		/datum/reagent/consumable/vanilla = 5,
		/datum/reagent/water = 5,
		/obj/item/reagent_containers/food/snacks/grown/potato/sweet = 2
	)
	result = /obj/item/reagent_containers/food/snacks/pie/dulcedebatata
	subcategory = CAT_PIE

/datum/crafting_recipe/food/frostypie
	name = "Frosty Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/bluecherries = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/frostypie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/goldenappletart
	name = "Golden Apple Streusel Tart"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple/gold = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/appletart
	subcategory = CAT_PIE

/datum/crafting_recipe/food/grapetart
	name = "Grape Tart"
	reqs = list(
            /datum/reagent/consumable/milk = 5,
            /datum/reagent/consumable/sugar = 5,
            /obj/item/reagent_containers/food/snacks/pie/plain = 1,
	        /obj/item/reagent_containers/food/snacks/grown/grapes = 3
	        )
	result = /obj/item/reagent_containers/food/snacks/pie/grapetart
	subcategory = CAT_PIE

/datum/crafting_recipe/food/meatpie
	name = "Meat Pie"
	reqs = list(
		/datum/reagent/consumable/blackpepper = 1,
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/meat/steak/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/meatpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/plumppie
	name = "Plump Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/plump_pie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/pumpkinpie
	name = "Pumpkin Pie"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/pumpkinpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/tofupie
	name = "Tofu Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/tofu = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/tofupie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/xenopie
	name = "Xeno Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/xeno = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pie/xemeatpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/frenchsilkpie
	name = "French Silk Pie"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pie/plain = 1,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 2
	)
	result = /obj/item/reagent_containers/food/snacks/pie/frenchsilkpie
	subcategory = CAT_PIE
