/obj/item/recipe_card
	name = "fermentation recipe card"
	desc = "Used to write down your secret recipe card."
	icon = 'monkestation/code/modules/brewin_and_chewin/icons/paper.dmi'
	icon_state = "recipe_paper"

	var/list/stored_reagents = list()
	var/list/stored_foods = list()
	var/brewing_time = 2 MINUTES

/obj/item/recipe_card/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/item/food/grown))
		if(target.type in stored_foods)
			return
		var/amount = tgui_input_number(user, "How much of [target.name] is needed?", name, 10, 50, 1)
		if(!amount)
			return
		stored_foods += list(target.type = amount)
		return

	if(istype(target, /obj/structure/fermentation_keg))
		stored_reagents = list()
		for(var/datum/reagent/reagent as anything in target.reagents.reagent_list)
			stored_reagents += list(reagent.type = reagent.volume)


/obj/item/recipe_card/CtrlClick(mob/user)
	. = ..()
	submit_recipe(user)

/obj/item/recipe_card/proc/submit_recipe(mob/user)
	if(!length(stored_foods) || !length(stored_reagents))
		return
	var/display_name = tgui_input_text(user, "What is this drink called?", name)
	if(!display_name)
		return
	var/bottle_name = tgui_input_text(user, "What is this drink's bottle called?", name)
	if(!bottle_name)
		return
	var/glass_name = tgui_input_text(user, "What is this drink's glass called?", name)
	if(!glass_name)
		return

	var/bottle_desc = tgui_input_text(user, "What is this drink's bottle description?", name, multiline = TRUE)
	if(!bottle_desc)
		return
	var/glass_desc = tgui_input_text(user, "What is this drink's glass description?", name, multiline = TRUE)
	if(!glass_desc)
		return

	var/datum/brewing_recipe/custom_recipe/new_recipe = new

	new_recipe.made_by = user.name
	new_recipe.glass_desc = glass_desc
	new_recipe.glass_name = glass_name
	new_recipe.bottle_name = bottle_name
	new_recipe.bottle_desc = bottle_desc
	new_recipe.brew_time = brewing_time
	new_recipe.needed_crops = stored_foods
	new_recipe.needed_reagents = stored_reagents
	new_recipe.brewed_amount = 4
	new_recipe.display_name = display_name
	new_recipe.cargo_valuation = 2000

	var/list/reagent_data = list()

	var/total_reagent_count = 0
	for(var/datum/reagent/reagent as anything in stored_reagents)
		total_reagent_count += stored_reagents[reagent]

	for(var/datum/reagent/reagent as anything in stored_reagents)
		var/list/new_list = list()
		new_list += reagent
		new_list[reagent] = stored_reagents[reagent] / total_reagent_count
		reagent_data += new_list

	new_recipe.reagent_data = reagent_data
	GLOB.custom_fermentation_recipes += new_recipe
	qdel(src)
