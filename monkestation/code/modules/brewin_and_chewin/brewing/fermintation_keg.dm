GLOBAL_LIST_EMPTY(custom_fermentation_recipes)

/obj/structure/fermentation_keg
	name = "fermentation keg"
	desc = "A simple keg that is meant for making booze."

	icon = 'monkestation/code/modules/brewin_and_chewin/icons/objects.dmi'
	icon_state = "barrel_tapless"

	density = TRUE

	/// The sound of fermentation
	var/datum/looping_sound/boiling/soundloop
	/// The volume of the barrel sounds
	var/sound_volume = 25
	var/open_icon_state = "barrel_tapless_open"

	//After brewing we can sell or bottle, this is for the latter
	var/ready_to_bottle = FALSE
	var/brewing = FALSE

	///our currently needed crops
	var/list/recipe_crop_stocks
	///our currently selected recipe
	var/datum/brewing_recipe/selected_recipe
	///our current price value used by exports
	var/price_tag = 0
	///our made item which we clear once its no longer ready to bottle
	var/made_item

	///icon used for wrapping the keg. set to NULL for any intentionally unwrappable subtypes.
	var/delivery_icon = "deliverykeg"



/obj/structure/fermentation_keg/Initialize()
	. = ..()
	create_reagents(240, OPENCONTAINER | NO_REACT) //on agv it should be 120u for water then rest can be other needed chemicals
	recipe_crop_stocks = list()

	soundloop = new(src, brewing)
	soundloop.volume = sound_volume

/obj/structure/fermentation_keg/attack_hand(mob/user)
	if(!brewing && (!selected_recipe || ready_to_bottle))
		shopping_run(user)
		return

	if(try_n_brew(user))
		start_brew()
	..()

/obj/structure/fermentation_keg/attackby(obj/item/I, mob/user)
	var/list/produce_list = list()
	var/obj/item/storage/bag/plants/storage

	if(istype(I, /obj/item/bottle_kit))
		var/obj/item/bottle_kit/kit = I
		bottle(kit.glass_colour)

	if(I.type in selected_recipe?.needed_items)
		produce_list += I

	if(istype(I, /obj/item/food/grown))
		produce_list += I

	if(istype(I, /obj/item/storage/bag/plants))
		storage = I
		for(var/obj/item/food/grown/item in storage.contents)
			produce_list += item

	for(var/obj/item/food/grown/G in produce_list)
		if(G.type in selected_recipe?.needed_crops)
			var/amount = recipe_crop_stocks[G.type] || 0
			var/added_item = round(min(10, max(1, G.seed.potency / 10)))
			recipe_crop_stocks[G.type] = amount + added_item
			qdel(G)

	for(var/obj/item/item in produce_list)
		if(item.type in selected_recipe?.needed_items)
			var/amount = recipe_crop_stocks[item.type] || 0
			var/added_item = 1
			recipe_crop_stocks[item.type] = amount + added_item
			qdel(item)

	. = ..()

/obj/structure/fermentation_keg/examine(mob/user)
	. =..()
	if(ready_to_bottle)
		. += span_boldnotice("[made_item]")
		. += span_notice("Value: [price_tag]")

	else if(selected_recipe)
		var/message = "Currently making: [selected_recipe.display_name].\n"

		for(var/datum/reagent/required_chem as anything in selected_recipe.needed_reagents)
			message += "Reagent Needed: [initial(required_chem.name)] [selected_recipe.needed_reagents[required_chem]].\n"

		for(var/obj/item/food/grown/required_crop as anything in selected_recipe.needed_crops)
			message += "Crop Needed: [capitalize(initial(required_crop.name))] [selected_recipe.needed_crops[required_crop]], Current Amount: [recipe_crop_stocks[required_crop] || 0].\n"

		for(var/obj/item/needed_item as anything in selected_recipe.needed_items)
			message += "Item Needed: [capitalize(initial(needed_item.name))] [selected_recipe.needed_items[needed_item]], Current Amount: [recipe_crop_stocks[needed_item] || 0].\n"

		//time
		if(selected_recipe.brew_time)
			if(selected_recipe.brew_time >= 1 MINUTES)
				message += "Once set, will take [selected_recipe.brew_time / 600] Minutes.\n"
			else
				message += "Once set, will take [selected_recipe.brew_time / 10] Seconds.\n"

		//How many are brewed
		if(selected_recipe.brewed_amount)
			message += "Will produce [selected_recipe.brewed_amount] bottles when finished.\n"

		if(selected_recipe.brewed_item && selected_recipe.brewed_item_count)
			var/name_to_use = selected_recipe.secondary_name
			if(!name_to_use)
				name_to_use = selected_recipe.display_name
			message += "Will produce [name_to_use] x [selected_recipe.brewed_item_count] when finished.\n"

		if(selected_recipe.helpful_hints)
			message += "[selected_recipe.helpful_hints].\n"

		if(istype(selected_recipe, /datum/brewing_recipe/custom_recipe))
			var/datum/brewing_recipe/custom_recipe/recipe = selected_recipe
			message += "Recipe Created By:[recipe.made_by]"
		. += message


/obj/structure/fermentation_keg/proc/shopping_run(mob/user)
	if(brewing)
		return

	var/list/options = list()
	for(var/path in subtypesof(/datum/brewing_recipe) - /datum/brewing_recipe/custom_recipe)
		var/datum/brewing_recipe/recipe = path
		var/prereq = initial(recipe.pre_reqs)
		if((!ready_to_bottle && prereq == null) || (selected_recipe?.reagent_to_brew == prereq && ready_to_bottle))
			options[initial(recipe.display_name)] = recipe


	for(var/datum/brewing_recipe/recipe in GLOB.custom_fermentation_recipes)
		var/prereq = recipe.pre_reqs
		if((!ready_to_bottle && prereq == null) || (selected_recipe?.reagent_to_brew == prereq && ready_to_bottle))
			options[recipe.display_name] = recipe

	if(options.len == 0)
		to_chat(user, "Their is no further brewing to be done, clear this barrel out or sell it.")
		return

	var/choice = tgui_input_list(user,"What brew do you want to make?", name, options)

	if(!choice)
		return

	var/choice_to_spawn = options[choice]

	if(istype(choice_to_spawn, /datum/brewing_recipe/custom_recipe))
		selected_recipe = choice_to_spawn
	else
		selected_recipe = new choice_to_spawn

	//Second stage brewing gives no refunds! - This is intented design to help make it so folks dont quit halfway through and still get a rebate
	ready_to_bottle = FALSE
	price_tag = 150
	icon_state = open_icon_state

//Remove only chemicals
/obj/structure/fermentation_keg/proc/clear_keg_reagents()
	if(reagents)
		//consume consume consume consume
		reagents.clear_reagents()

//Remove and reset
/obj/structure/fermentation_keg/proc/clear_keg(force = FALSE)
	if(brewing)
		return FALSE

	if(!force && ready_to_bottle)
		return FALSE

	if(reagents)
		reagents.clear_reagents()

	ready_to_bottle = FALSE
	made_item = null
	icon_state = open_icon_state

	recipe_crop_stocks.Cut()

	price_tag = 150

	if(force)
		selected_recipe = null

	return TRUE

/obj/structure/fermentation_keg/proc/start_brew()
	brewing = TRUE

	for(var/obj/item/food/grown/item as anything in selected_recipe.needed_crops)
		if(!(item in recipe_crop_stocks))
			return
		var/amount = recipe_crop_stocks[item] || 0
		recipe_crop_stocks[item] = amount - selected_recipe.needed_crops[item]

	for(var/obj/item/item as anything in selected_recipe.needed_items)
		if(!(item in recipe_crop_stocks))
			return
		var/amount = recipe_crop_stocks[item] || 0
		recipe_crop_stocks[item] = amount - selected_recipe.needed_items[item]

	clear_keg_reagents()

	soundloop.start()
	addtimer(CALLBACK(src, PROC_REF(end_brew)), selected_recipe.brew_time)
	icon_state = initial(icon_state)

/obj/structure/fermentation_keg/proc/end_brew()
	icon_state = "barrel_tapless_ready"
	soundloop.stop()
	ready_to_bottle = TRUE
	brewing = FALSE
	price_tag = selected_recipe.cargo_valuation
	made_item = selected_recipe.display_name

/obj/structure/fermentation_keg/proc/try_n_brew(mob/user)
	var/ready = TRUE
	if(!selected_recipe)
		if(user)
			to_chat(user, span_notice("You need to set a booze to brew!"))
		ready = FALSE

	if(brewing)
		if(user)
			to_chat(user, span_notice("This keg is already brewing a mix!"))
		ready = FALSE

	//Crops
	for(var/obj/item/food/grown/needed_crop as anything in selected_recipe.needed_crops)
		if(recipe_crop_stocks[needed_crop] < selected_recipe.needed_crops[needed_crop])
			if(user)
				to_chat(user, span_notice("This keg lacks [initial(needed_crop.name)]!"))
				ready = FALSE

	for(var/obj/item/needed_item as anything in selected_recipe.needed_crops)
		if(recipe_crop_stocks[needed_item] < selected_recipe.needed_items[needed_item])
			if(user)
				to_chat(user, span_notice("This keg lacks [initial(needed_item.name)]!"))
				ready = FALSE

	for(var/datum/reagent/required_chem as anything in selected_recipe.needed_reagents)
		if(selected_recipe.needed_reagents[required_chem] > reagents.get_reagent_amount(required_chem))
			if(user)
				to_chat(user, span_notice("The keg's unable to brew well lacking [initial(required_chem.name)]!"))
				ready = FALSE

	return ready


/obj/structure/fermentation_keg/proc/bottle(glass_colour)
	if(ready_to_bottle)

		ready_to_bottle = FALSE
		made_item = null
		brewing = FALSE
		price_tag = 150
		icon_state = open_icon_state

		if(selected_recipe.reagent_to_brew)
			if(!glass_colour)
				glass_colour = "brew_bottle"

			var/bottlecaps
			for(bottlecaps=0, bottlecaps < selected_recipe.brewed_amount, bottlecaps++)
				var/obj/item/reagent_containers/cup/glass/bottle/small/brewing_bottle/bottle_made = new /obj/item/reagent_containers/cup/glass/bottle/small/brewing_bottle(get_turf(src))
				bottle_made.icon_state = "[glass_colour]"
				if(istype(selected_recipe, /datum/brewing_recipe/custom_recipe))
					var/datum/brewing_recipe/custom_recipe/recipe = selected_recipe
					bottle_made.name = recipe.bottle_name
					bottle_made.desc = recipe.bottle_desc
					bottle_made.glass_name = recipe.glass_name
					bottle_made.glass_desc = recipe.glass_desc
					bottle_made.reagents.add_reagent(selected_recipe.reagent_to_brew, selected_recipe.per_brew_amount, list("reagents" = recipe.reagent_data))
				else
					bottle_made.reagents.add_reagent(selected_recipe.reagent_to_brew, selected_recipe.per_brew_amount)

		if(selected_recipe.brewed_item)
			var/items_given
			for(items_given= 0, items_given < selected_recipe.brewed_item_count, items_given++)
				new selected_recipe.brewed_item(get_turf(src))
		selected_recipe = null


/obj/structure/fermentation_keg/verb/reset_keg()
	set name = "Clear Keg (Completely Resets)"
	set category = "Object"
	set src in range(1)

	if(!isdead(usr))
		clear_keg(TRUE)
	else
		to_chat(usr, span_notice("Sadly this keg isnt brewing spirits!"))
