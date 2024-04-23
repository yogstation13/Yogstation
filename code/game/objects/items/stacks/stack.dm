/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

/*
 * Stacks
 */
/obj/item/stack
	icon = 'yogstation/icons/obj/stack_objects.dmi' // yogs -- use yog icons instead of tg
	gender = PLURAL
	max_integrity = 100
	/// A list to all recipies this stack item can create.
	var/list/datum/stack_recipe/recipes
	/// What's the name of just 1 of this stack. You have a stack of leather, but one piece of leather
	var/singular_name
	/// How much is in this stack?
	var/amount = 1
	/// How much is allowed in this stack?
	// Also see stack recipes initialisation. "max_res_amount" must be equal to this max_amount
	var/max_amount = 50
	/// If TRUE, this stack is a module used by a cyborg (doesn't run out like normal / etc)
	var/is_cyborg = FALSE
	/// Related to above. If present, the energy we draw from when using stack items, for cyborgs
	var/datum/robot_energy_storage/source
	/// Related to above. How much energy it costs from storage to use stack items
	var/cost = 1
	/// This path and its children should merge with this stack, defaults to src.type
	var/merge_type = null
	/// The weight class the stack has at amount > 2/3rds max_amount
	var/full_w_class = WEIGHT_CLASS_NORMAL
	/// Determines whether the item should update it's sprites based on amount.
	var/novariants = TRUE
	/// List that tells you how much is in a single unit.
	var/list/mats_per_unit
	/// Datum material type that this stack is made of
	var/material_type
	/// Does it merge strictly only with its type
	var/strict = FALSE
	//NOTE: When adding grind_results, the amounts should be for an INDIVIDUAL ITEM - these amounts will be multiplied by the stack size in on_grind()
	var/obj/structure/table/tableVariant // we tables now (stores table variant to be built from this stack)
	var/mats_per_stack = 0
	/// Amount of matter for RCD
	var/matter_amount = 0

/obj/item/stack/on_grind()
	for(var/i in 1 to grind_results.len) //This should only call if it's ground, so no need to check if grind_results exists
		grind_results[grind_results[i]] *= get_amount() //Gets the key at position i, then the reagent amount of that key, then multiplies it by stack size

/obj/item/stack/grind_requirements()
	if(is_cyborg)
		to_chat(usr, span_danger("[src] is electronically synthesized in your chassis and can't be ground up!"))
		return
	return TRUE

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	if(new_amount != null)
		amount = new_amount
	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount, FALSE)
	if(!merge_type)
		merge_type = type

	// if(LAZYLEN(mat_override))
	// 	set_mats_per_unit(mat_override, mat_amt)
	// else if(LAZYLEN(mats_per_unit))
	// 	set_mats_per_unit(mats_per_unit, 1)
	// else if(LAZYLEN(custom_materials))
	// 	set_mats_per_unit(custom_materials, amount ? 1/amount : 1)
	
	. = ..()
	if(merge)
		for(var/obj/item/stack/item_stack in loc)
			if(item_stack == src)
				continue
			if(can_merge(item_stack))
				INVOKE_ASYNC(src, PROC_REF(merge_without_del), item_stack)
				if(is_zero_amount(delete_if_zero = FALSE))
					return INITIALIZE_HINT_QDEL
	
	// recipes = get_main_recipes().Copy()
	// if(material_type)
	// 	var/datum/material/what_are_we_made_of = GET_MATERIAL_REF(material_type) //First/main material
	// 	for(var/category in what_are_we_made_of.categories)
	// 		switch(category)
	// 			if(MAT_CATEGORY_BASE_RECIPES)
	// 				recipes |= SSmaterials.base_stack_recipes.Copy()
	// 			if(MAT_CATEGORY_RIGID)
	// 				recipes |= SSmaterials.rigid_stack_recipes.Copy()

	update_weight()
	update_appearance()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_movable_entered_occupied_turf),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/** Sets the amount of materials per unit for this stack.
 *
 * Arguments:
 * - [mats][/list]: The value to set the mats per unit to.
 * - multiplier: The amount to multiply the mats per unit by. Defaults to 1.
 */
/obj/item/stack/proc/set_mats_per_unit(list/mats, multiplier=1)
	//mats_per_unit = SSmaterials.FindOrCreateMaterialCombo(mats, multiplier)
	update_custom_materials()

/** Updates the custom materials list of this stack.
 */
/obj/item/stack/proc/update_custom_materials()
	set_custom_materials(mats_per_unit, amount, is_update=TRUE)

/**
 * Override to make things like metalgen accurately set custom materials
 */
/obj/item/stack/set_custom_materials(list/materials, multiplier=1, is_update=FALSE)
	return is_update ? ..() : set_mats_per_unit(materials, multiplier/(amount || 1))

/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1/3)))
		w_class = clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if (amount <= (max_amount * (2/3)))
		w_class = clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		w_class = full_w_class

/obj/item/stack/update_icon_state()
	. = ..()
	if(novariants)
		return
	if(amount <= (max_amount * (1/3)))
		icon_state = initial(icon_state)
	else if (amount <= (max_amount * (2/3)))
		icon_state = "[initial(icon_state)]_2"
	else
		icon_state = "[initial(icon_state)]_3"

/obj/item/stack/examine(mob/user)
	. = ..()
	if (is_cyborg)
		if(singular_name)
			. += "There is enough energy for [get_amount()] [singular_name]\s."
		else
			. += "There is enough energy for [get_amount()]."
		return
	if(singular_name)
		if(get_amount()>1)
			. += "There are [get_amount()] [singular_name]\s in the stack."
		else
			. += "There is [get_amount()] [singular_name] in the stack."
	else if(get_amount()>1)
		. += "There are [get_amount()] in the stack."
	else
		. += "There is [get_amount()] in the stack."
	. += span_notice("Alt-click to take a custom amount.")

/obj/item/stack/proc/get_amount()
	if(is_cyborg)
		. = round(source?.energy / cost)
	else
		. = (amount)

/**
  * Builds all recipes in a given recipe list and returns an association list containing them
  *
  * Arguments:
  * * recipe_to_iterate - The list of recipes we are using to build recipes
  */
/obj/item/stack/proc/recursively_build_recipes(list/recipe_to_iterate)
	var/list/L = list()
	for(var/recipe in recipe_to_iterate)
		if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/R = recipe
			L["[R.title]"] = recursively_build_recipes(R.recipes)
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/R = recipe
			L["[R.title]"] = build_recipe(R)
	return L

/**
  * Returns a list of properties of a given recipe
  *
  * Arguments:
  * * R - The stack recipe we are using to get a list of properties
  */
/obj/item/stack/proc/build_recipe(datum/stack_recipe/R)
	return list(
		"res_amount" = R.res_amount,
		"max_res_amount" = R.max_res_amount,
		"req_amount" = R.req_amount,
		"ref" = "\ref[R]",
	)

/**
  * Checks if the recipe is valid to be used
  *
  * Arguments:
  * * R - The stack recipe we are checking if it is valid
  * * recipe_list - The list of recipes we are using to check the given recipe
  */
/obj/item/stack/proc/is_valid_recipe(datum/stack_recipe/R, list/recipe_list)
	for(var/S in recipe_list)
		if(S == R)
			return TRUE
		if(istype(S, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/L = S
			if(is_valid_recipe(R, L.recipes))
				return TRUE
	return FALSE

/obj/item/stack/attack_self(mob/user)
	interact(user)

/obj/item/stack/interact(mob/user)
	ui_interact(user)

/obj/item/stack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/stack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StackCrafting", name)
		ui.open()

/obj/item/stack/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = get_amount()
	return data

/obj/item/stack/ui_static_data(mob/user)
	var/list/data = list()
	data["recipes"] = recursively_build_recipes(recipes)
	return data

/obj/item/stack/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("make")
			if(get_amount() < 1 && !is_cyborg)
				qdel(src)
				return
			var/datum/stack_recipe/R = locate(params["ref"])
			if(!is_valid_recipe(R, recipes)) //href exploit protection
				return
			var/multiplier = text2num(params["multiplier"])
			if(!multiplier || (multiplier <= 0)) //href exploit protection
				return
			if(!building_checks(R, multiplier))
				return
			if(R.time)
				var/adjusted_time = 0
				usr.visible_message("<span class='notice'>[usr] starts building \a [R.title].</span>", "<span class='notice'>You start building \a [R.title]...</span>")
				adjusted_time = R.time
				if(!do_after(usr, adjusted_time, usr))
					return
				if(!building_checks(R, multiplier))
					return

			var/obj/O
			if(R.max_res_amount > 1) //Is it a stack?
				O = new R.result_type(usr.drop_location(), R.res_amount * multiplier)
			else if(ispath(R.result_type, /turf))
				var/turf/T = usr.drop_location()
				if(!isturf(T))
					return
				T.place_on_top(R.result_type, flags = CHANGETURF_INHERIT_AIR)
			else
				O = new R.result_type(usr.drop_location())
			if(O)
				O.setDir(usr.dir)
			use(R.req_amount * multiplier)

			if(istype(O, /obj/structure/windoor_assembly))
				var/obj/structure/windoor_assembly/W = O
				W.ini_dir = W.dir
			else if(istype(O, /obj/structure/window))
				var/obj/structure/window/W = O
				W.ini_dir = W.dir

			if(QDELETED(O))
				return //It's a stack and has already been merged

			if(isitem(O))
				usr.put_in_hands(O)
			O.add_fingerprint(usr)

			//BubbleWrap - so newly formed boxes are empty
			if(istype(O, /obj/item/storage))
				for (var/obj/item/I in O)
					qdel(I)
			//BubbleWrap END
			return TRUE

/obj/item/stack/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, amount))
		add(clamp(vval, 1-amount, max_amount - amount)) //there must always be one.
		return TRUE
	else if(vname == NAMEOF(src, max_amount))
		max_amount = max(vval, 1)
		add((max_amount < amount) ? (max_amount - amount) : 0) //update icon, weight, ect
		return TRUE
	return ..()

/obj/item/stack/proc/building_checks(datum/stack_recipe/R, multiplier)
	if (get_amount() < R.req_amount*multiplier)
		if (R.req_amount*multiplier>1)
			to_chat(usr, span_warning("You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!"))
		else
			to_chat(usr, span_warning("You haven't got enough [src] to build \the [R.title]!"))
		return FALSE
	var/turf/T = get_turf(usr)

	var/obj/D = R.result_type
	if(R.window_checks && !valid_window_location(T, initial(D.dir) == FULLTILE_WINDOW_DIR ? FULLTILE_WINDOW_DIR : usr.dir))
		to_chat(usr, span_warning("The [R.title] won't fit here!"))
		return FALSE
	if(R.one_per_turf && (locate(R.result_type) in T))
		to_chat(usr, span_warning("There is another [R.title] here!"))
		return FALSE
	if(R.on_floor)
		if(!isfloorturf(T))
			to_chat(usr, span_warning("\The [R.title] must be constructed on the floor!"))
			return FALSE
		for(var/obj/AM in T)
			if(istype(AM,/obj/structure/grille))
				continue
			if(istype(AM,/obj/structure/table))
				continue
			if(istype(AM,/obj/structure/window))
				var/obj/structure/window/W = AM
				if(!W.fulltile)
					continue
			if(AM.density)
				to_chat(usr, span_warning("Theres a [AM.name] here. You cant make a [R.title] here!"))
				return FALSE
	if(R.placement_checks)
		switch(R.placement_checks)
			if(STACK_CHECK_CARDINALS)
				var/turf/step
				for(var/direction in GLOB.cardinals)
					step = get_step(T, direction)
					if(locate(R.result_type) in step)
						to_chat(usr, span_warning("\The [R.title] must not be built directly adjacent to another!"))
						return FALSE
			if(STACK_CHECK_ADJACENT)
				if(locate(R.result_type) in range(1, T))
					to_chat(usr, span_warning("\The [R.title] must be constructed at least one tile away from others of its type!"))
					return FALSE
	return TRUE

/obj/item/stack/use(used, transfer = FALSE, check = TRUE) // return 0 = borked; return 1 = had enough
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return FALSE
	if (is_cyborg)
		return source.use_charge(used * cost)
	if (amount < used)
		return FALSE
	amount -= used
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return TRUE
	if(length(mats_per_unit))
		update_custom_materials()
	update_appearance()
	update_weight()
	return TRUE

/obj/item/stack/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		if(singular_name)
			if(amount > 1)
				to_chat(user, span_warning("You need at least [amount] [singular_name]\s to do this!"))
			else
				to_chat(user, span_warning("You need at least [amount] [singular_name] to do this!"))
		else
			to_chat(user, span_warning("You need at least [amount] to do this!"))

		return FALSE

	return TRUE

/**
 * Returns TRUE if the item stack is the equivalent of a 0 amount item.
 *
 * Also deletes the item if delete_if_zero is TRUE and the stack does not have
 * is_cyborg set to true.
 */
/obj/item/stack/proc/is_zero_amount(delete_if_zero = TRUE)
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		if(delete_if_zero)
			qdel(src)
		return TRUE
	return FALSE

/** Adds some number of units to this stack.
 *
 * Arguments:
 * - _amount: The number of units to add to this stack.
 */
/obj/item/stack/proc/add(_amount)
	if(is_cyborg)
		source.add_charge(_amount * cost)
	else
		amount += _amount
	if(length(mats_per_unit))
		update_custom_materials()
	update_appearance()
	update_weight()

/** Checks whether this stack can merge itself into another stack.
 *
 * Arguments:
 * - [check][/obj/item/stack]: The stack to check for mergeability.
 * - [inhand][boolean]: Whether or not the stack to check should act like it's in a mob's hand.
 */
/obj/item/stack/proc/can_merge(obj/item/stack/check, inhand = FALSE)
	// We don't only use istype here, since that will match subtypes, and stack things that shouldn't stack
	if(!istype(check, merge_type) || check.merge_type != merge_type)
		return FALSE
	if(mats_per_unit ~! check.mats_per_unit) // ~! in case of lists this operator checks only keys, but not values
		return FALSE
	if(is_cyborg) // No merging cyborg stacks into other stacks
		return FALSE
	if(ismob(loc) && !inhand) // no merging with items that are on the mob
		return FALSE
	if(istype(loc, /obj/machinery)) // no merging items in machines that aren't both in componentparts
		var/obj/machinery/machine = loc
		if(!(src in machine.component_parts) || !(check in machine.component_parts))
			return FALSE
	if(SEND_SIGNAL(src, COMSIG_STACK_CAN_MERGE, check, inhand) & CANCEL_STACK_MERGE)
		return FALSE
	return TRUE


/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This calls use() without check = FALSE, preventing the item from qdeling itself if it reaches 0 stack size.
 *
 * As a result, this proc can leave behind a 0 amount stack.
 */
/obj/item/stack/proc/merge_without_del(obj/item/stack/target_stack, limit)
	// Cover edge cases where multiple stacks are being merged together and haven't been deleted properly.
	// Also cover edge case where a stack is being merged into itself, which is supposedly possible.
	if(QDELETED(target_stack))
		CRASH("Stack merge attempted on qdeleted target stack.")
	if(QDELETED(src))
		CRASH("Stack merge attempted on qdeleted source stack.")
	if(target_stack == src)
		CRASH("Stack attempted to merge into itself.")

	var/transfer = get_amount()
	if(target_stack.is_cyborg)
		transfer = min(transfer, round((target_stack.source.max_energy - target_stack.source.energy) / target_stack.cost))
	else
		transfer = min(transfer, (limit ? limit : target_stack.max_amount) - target_stack.amount)
	if(pulledby)
		pulledby.start_pulling(target_stack)
	target_stack.copy_evidences(src)
	use(transfer, transfer = TRUE, check = FALSE)
	target_stack.add(transfer)
	if(target_stack.mats_per_unit != mats_per_unit) // We get the average value of mats_per_unit between two stacks getting merged
		var/list/temp_mats_list = list() // mats_per_unit is passed by ref into this coil, and that same ref is used in other places. If we didn't make a new list here we'd end up contaminating those other places, which leads to batshit behavior
		for(var/mat_type in target_stack.mats_per_unit)
			temp_mats_list[mat_type] = (target_stack.mats_per_unit[mat_type] * (target_stack.amount - transfer) + mats_per_unit[mat_type] * transfer) / target_stack.amount
		target_stack.mats_per_unit = temp_mats_list
	return transfer

/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This proc deletes src if the remaining amount after the transfer is 0.
 */
/obj/item/stack/proc/merge(obj/item/stack/target_stack, limit)
	. = merge_without_del(target_stack, limit)
	is_zero_amount(delete_if_zero = TRUE)

// Signal handler for connect_loc element. Called when a movable enters the turf we're currently occupying. Merges if possible.
/obj/item/stack/proc/on_movable_entered_occupied_turf(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	// Edge case. This signal will also be sent when src has entered the turf. Don't want to merge with ourselves.
	if(arrived == src)
		return

	if(!arrived.throwing && can_merge(arrived))
		INVOKE_ASYNC(src, PROC_REF(merge), arrived)

/obj/item/stack/hitby(atom/movable/hitting, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(can_merge(hitting, inhand = TRUE))
		merge(hitting)
	. = ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/attack_hand(mob/user)
	if(user.get_inactive_held_item() == src)
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		return change_stack(user,1)
	else
		. = ..()

/obj/item/stack/AltClick(mob/living/user)
	. = ..()
	if(isturf(loc)) // to prevent people that are alt clicking a tile to see its content from getting undesidered pop ups
		return
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(is_cyborg)
		return
	else
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		//get amount from user
		var/max = get_amount()
		var/stackmaterial = round(input(user,"How many sheets do you wish to take out of this stack? (Maximum  [max])") as null|num)
		max = get_amount()
		stackmaterial = min(max, stackmaterial)
		if(stackmaterial == null || stackmaterial <= 0 || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
			return
		else
			change_stack(user, stackmaterial)
			to_chat(user, span_notice("You take [stackmaterial] sheets out of the stack."))

/obj/item/stack/proc/change_stack(mob/user, amount)
	if(!use(amount, TRUE, FALSE))
		return FALSE
	var/obj/item/stack/F = new type(user? user : drop_location(), amount, FALSE)
	. = F
	F.copy_evidences(src)
	if(user)
		if(!user.put_in_hands(F, merge_stacks = FALSE))
			F.forceMove(user.drop_location())
		add_fingerprint(user)
		F.add_fingerprint(user)
	is_zero_amount(delete_if_zero = TRUE)

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(strict && W.type == merge_type)
		var/obj/item/stack/S = W
		if(merge(S))
			to_chat(user, span_notice("Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s."))
	else if(!strict && istype(W, merge_type))
		var/obj/item/stack/S = W
		if(merge(S))
			to_chat(user, span_notice("Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s."))
	else
		. = ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	add_blood_DNA(from.return_blood_DNA())
	add_fingerprint_list(from.return_fingerprints())
	add_hiddenprint_list(from.return_hiddenprints())
	fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/obj/item/stack/microwave_act(obj/machinery/microwave/M)
	if(istype(M) && M.dirty < 100)
		M.dirty += amount

/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = FALSE
	var/on_floor = FALSE
	var/window_checks = FALSE
	var/placement_checks = FALSE

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1,time = 0, one_per_turf = FALSE, on_floor = FALSE, window_checks = FALSE, placement_checks = FALSE )


	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.window_checks = window_checks
	src.placement_checks = placement_checks
/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes
