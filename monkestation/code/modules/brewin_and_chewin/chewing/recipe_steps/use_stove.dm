//A cooking step that involves adding a reagent to the food.
/datum/chewin_cooking/recipe_step/use_stove
	class=CHEWIN_USE_STOVE
	auto_complete_enabled = TRUE
	var/time
	var/heat

//set_heat: The temperature the stove must cook at.
//set_time: How long something must be cook in the stove
//our_recipe: The parent recipe object
/datum/chewin_cooking/recipe_step/use_stove/New(var/set_heat, var/set_time, var/datum/chewin_cooking/recipe/our_recipe)



	time = set_time
	heat = set_heat

	desc = "Cook on a stove set to [heat] for [DisplayTimeText(time)]."

	..(our_recipe)


/datum/chewin_cooking/recipe_step/use_stove/check_conditions_met(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)

	if(!used_item.GetComponent(/datum/component/stove))
		return CHEWIN_CHECK_INVALID

	return CHEWIN_CHECK_VALID

//Reagents are calculated prior to object creation
/datum/chewin_cooking/recipe_step/use_stove/calculate_quality(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/cooking_container/container = tracker.holder_ref.resolve()

	var/bad_cooking = 0
	for (var/key in container.stove_data)
		if (heat != key)
			bad_cooking += container.stove_data[key]

	bad_cooking = round(bad_cooking / (5 SECONDS))

	var/good_cooking = round(time / (3 SECONDS)) - bad_cooking

	return clamp_quality(good_cooking)


/datum/chewin_cooking/recipe_step/use_stove/follow_step(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	return CHEWIN_SUCCESS

/datum/chewin_cooking/recipe_step/use_stove/is_complete(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)

	var/obj/item/reagent_containers/cooking_container/container = tracker.holder_ref.resolve()

	if(container.stove_data[heat] >= time)
		#ifdef CHEWIN_DEBUG
		log_debug("use_stove/is_complete() Returned True; comparing [heat]: [container.stove_data[heat]] to [time]")
		#endif
		return TRUE

	#ifdef CHEWIN_DEBUG
	log_debug("use_stove/is_complete() Returned False; comparing [heat]: [container.stove_data[heat]] to [time]")
	#endif
	return FALSE
