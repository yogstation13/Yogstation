/datum/component/personal_crafting/Initialize()
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(create_mob_button))

/datum/component/personal_crafting/proc/create_mob_button(mob/user, client/CL)
	var/datum/hud/H = user.hud_used
	var/atom/movable/screen/craft/C = new()
	C.icon = H.ui_style
	H.static_inventory += C
	CL.screen += C
	RegisterSignal(C, COMSIG_CLICK, PROC_REF(component_ui_interact))

#define COOKING TRUE
#define CRAFTING FALSE

/datum/component/personal_crafting
	var/busy
	var/mode = CRAFTING
	var/display_craftable_only = FALSE
	var/display_compact = FALSE
	var/forced_mode = FALSE

/*	This is what procs do:
	get_environment - gets a list of things accessable for crafting by user
	get_surroundings - takes a list of things and makes a list of key-types to values-amounts of said type in the list
	check_contents - takes a recipe and a key-type list and checks if said recipe can be done with available stuff
	check_tools - takes recipe, a key-type list, and a user and checks if there are enough tools to do the stuff, checks bugs one level deep
	construct_item - takes a recipe and a user, call all the checking procs, calls do_after, checks all the things again, calls del_reqs, creates result, calls CheckParts of said result with argument being list returned by deel_reqs
	del_reqs - takes recipe and a user, loops over the recipes reqs var and tries to find everything in the list make by get_environment and delete it/add to parts list, then returns the said list
*/

/datum/component/personal_crafting/proc/check_contents(atom/a, datum/crafting_recipe/R, list/contents)
	var/list/item_instances = contents["instances"]
	contents = contents["other"]

	var/list/requirements_list = list()

	// Process all requirements
	for(var/requirement_path in R.reqs)
		// Check we have the appropriate ammount avalible in the contents list
		var/needed_amount = R.reqs[requirement_path]
		for(var/content_item_path in contents)
			// Right path and not blacklisted
			if(!ispath(content_item_path, requirement_path) || R.blacklist.Find(content_item_path))
				continue

			needed_amount -= contents[content_item_path]
			if(needed_amount <= 0)
				break
		
		if(needed_amount > 0)
			return FALSE

		// Store the instances of what we will use for R.check_requirements() for requirement_path.
		var/list/instances_list = list()
		for(var/instance_path in item_instances)
			if(ispath(instance_path in item_instances))
				instances_list += item_instances[instance_path]

		requirements_list[requirement_path] = instances_list

	return R.check_requirements(a, requirements_list)

/datum/component/personal_crafting/proc/get_environment(atom/a, list/blacklist = null, radius_range = 1)
	. = list()
	if(!isturf(a.loc))
		return
	for(var/atom/movable/AM in range(radius_range, a))
		if((AM.flags_1 & HOLOGRAM_1) || (blacklist && (AM.type in blacklist)))
			continue
		. += AM

/datum/component/personal_crafting/proc/get_surroundings(atom/a, list/blacklist=null)
	. = list()
	.["tool_behaviour"] = list()
	.["other"] = list()
	.["instances"] = list()
	for(var/obj/item/item in get_environment(a, blacklist))
		LAZYADDASSOCLIST(.["instances"], item.type, item)
		if(isstack(item))
			var/obj/item/stack/stack = item
			.["other"][item.type] += stack.amount
			continue
		if(is_reagent_container(item))
			var/obj/item/reagent_containers/container = item
			if(!istype(container, /obj/item/reagent_containers/food))
				if(container.is_drainable() && length(container.reagents.reagent_list)) 
					for(var/datum/reagent/reagent in container.reagents.reagent_list)
						.["other"][reagent.type] += reagent.volume
					continue
			// Food items are reagent containers and some of them still should be included (condiments & drinks).
			var/food_beakers = istype(container, /obj/item/reagent_containers/food/condiment/) || istype(container, /obj/item/reagent_containers/food/drinks/)
			if(food_beakers)
				if(container.is_drainable() && length(container.reagents.reagent_list)) 
					for(var/datum/reagent/reagent in container.reagents.reagent_list)
						.["other"][reagent.type] += reagent.volume
					continue
		if(item.tool_behaviour)
			.["tool_behaviour"] += item.tool_behaviour
		.["other"][item.type] += 1

/datum/component/personal_crafting/proc/check_tools(atom/source, datum/crafting_recipe/recipe, list/surroundings)
	if(!length(recipe.tool_behaviors) && !length(recipe.tool_paths))
		return TRUE
	var/list/available_tools = list()
	var/list/present_qualities = list()

	for(var/obj/item/contained_item in source.contents)
		// We don't use/have `atom_storage`. Thus:
		if(istype(contained_item, /obj/item/organ/cyberimp/arm/toolset))
			var/obj/item/organ/cyberimp/arm/toolset/toolset = contained_item
			if(toolset.owner == source)
				for(var/obj/item/implant_item in contained_item.contents)
					available_tools += implant_item.type
					if(implant_item.tool_behaviour)
						present_qualities[implant_item.tool_behaviour] = TRUE
		if(istype(contained_item, /obj/item/storage))
			for(var/obj/item/subcontained_item in contained_item.contents)
				available_tools += subcontained_item.type
				if(subcontained_item.tool_behaviour)
					present_qualities[subcontained_item.tool_behaviour] = TRUE

		available_tools[contained_item.type] = TRUE
		if(contained_item.tool_behaviour)
			available_tools[contained_item.tool_behaviour] = TRUE

	for(var/quality in surroundings["tool_behaviour"])
		present_qualities[quality] = TRUE

	for(var/path in surroundings["other"])
		available_tools[path] = TRUE

	for(var/required_quality in recipe.tool_behaviors)
		if(present_qualities[required_quality])
			continue
		return FALSE

	for(var/required_path in recipe.tool_paths)
		var/found_this_tool = FALSE
		for(var/tool_path in available_tools)
			if(!ispath(required_path, tool_path))
				continue
			found_this_tool = TRUE
			break
		if(found_this_tool)
			continue
		return FALSE

	return TRUE

/datum/component/personal_crafting/proc/construct_item(atom/a, datum/crafting_recipe/R)
	var/list/contents = get_surroundings(a, R.blacklist)
	var/send_feedback = 1
	if(!check_contents(a, R, contents))
		return ", missing component."
	if(!check_tools(a, R, contents))
		return ", missing tool."
	if(ismob(a))
		var/mob/mob = a
		if(mob && HAS_TRAIT(mob, TRAIT_CRAFTY))
			R.time *= 0.75
	if(!do_after(a, R.time, a))
		return "."
	contents = get_surroundings(a, R.blacklist) // Double checking since items could no longer be there after the do_after().
	if(!check_contents(a, R, contents))
		return ", missing component."
	if(!check_tools(a, R, contents))
		return ", missing tool."
	var/list/parts = del_reqs(R, a)
	var/atom/movable/I = new R.result(get_turf(a.loc))
	I.CheckParts(parts, R)
	if(send_feedback)
		SSblackbox.record_feedback("tally", "object_crafted", 1, I.type)
	return I

/*Del reqs works like this:

	Loop over reqs var of the recipe
	Set var amt to the value current cycle req is pointing to, its amount of type we need to delete
	Get var/surroundings list of things accessable to crafting by get_environment()
	Check the type of the current cycle req
		If its reagent then do a while loop, inside it try to locate() reagent containers, inside such containers try to locate needed reagent, if there isnt remove thing from surroundings
			If there is enough reagent in the search result then delete the needed amount, create the same type of reagent with the same data var and put it into deletion list
			If there isnt enough take all of that reagent from the container, put into deletion list, substract the amt var by the volume of reagent, remove the container from surroundings list and keep searching
			While doing above stuff check deletion list if it already has such reagnet, if yes merge instead of adding second one
		If its stack check if it has enough amount
			If yes create new stack with the needed amount and put in into deletion list, substract taken amount from the stack
			If no put all of the stack in the deletion list, substract its amount from amt and keep searching
			While doing above stuff check deletion list if it already has such stack type, if yes try to merge them instead of adding new one
		If its anything else just locate() in in the list in a while loop, each find --s the amt var and puts the found stuff in deletion loop

	Then do a loop over parts var of the recipe
		Do similar stuff to what we have done above, but now in deletion list, until the parts conditions are satisfied keep taking from the deletion list and putting it into parts list for return

	After its done loop over deletion list and delete all the shit that wasnt taken by parts loop

	del_reqs return the list of parts resulting object will receive as argument of CheckParts proc, on the atom level it will add them all to the contents, on all other levels it calls ..() and does whatever is needed afterwards but from contents list already
*/

/datum/component/personal_crafting/proc/del_reqs(datum/crafting_recipe/R, mob/user)
	var/list/surroundings
	var/list/Deletion = list()
	. = list()
	var/data
	var/amt
	var/list/requirements = list()
	if(R.reqs)
		requirements += R.reqs
	main_loop:
		for(var/path_key in requirements)
			amt = R.reqs[path_key]
			surroundings = get_environment(user)
			surroundings -= Deletion
			if(ispath(path_key, /datum/reagent))
				var/datum/reagent/RG = new path_key
				var/datum/reagent/RGNT
				while(amt > 0)
					var/obj/item/reagent_containers/RC = locate() in surroundings
					RG = RC.reagents?.get_reagent(path_key)
					if(RG)
						if(!locate(RG.type) in Deletion)
							Deletion += new RG.type()
						if(RG.volume > amt)
							RG.volume -= amt
							data = RG.data
							RC.reagents.conditional_update(RC)
							RG = locate(RG.type) in Deletion
							RG.volume = amt
							RG.data += data
							continue main_loop
						else
							surroundings -= RC
							amt -= RG.volume
							RC.reagents.reagent_list -= RG
							RC.reagents.conditional_update(RC)
							RGNT = locate(RG.type) in Deletion
							RGNT.volume += RG.volume
							RGNT.data += RG.data
							qdel(RG)
						RC.on_reagent_change()
					else
						surroundings -= RC
			else if(ispath(path_key, /obj/item/stack))
				var/obj/item/stack/S
				var/obj/item/stack/SD
				while(amt > 0)
					S = locate(path_key) in surroundings
					if(S.amount >= amt)
						if(!locate(S.type) in Deletion)
							SD = new S.type()
							Deletion += SD
						S.use(amt)
						SD = locate(S.type) in Deletion
						SD.amount += amt
						continue main_loop
					else
						amt -= S.amount
						if(!locate(S.type) in Deletion)
							Deletion += S
						else
							data = S.amount
							S = locate(S.type) in Deletion
							S.add(data)
						surroundings -= S
			else
				var/atom/movable/I
				while(amt > 0)
					I = locate(path_key) in surroundings
					Deletion += I
					surroundings -= I
					amt--
	var/list/partlist = list(R.parts.len)
	for(var/M in R.parts)
		partlist[M] = R.parts[M]
	for(var/part in R.parts)
		if(istype(part, /datum/reagent))
			var/datum/reagent/RG = locate(part) in Deletion
			if(RG.volume > partlist[part])
				RG.volume = partlist[part]
			. += RG
			Deletion -= RG
			continue
		if(isstack(part))
			var/obj/item/stack/ST = locate(part) in Deletion
			if(ST.amount > partlist[part])
				ST.amount = partlist[part]
			. += ST
			Deletion -= ST
			continue
		while(partlist[part] > 0)
			var/atom/movable/AM = locate(part) in Deletion
			. += AM
			Deletion -= AM
			partlist[part] -= 1
	while(Deletion.len)
		var/DL = Deletion[Deletion.len]
		Deletion.Cut(Deletion.len)
		if(istype(DL, /obj/item/storage))
			var/obj/item/storage/container = DL
			container.emptyStorage()
		qdel(DL)

/datum/component/personal_crafting/proc/is_recipe_available(datum/crafting_recipe/recipe, mob/user)
	if(!recipe.always_available && !(recipe.type in user?.mind?.learned_recipes)) // User doesn't actually know how to make this.
		return FALSE
	return TRUE

/datum/component/personal_crafting/proc/component_ui_interact(atom/movable/screen/craft/image, location, control, params, user)
	if(user == parent)
		ui_interact(user)

/datum/component/personal_crafting/ui_state(mob/user)
	return GLOB.not_incapacitated_turf_state

/datum/component/personal_crafting/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersonalCrafting", "Crafting")
		ui.open()


/datum/component/personal_crafting/ui_data(mob/user)
	var/list/data = list()
	data["busy"] = busy
	data["mode"] = mode
	data["display_craftable_only"] = display_craftable_only
	data["display_compact"] = display_compact

	var/list/surroundings = get_surroundings(user)
	var/list/craftability = list()
	for(var/datum/crafting_recipe/recipe as anything in (mode ? GLOB.cooking_recipes : GLOB.crafting_recipes))
		if(!is_recipe_available(recipe, user))
			continue
		if(check_contents(user, recipe, surroundings) && check_tools(user, recipe, surroundings))
			craftability["[REF(recipe)]"] = TRUE
		if(display_craftable_only) // for debugging only
			craftability["[REF(recipe)]"] = TRUE

	data["craftability"] = craftability
	return data

/datum/component/personal_crafting/ui_static_data(mob/user)
	var/list/data = list()
	var/list/material_occurences = list()

	data["forced_mode"] = forced_mode
	data["recipes"] = list()
	data["categories"] = list()
	data["foodtypes"] = FOOD_FLAGS

	if(user.has_dna())
		var/mob/living/carbon/carbon = user
		data["diet"] = carbon.dna.species.get_species_diet()

	for(var/datum/crafting_recipe/recipe as anything in (mode ? GLOB.cooking_recipes : GLOB.crafting_recipes))
		if(!is_recipe_available(recipe, user))
			continue

		if(recipe.category)
			data["categories"] |= recipe.category

		// Materials
		for(var/req in recipe.reqs)
			material_occurences[req] += 1

		data["recipes"] += list(build_crafting_data(recipe))

	var/list/atoms = mode ? GLOB.cooking_recipes_atoms : GLOB.crafting_recipes_atoms

	// Prepare atom data
	for(var/atom/atom as anything in atoms)
		data["atom_data"] += list(list(
			"name" = initial(atom.name),
			"is_reagent" = ispath(atom, /datum/reagent/)
		))

	// Prepare materials data
	for(var/atom/atom as anything in material_occurences)
		if(material_occurences[atom] == 1)
			continue // Don't include materials that appear only once
		var/id = atoms.Find(atom)
		data["material_occurences"] += list(list(
				"atom_id" = "[id]",
				"occurences" = material_occurences[atom]
			))

	return data

/datum/component/personal_crafting/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("make")
			var/mob/user = usr
			var/datum/crafting_recipe/crafting_recipe = locate(params["recipe"]) in (mode ? GLOB.cooking_recipes : GLOB.crafting_recipes)
			busy = TRUE
			ui_interact(user)
			var/atom/movable/result = construct_item(user, crafting_recipe)
			if(!istext(result)) // We made an item and didn't get a fail message.
				if(ismob(user) && isitem(result)) // In case the user is actually possessing a non-mob like a machine.
					user.put_in_hands(result)
				else
					if(!istype(result, /obj/effect/spawner))
						result.forceMove(user.drop_location())
				to_chat(user, span_notice("[crafting_recipe.name] constructed."))
				user.investigate_log("crafted [crafting_recipe]", INVESTIGATE_CRAFTING)
				crafting_recipe.on_craft_completion(user, result)
			else
				to_chat(user, span_warning("Construction failed[result]"))
			busy = FALSE
		if("toggle_recipes")
			display_craftable_only = !display_craftable_only
			. = TRUE
		if("toggle_compact")
			display_compact = !display_compact
			. = TRUE
		if("toggle_mode")
			if(forced_mode)
				return
			mode = !mode
			var/mob/user = usr
			update_static_data(user)
			. = TRUE

/datum/component/personal_crafting/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/crafting),
		get_asset_datum(/datum/asset/spritesheet/crafting/cooking),
	)

/datum/component/personal_crafting/proc/build_crafting_data(datum/crafting_recipe/recipe)
	var/list/data = list()
	var/list/atoms = mode ? GLOB.cooking_recipes_atoms : GLOB.crafting_recipes_atoms

	data["ref"] = "[REF(recipe)]"
	var/atom/atom = recipe.result

	//load sprite sheets and select the correct one based on the mode
	var/static/list/sprite_sheets
	if(isnull(sprite_sheets))
		sprite_sheets = ui_assets()
	var/datum/asset/spritesheet/sheet = sprite_sheets[mode ? 2 : 1]

	//infer icon size of this atom
	var/atom_id = atoms.Find(atom)
	var/icon_size = sheet.icon_size_id("a[atom_id]")
	data["icon"] = "[icon_size] a[atom_id]"

	var/recipe_data = recipe.crafting_ui_data()
	for(var/new_data in recipe_data)
		data[new_data] = recipe_data[new_data]

	// Category
	data["category"] = recipe.category

	// Name, Description
	data["name"] = recipe.name || initial(atom.name)

	if(ispath(recipe.result, /datum/reagent))
		var/datum/reagent/reagent = recipe.result
		data["desc"] = recipe.desc || initial(reagent.description)

	// Tools
	if(recipe.tool_behaviors)
		data["tool_behaviors"] = recipe.tool_behaviors
	if(recipe.tool_paths)
		data["tool_paths"] = list()
		for(var/req_atom in recipe.tool_paths)
			data["tool_paths"] += atoms.Find(req_atom)

	// Ingredients / Materials
	if(recipe.reqs.len)
		data["reqs"] = list()
		for(var/req_atom in recipe.reqs)
			var/id = atoms.Find(req_atom)
			data["reqs"]["[id]"] = recipe.reqs[req_atom]

	return data

#undef COOKING
#undef CRAFTING

//Mind helpers

/// proc that teaches user a non-standard crafting recipe
/datum/mind/proc/teach_crafting_recipe(recipe)
	if(!learned_recipes)
		learned_recipes = list()
	learned_recipes |= recipe

/// proc that makes user forget a specific crafting recipe
/datum/mind/proc/forget_crafting_recipe(recipe)
	learned_recipes -= recipe

/datum/mind/proc/has_crafting_recipe(mob/user, potential_recipe)
	if(!learned_recipes)
		return FALSE
	if(!ispath(potential_recipe, /datum/crafting_recipe))
		CRASH("Non-crafting recipe passed to has_crafting_recipe")
	for(var/recipe in user.mind.learned_recipes)
		if(recipe == potential_recipe)
			return TRUE
	return FALSE
