/obj/machinery/assembler
	name = "assembler"
	desc = "Produces a set recipe when given the materials, some say a small cargo technican is stuck inside making these things."
	circuit = /obj/item/circuitboard/machine/assembler

	var/speed_multiplier = 1
	var/datum/crafting_recipe/chosen_recipe
	var/crafting = FALSE

	var/static/list/crafting_recipes = list()
	var/list/crafting_inventory = list()

	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "assembler"


/obj/machinery/assembler/Initialize(mapload)
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/hovering_information, /datum/hover_data/assembler)
	register_context()

	if(!length(crafting_recipes))
		create_recipes()

/obj/machinery/assembler/RefreshParts()
	. = ..()
	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	if(!locate_servo)
		return
	speed_multiplier = 1 / locate_servo.tier

/obj/machinery/assembler/Destroy()
	. = ..()
	for(var/atom/movable/movable in crafting_inventory)
		movable.forceMove(get_turf(src))
		crafting_inventory -= movable

/obj/machinery/assembler/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(chosen_recipe)
		var/processable = "Accepts: "
		var/comma = FALSE
		for(var/atom/atom as anything in chosen_recipe.reqs)
			if(comma)
				processable += ", "
			processable += initial(atom.name)
			comma = !comma
		context[SCREENTIP_CONTEXT_MISC] = processable
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/assembler/examine(mob/user)
	. = ..()
	if(chosen_recipe)
		. += span_notice(chosen_recipe.name)
		for(var/atom/atom as anything in chosen_recipe.reqs)
			. += span_notice("[initial(atom.name)]: [chosen_recipe.reqs[atom]]")

/obj/machinery/assembler/proc/create_recipes()
	for(var/datum/crafting_recipe/recipe as anything in subtypesof(/datum/crafting_recipe) - /datum/crafting_recipe/stack)
		if(initial(recipe.non_craftable) || !initial(recipe.always_available))
			continue
		crafting_recipes += new recipe

/obj/machinery/assembler/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/datum/crafting_recipe/choice = tgui_input_list(user, "Choose a recipe", name, crafting_recipes)
	if(!choice)
		return
	chosen_recipe = choice
	for(var/atom/movable/listed as anything in crafting_inventory)
		listed.forceMove(get_turf(src))
		crafting_inventory -= listed

/obj/machinery/assembler/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(!chosen_recipe)
		return FALSE
	var/failed = TRUE
	for(var/atom/movable/movable as anything in chosen_recipe.reqs)
		if(istype(mover, movable))
			failed = FALSE
			break
	if(failed)
		return FALSE
	if(!check_item(mover))
		return FALSE
	return ..()

/obj/machinery/assembler/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(accept_item), atom_movable)

/obj/machinery/assembler/proc/accept_item(atom/movable/atom_movable)
	if(!chosen_recipe)
		return
	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		if(!(stack.merge_type in chosen_recipe.reqs))
			return FALSE
	else
		var/failed = TRUE
		for(var/atom/movable/movable as anything in chosen_recipe.reqs)
			if(istype(atom_movable, movable))
				failed = FALSE
				break
		if(failed)
			return FALSE

	atom_movable.forceMove(src)
	crafting_inventory += atom_movable
	check_recipe_state()


/obj/machinery/assembler/can_drop_off(atom/movable/target)
	if(!check_item(target))
		return FALSE
	return TRUE


/obj/machinery/assembler/proc/check_item(atom/movable/atom_movable)
	if(!chosen_recipe)
		return
	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		if(!(stack.merge_type in chosen_recipe.reqs))
			return FALSE

	if(!isstack(atom_movable))
		var/failed = TRUE
		for(var/atom/movable/movable as anything in chosen_recipe.reqs)
			if(istype(atom_movable, movable))
				failed = FALSE
				break
		if(failed)
			return FALSE

	var/list/reqs = chosen_recipe.reqs.Copy()
	for(var/atom/movable/listed in reqs)
		reqs[listed] *= 10 // we can queue 10 crafts of everything

	for(var/atom/movable/item in crafting_inventory)
		if(isstack(item))
			var/obj/item/stack/stack = item
			if(item in reqs)
				reqs[item.type] -= stack.amount
				if(reqs[item.type] <= 0)
					reqs -= item.type
		else
			for(var/atom/movable/movable as anything in chosen_recipe.reqs)
				if(istype(item, movable))
					reqs[movable]--
					if(reqs[movable] <= 0)
						reqs -= movable
	if(!length(reqs))
		return FALSE

	var/passed = FALSE
	for(var/atom/movable/movable as anything in chosen_recipe.reqs)
		if(istype(atom_movable, movable))
			passed = TRUE
			break
	if(passed)
		return TRUE

	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		if((stack.merge_type in reqs))
			return TRUE

	return FALSE


/obj/machinery/assembler/proc/check_recipe_state()
	if(!chosen_recipe)
		return
	var/list/reqs = chosen_recipe.reqs.Copy()
	if(!length(reqs))
		return

	for(var/atom/movable/item in crafting_inventory)
		if(isstack(item))
			var/obj/item/stack/stack = item
			if(stack.merge_type in reqs)
				reqs[stack.merge_type] -= stack.amount
				if(reqs[stack.merge_type] <= 0)
					reqs -= stack.merge_type
		else
			for(var/atom/movable/movable as anything in chosen_recipe.reqs)
				if(istype(item, movable))
					reqs[movable]--
					if(reqs[movable] <= 0)
						reqs -= movable
	if(!length(reqs))
		start_craft()

/obj/machinery/assembler/proc/start_craft()
	if(crafting)
		return
	crafting = TRUE

	if(!machine_do_after_visable(src, chosen_recipe.time * speed_multiplier * 3))
		return

	var/list/requirements = chosen_recipe.reqs
	var/list/parts = list()

	for(var/obj/item/req as anything in requirements)
		for(var/obj/item/item as anything in crafting_inventory)
			if(!istype(item, req))
				continue
			if(isstack(item))
				var/obj/item/stack/stack = item
				if(stack.amount == requirements[stack.merge_type])
					var/failed = TRUE
					crafting_inventory -= item
					for(var/obj/item/part as anything in chosen_recipe.parts)
						if(!istype(item, part))
							continue
						parts += item
						failed = FALSE
					if(failed)
						qdel(item)
				else if(stack.amount > requirements[item.type])
					for(var/obj/item/part as anything in chosen_recipe.parts)
						if(!istype(item, part))
							continue
						var/obj/item/stack/new_stack = new item
						new_stack.amount = requirements[item.type]
						parts += new_stack
					stack.amount -= requirements[stack.merge_type]
			else
				var/failed = TRUE
				crafting_inventory -= item
				for(var/obj/item/part as anything in chosen_recipe.parts)
					if(!istype(item, part))
						continue
					parts += item
					failed = FALSE

				if(failed)
					qdel(item)

	var/atom/movable/I
	if(ispath(chosen_recipe.result, /obj/item/stack))
		I = new chosen_recipe.result(src, chosen_recipe.result_amount || 1)
		I.forceMove(drop_location())
	else
		I = new chosen_recipe.result (src)
		I.forceMove(drop_location())
		if(I.atom_storage && chosen_recipe.delete_contents)
			for(var/obj/item/thing in I)
				qdel(thing)
	I.CheckParts(parts, chosen_recipe)
	I.forceMove(drop_location())

	crafting = FALSE
	check_recipe_state()


/datum/hover_data/assembler
	var/obj/effect/overlay/hover/recipe_icon
	var/last_type

/datum/hover_data/assembler/New(datum/component/hovering_information, atom/parent)
	. = ..()
	recipe_icon = new(null)
	recipe_icon.maptext_width = 64
	recipe_icon.maptext_y = 32
	recipe_icon.maptext_x = -4
	recipe_icon.alpha = 125

/datum/hover_data/assembler/setup_data(obj/machinery/assembler/source, mob/enterer)
	. = ..()
	if(!source.chosen_recipe)
		return
	if(last_type != source.chosen_recipe.result)
		update_image(source)
	var/image/new_image = new(source)
	new_image.appearance = recipe_icon.appearance
	SET_PLANE_EXPLICIT(new_image, new_image.plane, source)
	if(!isturf(source.loc))
		new_image.loc = source.loc
	else
		new_image.loc = source
	add_client_image(new_image, enterer.client)

/datum/hover_data/assembler/proc/update_image(obj/machinery/assembler/source)
	if(!source.chosen_recipe)
		return
	last_type = source.chosen_recipe.result

	var/atom/atom = source.chosen_recipe.result

	recipe_icon.icon = initial(atom.icon)
	recipe_icon.icon_state = initial(atom.icon_state)
