/obj/structure/machine/assembly_bench
	name = "assembly bench"
	desc = "Can be used to assemble smithed parts together. Put in a smithed part to start."

	density = TRUE
	anchored = TRUE

	icon = 'monkestation/code/modules/smithing/icons/forge_structures.dmi'
	icon_state = "crafting_bench_empty"

	var/list/recipes = list()
	var/datum/assembly_recipe/current_recipe
	var/list/stored_items = list()
	var/obj/item/held_starting_item

/obj/structure/machine/assembly_bench/Initialize(mapload)
	. = ..()
	for(var/datum/assembly_recipe/subtype as anything in subtypesof(/datum/assembly_recipe) - /datum/assembly_recipe/smithed_weapon)
		recipes += new subtype
	register_context()

/obj/structure/machine/assembly_bench/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!current_recipe && held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Add to select recipe"
	else
		context[SCREENTIP_CONTEXT_LMB] = "Add to progress recipe"
	if(current_recipe)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Clear Recipe."
	return CONTEXTUAL_SCREENTIP_SET


/obj/structure/machine/assembly_bench/examine(mob/user)
	. = ..()
	if(current_recipe)
		for(var/obj/item/item as anything in current_recipe.needed_items)
			. += span_notice("[current_recipe.needed_items[item]] [initial(item.name)] needed.")

/obj/structure/machine/assembly_bench/AltClick(mob/user)
	if(current_recipe)
		for(var/obj/item/stored in stored_items)
			stored.forceMove(user.loc)
			stored_items -= stored
		clear_recipe()
		return TRUE
	. = ..()


/obj/structure/machine/assembly_bench/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.tool_behaviour == TOOL_WRENCH && !current_recipe)
		default_unfasten_wrench(user,attacking_item,40)
		return
	if(!anchored)
		return ..()
	if(!current_recipe)
		for(var/datum/assembly_recipe/recipe as anything in recipes)
			if(recipe.item_to_start != attacking_item.type)
				continue
			current_recipe = new recipe.type
			current_recipe.parent = src
			attacking_item.forceMove(src)
			stored_items += attacking_item
			held_starting_item = attacking_item
			return

	if(current_recipe)
		for(var/item in current_recipe.needed_items)
			if(istype(attacking_item, item))
				current_recipe.needed_items[item]--

				if(isstack(attacking_item))
					var/obj/item/stack/stack = attacking_item
					if(stack.amount == 1)
						attacking_item.forceMove(src)
					else
						var/obj/item/stack/new_stack = stack.split_stack(user, 1)
						attacking_item = new_stack
						new_stack.forceMove(src)
				else
					attacking_item.forceMove(src)

				stored_items += attacking_item
				if((!current_recipe.needed_items[item]) || current_recipe.needed_items[item] <= 0)
					current_recipe.needed_items -= item
				if(!length(current_recipe.needed_items))
					try_complete_recipe(user)
				return
	return ..()

/obj/structure/machine/assembly_bench/proc/try_complete_recipe(mob/living/user)
	if(!current_recipe)
		return
	if(length(current_recipe.needed_items))
		return
	if(do_after(user, current_recipe.craft_time, src))
		current_recipe.complete_recipe()
		user.mind.adjust_experience(/datum/skill/smithing, 10) //You made a thing! Congrats!

/obj/structure/machine/assembly_bench/attack_hand(mob/living/user, list/modifiers)
	try_complete_recipe(user)
	. = ..()

/obj/structure/machine/assembly_bench/proc/clear_recipe()
	current_recipe.parent = null
	held_starting_item = null
	QDEL_NULL(current_recipe)
	QDEL_LIST(stored_items)
	stored_items = list()
