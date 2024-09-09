/datum/chewin_cooking/recipe/proc/generate_crafting_helper()
	var/datum/crafting_recipe/food/new_food_recipe = new
	new_food_recipe.category = food_category
	new_food_recipe.result = product_type
	new_food_recipe.name = name
	new_food_recipe.non_craftable = TRUE

	var/list/steps = list()
	var/in_group = FALSE
	for(var/iter in step_builder)
		if(islist(iter))
			var/list/iteration_list = iter
			switch(iteration_list[1])
				if(CHEWIN_ADD_PRODUCE_OPTIONAL)
					var/obj/item/food/grown/grown_path = iteration_list[2]
					if(!in_group)
						steps += "Optional Step"
					steps += "Add [initial(grown_path.name)] to [cooking_container]"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_ADD_PRODUCE)
					var/obj/item/food/grown/grown_path = iteration_list[2]
					steps += "Add [initial(grown_path.name)] to [cooking_container]"
				if(CHEWIN_ADD_PRODUCE_CHOICE_OPTIONAL)
					var/string = ""
					var/first = TRUE
					for(var/obj/item/food/grown/grown_path as anything in iteration_list[2])
						if(!first)
							string += " or"
						string += initial(grown_path.name)
						first = FALSE
					if(!in_group)
						steps += "Optional Step"
					steps += "Add [string] to [cooking_container]"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_ADD_PRODUCE_CHOICE)
					var/string = ""
					var/first = TRUE
					for(var/obj/item/food/grown/grown_path as anything in iteration_list[2])
						if(!first)
							string += " or"
						string += initial(grown_path.name)
						first = FALSE
					steps += "Add [string] to [cooking_container]"

				if(CHEWIN_ADD_ITEM)
					var/obj/item/item_path = iteration_list[2]
					steps += "Add [initial(item_path.name)] to [cooking_container]"
				if(CHEWIN_ADD_ITEM_OPTIONAL)
					var/obj/item/item_path = iteration_list[2]
					if(!in_group)
						steps += "Optional Step"
					steps += "Add [initial(item_path.name)] to [cooking_container]"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_ADD_REAGENT_OPTIONAL)
					var/datum/reagent/reagent_path = iteration_list[2]
					if(!in_group)
						steps += "Optional Step"
					steps += "Add [iteration_list[3]] units of [initial(reagent_path.name)] to [cooking_container]"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_ADD_REAGENT)
					var/datum/reagent/reagent_path = iteration_list[2]
					steps += "Add [iteration_list[3]] units of [initial(reagent_path.name)] to [cooking_container]"
				if(CHEWIN_ADD_REAGENT_CHOICE_OPTIONAL)
					var/string = ""
					var/first = TRUE
					for(var/datum/reagent/reagent_path as anything in iteration_list[2])
						if(!first)
							string += " or"
						string += initial(reagent_path.name)
						first = FALSE

					if(!in_group)
						steps += "Optional Step"
					steps += "Add [iteration_list[3]] units of [string] to [cooking_container]"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_ADD_REAGENT_CHOICE)
					var/string = ""
					var/first = TRUE
					for(var/datum/reagent/reagent_path as anything in iteration_list[2])
						if(!first)
							string += " or "
						string += initial(reagent_path.name)
						first = FALSE

					steps += "Add [iteration_list[3]] units of [string] to [cooking_container]"
				if(CHEWIN_USE_TOOL)
					steps += "Use [iteration_list[2]] on [cooking_container]"
				if(CHEWIN_USE_TOOL_OPTIONAL)
					if(!in_group)
						steps += "Optional Step"
					steps += "Use [iteration_list[2]] on [cooking_container]"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_USE_ITEM)
					steps += "Use [iteration_list[2]] on [cooking_container]"
				if(CHEWIN_USE_ITEM_OPTIONAL)
					if(!in_group)
						steps += "Optional Step"
					steps += "Use [iteration_list[2]] on [cooking_container]"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_USE_STOVE)
					steps += "Cook on Stove on [iteration_list[2]] heat for [iteration_list[3] * 0.1] Seconds"
				if(CHEWIN_USE_STOVE_OPTIONAL)
					if(!in_group)
						steps += "Optional Step"
					steps += "Cook on Stove on [iteration_list[2]] heat for [iteration_list[3] * 0.1] Seconds"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_USE_FRYER)
					steps += "Deepfr for [iteration_list[3] * 0.1] Seconds"
				if(CHEWIN_USE_OVEN)
					steps += "Cook in Oven on [iteration_list[2]] heat for [iteration_list[3] * 0.1] Seconds"
				if(CHEWIN_USE_OVEN_OPTIONAL)
					if(!in_group)
						steps += "Optional Step"
					steps += "Cook in Oven on [iteration_list[2]] heat for [iteration_list[3] * 0.1] Seconds"
					if(!in_group)
						steps += "End Optional Step"
				if(CHEWIN_USE_GRILL)
					steps += "Cook on Grill on [iteration_list[2]] heat for [iteration_list[3] * 0.1] Seconds"
				if(CHEWIN_USE_GRILL_OPTIONAL)
					if(!in_group)
						steps += "Optional Step"
					steps += "Cook on Grill on [iteration_list[2]] heat for [iteration_list[3] * 0.1] Seconds"
					if(!in_group)
						steps += "End Optional Step"
		else
			switch(iter)
				if(CHEWIN_BEGIN_OPTION_CHAIN)
					in_group = TRUE
					steps += "Optional Steps"
				if(CHEWIN_END_OPTION_CHAIN)
					in_group = FALSE
					steps += "End Optional Steps"
				if(CHEWIN_BEGIN_EXCLUSIVE_OPTIONS)
					in_group = TRUE
					steps += "Exclusive Optional Steps"
				if(CHEWIN_END_EXCLUSIVE_OPTIONS)
					in_group = FALSE
					steps += "End Exclusive Optional Steps"
	new_food_recipe.steps = steps
	GLOB.cooking_recipes += new_food_recipe
