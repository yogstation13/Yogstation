/datum/component/edible/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(parent))
		return FALSE
	return TRUE

/datum/component/edible/proc/show_radial_recipes(atom/parent_atom, mob/user)
	SIGNAL_HANDLER
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/chef = user
	var/datum/component/personal_crafting/crafting_menu = user.GetComponent(/datum/component/personal_crafting) // we turned crafting into a component so now I have to do this shit to avoid copypaste
	if(!crafting_menu)
		CRASH("This really needs to be looked into this is not suppose to happen like ever. A human tried to show radial recipes without a crafting component")
	var/list/available_recipes = list()
	var/list/surroundings = crafting_menu.get_surroundings(chef)
	var/list/recipes_radial = list()
	var/list/recipes_craft = list()
	for(var/recipe in GLOB.cooking_recipes)
		var/datum/crafting_recipe/potential_recipe = recipe
		if(parent.type in potential_recipe.reqs) // dont show recipes that don't involve this item
			if(crafting_menu.check_contents(chef, potential_recipe, surroundings)) // don't show recipes we can't actually make
				available_recipes.Add(potential_recipe)
	for(var/available_recipe in available_recipes)
		var/datum/crafting_recipe/available_recipe_datum = available_recipe
		var/atom/craftable_atom = available_recipe_datum.result
		recipes_radial.Add(list(initial(craftable_atom.name) = image(icon = initial(craftable_atom.icon), icon_state = initial(craftable_atom.icon_state))))
		recipes_craft.Add(list(initial(craftable_atom.name) = available_recipe_datum))
	INVOKE_ASYNC(src, PROC_REF(hate_signals_holy_shit), recipes_radial, recipes_craft, chef, crafting_menu)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/edible/proc/hate_signals_holy_shit(list/recipes_radial, list/recipes_craft, mob/chef, datum/component/personal_crafting/crafting_menu)
	var/recipe_chosen = show_radial_menu(chef, chef, recipes_radial, custom_check = CALLBACK(src, PROC_REF(check_menu), chef), require_near = TRUE, tooltips = TRUE)
	if(!recipe_chosen)
		return
	var/datum/crafting_recipe/chosen_recipe = recipes_craft[recipe_chosen]
	chef.balloon_alert_to_viewers("crafting [chosen_recipe.name]")
	crafting_menu.craft_until_cant(chosen_recipe, chef, get_turf(parent))
