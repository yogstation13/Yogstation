

/////////////////// Dough Ingredients ////////////////////////
//Note for this file: All the raw pastries should not have microwave (cooked_type) results, use baking instead. All cooked products can use baking, but should also support a microwave.

/obj/item/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "dough"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/dough/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/store/bread/plain, rand(30 SECONDS, 45 SECONDS), TRUE, TRUE)


// Dough + rolling pin = flat dough
/obj/item/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/flatdough(loc)
			to_chat(user, span_notice("You flatten [src]."))
			qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a surface to roll it out!"))
	else
		..()


// sliceable into 3xdoughslices
/obj/item/reagent_containers/food/snacks/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/reagent_containers/food/snacks/doughslice
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/pizza/raw
	slices_num = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN
	burns_in_oven = TRUE

/obj/item/reagent_containers/food/snacks/flatdough/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizzabread, rand(30 SECONDS, 45 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzabread
	name = "pizza bread"
	desc = "Add ingredients to make a pizza."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "pizzabread"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("bread" = 1)
	foodtype = GRAIN


/obj/item/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A slice of dough. Can be cooked into a bun."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "doughslice"
	filling_color = "#CD853F"
	tastes = list("dough" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/doughslice/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/bun, rand(20 SECONDS, 25 SECONDS), TRUE, TRUE)


/obj/item/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "bun"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/burger
	filling_color = "#CD853F"
	tastes = list("bun" = 1) // the bun tastes of bun.
	foodtype = GRAIN
	burns_in_oven = TRUE

/obj/item/reagent_containers/food/snacks/cakebatter
	name = "cake batter"
	desc = "Bake it to get a cake."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "cakebatter"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("batter" = 1)
	foodtype = GRAIN | DAIRY

// Cake batter + rolling pin = pie dough
/obj/item/reagent_containers/food/snacks/cakebatter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/piedough(loc)
			to_chat(user, span_notice("You flatten [src]."))
			qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a surface to roll it out!"))
	else
		..()

/obj/item/reagent_containers/food/snacks/cakebatter/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/store/cake/plain, rand(70 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/piedough
	name = "pie dough"
	desc = "Bake it to get a pie."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "piedough"
	slice_path = /obj/item/reagent_containers/food/snacks/rawpastrybase
	slices_num = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 9)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/piedough/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pie/plain, rand(30 SECONDS, 45 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/rawpastrybase
	name = "raw pastry base"
	desc = "Must be cooked before use."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawpastrybase"
	filling_color = "#CD853F"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("raw pastry" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/rawpastrybase/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pastrybase, rand(20 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pastrybase
	name = "pastry base"
	desc = "A base for any self-respecting pastry."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "pastrybase"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	filling_color = "#CD853F"
	tastes = list("pastry" = 1)
	foodtype = GRAIN | DAIRY
	burns_in_oven = TRUE
