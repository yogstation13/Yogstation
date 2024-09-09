/proc/initialize_cooking_recipes()
	//All combination path datums, save for the default recipes we don't want.
	var/list/recipe_paths = typesof(/datum/chewin_cooking/recipe)
	recipe_paths -= /datum/chewin_cooking/recipe
	for (var/path in recipe_paths)
		var/datum/chewin_cooking/recipe/example_recipe = new path()
		if(!GLOB.chewin_recipe_dictionary[example_recipe.cooking_container])
			GLOB.chewin_recipe_dictionary[example_recipe.cooking_container] = list()
		GLOB.chewin_recipe_dictionary[example_recipe.cooking_container]["[example_recipe.unique_id]"] = example_recipe

		GLOB.chewin_recipe_list += example_recipe
