
// see code/module/crafting/table.dm

////////////////////////////////////////////////BREAD////////////////////////////////////////////////

/datum/crafting_recipe/food/baguette
	name = "Baguette"
	time = 4 SECONDS
	reqs = list(/datum/reagent/consumable/sodiumchloride = 1,
				/datum/reagent/consumable/blackpepper = 1,
				/obj/item/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/reagent_containers/food/snacks/baguette
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/banananutbread
	name = "Banana-Nut Bread"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/reagent_containers/food/snacks/boiledegg = 3,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/bread/banana
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/butterbiscuit
	name = "Butter Biscuit"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/bun = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/butterbiscuit
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/butteredtoast
	name = "Buttered Toast"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice/toast = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/butteredtoast
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/creamcheesebread
	name = "Cream Cheese Bread"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/reagent_containers/food/snacks/store/bread/creamcheese
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/frenchtoast
	name = "raw French toast"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 1,
		/datum/reagent/consumable/cinnamon = 5,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/eggyolk = 5
	)
	result = /obj/item/reagent_containers/food/snacks/frenchtoast/raw
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/garlicbread
	name = "Garlic Bread"
	time = 4 SECONDS
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/garlic = 1,
				/obj/item/reagent_containers/food/snacks/breadslice/toast = 1,
				/obj/item/reagent_containers/food/snacks/butterslice = 1
	)
	result = /obj/item/reagent_containers/food/snacks/garlicbread
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/jelliedyoast
	name = "Jellied Toast"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/toast = 1
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/cherry
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/meatbread
	name = "Meat Bread"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/plain = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/reagent_containers/food/snacks/store/bread/meat
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/mimanabread
	name = "Mimana Bread"
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/reagent_containers/food/snacks/tofu = 3,
		/obj/item/reagent_containers/food/snacks/grown/banana/mime = 1
	)
	result = /obj/item/reagent_containers/food/snacks/store/bread/mimana
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/slimetoast
	name = "Slime Toast"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/toast = 1
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/slime
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/spidermeatbread
	name = "Spidermeat Bread"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/spider = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/reagent_containers/food/snacks/store/bread/spidermeat
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/tofubread
	name = "Tofu Bread"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/reagent_containers/food/snacks/tofu = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/reagent_containers/food/snacks/store/bread/tofu
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/twobread
	name = "Two Bread"
	reqs = list(
		/datum/reagent/consumable/ethanol/wine = 5,
		/obj/item/reagent_containers/food/snacks/breadslice/plain = 2
	)
	result = /obj/item/reagent_containers/food/snacks/twobread
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/xenomeatbread
	name = "Xenomeat Bread"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/xeno = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/reagent_containers/food/snacks/store/bread/xenomeat
	subcategory = CAT_BREAD


