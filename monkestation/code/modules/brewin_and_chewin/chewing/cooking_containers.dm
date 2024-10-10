//Cooking containers are used in ovens, fryers and so on, to hold multiple ingredients for a recipe.
//They interact with the cooking process, and link up with the cooking code dynamically.

//Originally sourced from the Aurora, heavily retooled to actually work with CHEWIN


//Holder for a portion of an incomplete meal,
//allows a cook to temporarily offload recipes to work on things factory-style, eliminating the need for 20 plates to get things done fast.

/obj/item/reagent_containers/cooking_container
	icon = 'monkestation/code/modules/brewin_and_chewin/icons/kitchen.dmi'
	verb_exclaim = ""
	var/shortname
	var/place_verb = "into"
	var/appliancetype //string
	w_class = WEIGHT_CLASS_SMALL
	volume = 240 //Don't make recipes using reagents in larger quantities than this amount; they won't work.
	var/datum/chewin_cooking/recipe_tracker/tracker = null //To be populated the first time the plate is interacted with.
	var/lip //Icon state of the lip layer of the object
	var/removal_penalty = 0 //A flat quality reduction for removing an unfinished recipe from the container.

	possible_transfer_amounts = list(5,10,30,60,90,120,240)
	amount_per_transfer_from_this = 10

	reagent_flags = OPENCONTAINER | NO_REACT
	var/list/fryer_data = list("High"=0) //Record of what deepfryer-cooking has been done on this food.
	var/list/stove_data = list("High"=0 , "Medium" = 0, "Low"=0) //Record of what stove-cooking has been done on this food.
	var/list/grill_data = list("High"=0 , "Medium" = 0, "Low"=0) //Record of what grill-cooking has been done on this food.
	var/list/oven_data = list("High"=0 , "Medium" = 0, "Low"=0) //Record of what oven-cooking has been done on this food.

/obj/item/reagent_containers/cooking_container/Initialize()
	.=..()
	appearance_flags |= KEEP_TOGETHER
	RegisterSignal(src, COMSIG_STOVE_PROCESS, PROC_REF(process_stovetop))
	RegisterSignal(src, COMSIG_ITEM_OVEN_PROCESS, PROC_REF(process_bake))


/obj/item/reagent_containers/cooking_container/examine(mob/user)
	. = ..()
	if(contents)
		.+= get_content_info()
	if(reagents.total_volume)
		.+= get_reagent_info()

/obj/item/reagent_containers/cooking_container/proc/get_content_info()
	var/string = "It contains:</br><ul><li>"
	string += jointext(contents, "</li><li>") + "</li></ul>"
	return string

/obj/item/reagent_containers/cooking_container/proc/get_reagent_info()
	return "It contains [reagents.total_volume] units of reagents."

/obj/item/reagent_containers/cooking_container/attackby(var/obj/item/used_item, var/mob/user)

	#ifdef CHEWIN_DEBUG
	logger.Log(LOG_CATEGORY_DEBUG"cooking_container/attackby() called!")
	#endif

	if(istype(used_item, /obj/item/spatula))
		do_empty(user, target=null, reagent_clear = FALSE)
		return

	if(!tracker && (contents.len || reagents.total_volume != 0))
		to_chat(user, "The [src] is full. Empty its contents first.")
	else
		process_item(used_item, user)

	return TRUE

/obj/item/reagent_containers/cooking_container/after_attack_pour(mob/user, atom/target)


	#ifdef CHEWIN_DEBUG
	logger.Log(LOG_CATEGORY_DEBUG"cooking_container/standard_pour_into() called!")
	#endif

	if(tracker)
		if(alert(user, "There is an ongoing recipe in the [src]. Dump it out?",,"Yes","No") == "No")
			return FALSE
		for(var/datum/reagent/our_reagent in reagents.reagent_list)
			if(our_reagent.data && istype(our_reagent.data, /list) && our_reagent.data["FOOD_QUALITY"])
				our_reagent.data["FOOD_QUALITY"] = 0

	do_empty(user, target, reagent_clear = FALSE)

	#ifdef CHEWIN_DEBUG
	logger.Log(LOG_CATEGORY_DEBUG"cooking_container/do_empty() completed!")
	#endif

	. = ..()


/obj/item/reagent_containers/cooking_container/afterattack(var/obj/target, var/mob/user, var/flag)
	if(!istype(target, /obj/item/reagent_containers))
		return FALSE
	if(!flag)
		return FALSE
	if(tracker)
		return FALSE
	if(after_attack_pour(user, target))
		return TRUE

/obj/item/reagent_containers/cooking_container/proc/process_item(var/obj/I, var/mob/user, var/lower_quality_on_fail = 0, var/send_message = TRUE)


	#ifdef CHEWIN_DEBUG
	logger.Log(LOG_CATEGORY_DEBUG"cooking_container/process_item() called!")
	#endif

	//OK, time to load the tracker
	if(!tracker)
		if(lower_quality_on_fail)
			for (var/obj/item/contained in contents)
				contained?:food_quality -= lower_quality_on_fail
		else
			tracker = new /datum/chewin_cooking/recipe_tracker(src)

	var/return_value = 0
	switch(tracker.process_item_wrap(I, user))
		if(CHEWIN_NO_STEPS)
			if(no_step_checks(I)) //literally fryers
				if(send_message)
					to_chat(user, "It doesn't seem like you can create a meal from that. Yet.")
				if(lower_quality_on_fail)
					for (var/datum/chewin_cooking/recipe_pointer/pointer in tracker.active_recipe_pointers)
						pointer?:tracked_quality -= lower_quality_on_fail
		if(CHEWIN_CHOICE_CANCEL)
			if(send_message)
				to_chat(user, "You decide against cooking with the [src].")
		if(CHEWIN_COMPLETE)
			if(send_message)
				to_chat(user, "You finish cooking with the [src].")
			qdel(tracker)
			tracker = null
			clear_cooking_data()
			update_icon()
			return_value = 1
		if(CHEWIN_SUCCESS)
			if(send_message)
				to_chat(user, "You have successfully completed a recipe step.")
			clear_cooking_data()
			return_value = 1
			update_icon()
		if(CHEWIN_PARTIAL_SUCCESS)
			if(send_message)
				to_chat(user, "More must be done to complete this step of the recipe.")
		if(CHEWIN_LOCKOUT)
			if(send_message)
				to_chat(user, "You can't make the same decision twice!")

	if(tracker && !tracker.recipe_started)
		qdel(tracker)
		tracker = null
	return return_value

//TODO: Handle the contents of the container being ruined via burning.
/obj/item/reagent_containers/cooking_container/proc/handle_burning()
	return

//TODO: Handle the contents of the container lighting on actual fire.
/obj/item/reagent_containers/cooking_container/proc/handle_ignition()
	return FALSE

/obj/item/reagent_containers/cooking_container/verb/empty()
	set src in view(1)
	set name = "Empty Container"
	set category = "Object"
	set desc = "Removes items from the container, excluding reagents."
	do_empty(usr)

/obj/item/reagent_containers/cooking_container/proc/do_empty(mob/user, var/atom/target = null, var/reagent_clear = TRUE)
	#ifdef CHEWIN_DEBUG
	logger.Log(LOG_CATEGORY_DEBUG"cooking_container/do_empty() called!")
	#endif

	if(contents.len != 0)
		if(tracker && removal_penalty)
			for (var/obj/item/contained in contents)
				contained?:food_quality -= removal_penalty
			to_chat(user, span_warning("The quality of ingredients in the [src] was reduced by the extra jostling."))

		//Handle quality reduction for reagents
		if(reagents.total_volume != 0)
			var/reagent_qual_reduction = round(reagents.total_volume/contents.len)
			if(reagent_qual_reduction != 0)
				for (var/obj/item/contained in contents)
					contained?:food_quality -= reagent_qual_reduction
				to_chat(user, span_warning("The quality of ingredients in the [src] was reduced by the presence of reagents in the container."))


		for (var/contained in contents)
			var/atom/movable/AM = contained
			remove_from_visible(AM)
			if(!target)
				AM.forceMove(get_turf(src))
			else
				AM.forceMove(get_turf(target))

	//TODO: Splash the reagents somewhere
	if(reagent_clear)
		reagents.clear_reagents()

	update_icon()
	qdel(tracker)
	tracker = null
	clear_cooking_data()

	if(contents.len != 0)
		to_chat(user, span_notice("You remove all the solid items from [src]."))


/obj/item/reagent_containers/cooking_container/AltClick(var/mob/user)
	do_empty(user)

//Deletes contents of container.
//Used when food is burned, before replacing it with a burned mess
/obj/item/reagent_containers/cooking_container/proc/clear()
	QDEL_LIST(contents)
	contents=list()
	reagents.clear_reagents()
	if(tracker)
		qdel(tracker)
		tracker = null
	clear_cooking_data()


/obj/item/reagent_containers/cooking_container/proc/clear_cooking_data()
	stove_data = list("High"=0 , "Medium" = 0, "Low"=0)
	grill_data = list("High"=0 , "Medium" = 0, "Low"=0)
	fryer_data = list("High"=0)

/obj/item/reagent_containers/cooking_container/proc/label(var/number, var/CT = null)
	//This returns something like "Fryer basket 1 - empty"
	//The latter part is a brief reminder of contents
	//This is used in the removal menu
	. = shortname
	if (!isnull(number))
		.+= " [number]"
	.+= " - "
	if (LAZYLEN(contents))
		var/obj/O = locate() in contents
		return . + O.name //Just append the name of the first object
	return . + "empty"

/obj/item/reagent_containers/cooking_container/update_icon()
	. = ..()
	cut_overlays()
	for(var/obj/item/our_item in vis_contents)
		src.remove_from_visible(our_item)

	for(var/i=contents.len, i>=1, i--)
		var/obj/item/our_item = contents[i]
		src.add_to_visible(our_item)
	if(lip)
		add_overlay(image(src.icon, icon_state=lip, layer=ABOVE_OBJ_LAYER))

/obj/item/reagent_containers/cooking_container/proc/add_to_visible(var/obj/item/our_item)
	our_item.pixel_x = initial(our_item.pixel_x)
	our_item.pixel_y = initial(our_item.pixel_y)
	our_item.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	our_item.blend_mode = BLEND_INSET_OVERLAY
	our_item.transform *= 0.6
	src.vis_contents += our_item

/obj/item/reagent_containers/cooking_container/proc/remove_from_visible(var/obj/item/our_item)
	our_item.vis_flags = 0
	our_item.blend_mode = 0
	our_item.transform = null
	src.vis_contents.Remove(our_item)

/obj/item/reagent_containers/cooking_container/plate
	icon = 'monkestation/code/modules/brewin_and_chewin/icons/eris_kitchen.dmi'
	name = "serving plate"
	shortname = "plate"
	desc = "A shitty serving plate. You probably shouldn't be seeing this."
	icon_state = "plate"
	appliancetype = PLATE

/obj/item/reagent_containers/cooking_container/board
	name = "cutting board"
	shortname = "cutting_board"
	desc = "Good for making sandwiches on, too."
	icon_state = "cutting_board"
	appliancetype = CUTTING_BOARD

/obj/item/reagent_containers/cooking_container/oven
	name = "oven tray"
	shortname = "shelf"
	desc = "Put ingredients in this; designed for use with an oven. Warranty void if used."
	icon_state = "oven_dish"
	lip = "oven_dish_lip"
	appliancetype = OVEN

/obj/item/reagent_containers/cooking_container/proc/process_bake(datum/source, obj/machinery/oven/oven, seconds_per_tick)
	#ifdef CWJ_DEBUG
	logger.Log(LOG_CATEGORY_DEBUG"grill/proc/process_bake data:", list("temperature: [oven.temperature]", "reference_time: [oven.reference_time]", " world.time: [world.time]", "cooking_timestamp: [oven.cooking_timestamp]", " grill_data: [grill_data]"))
	#endif

	if(oven_data[oven.temperature])
		oven_data[oven.temperature] += seconds_per_tick * 10
	else
		oven_data[oven.temperature] = seconds_per_tick * 10
	return COMPONENT_BAKING_GOOD_RESULT | COMPONENT_HANDLED_BAKING

/obj/item/reagent_containers/cooking_container/proc/process_stovetop(datum/source, temperature, seconds_per_tick, obj/stove_object)
	if(stove_data[temperature])
		stove_data[temperature] += seconds_per_tick * 10
	else
		stove_data[temperature] = seconds_per_tick * 10
	process_item(stove_object, null, FALSE, FALSE)
	return TRUE

/obj/item/reagent_containers/cooking_container/pan
	name = "pan"
	desc = "An normal pan."

	icon_state = "pan" //Default state is the base icon so it looks nice in the map builder
	lip = "pan_lip"
	hitsound = 'sound/weapons/smash.ogg'
	appliancetype = PAN

/obj/item/reagent_containers/cooking_container/pot
	name = "cooking pot"
	shortname = "cooking pot"
	desc = "Boil things with this. Maybe even stick 'em in a stew."

	icon_state = "pot"
	lip = "pot_lip"

	hitsound = 'sound/weapons/smash.ogg'
	removal_penalty = 5
	appliancetype = POT
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reagent_containers/cooking_container/deep_basket
	name = "deep fryer basket"
	shortname = "basket"
	desc = "Cwispy! Warranty void if used."

	icon_state = "deepfryer_basket"
	lip = "deepfryer_basket_lip"
	removal_penalty = 5
	appliancetype = DF_BASKET

/obj/item/reagent_containers/cooking_container/proc/no_step_checks(obj/item/item)
	return TRUE

/obj/item/reagent_containers/cooking_container/deep_basket/no_step_checks(obj/item/item)
	item.forceMove(src)
	qdel(tracker)
	update_icon()
	return FALSE


/obj/item/reagent_containers/cooking_container/air_basket
	name = "air fryer basket"
	shortname = "basket"
	desc = "Permanently laminated with dried oil and late-stage capitalism."

	icon_state = "airfryer_basket"
	lip = "airfryer_basket_lip"
	removal_penalty = 5
	appliancetype = AF_BASKET


/obj/item/reagent_containers/cooking_container/grill_grate
	name = "grill grate"
	shortname = "grate"
	place_verb = "onto"
	desc = "Primarily used to grill meat, place this on a grill and enjoy an ancient human tradition."

	icon_state = "grill_grate"

	appliancetype = GRILL

/obj/item/reagent_containers/cooking_container/bowl
	name = "mixing bowl"
	shortname = "mixing bowl"
	desc = "A bowl."

	icon_state = "bowl"
	lip = "bowl_lip"

	removal_penalty = 2
	appliancetype = BOWL
