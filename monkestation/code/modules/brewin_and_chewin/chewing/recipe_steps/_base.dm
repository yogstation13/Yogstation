//A step in a recipe, whether optional or required
/datum/chewin_cooking/recipe_step
	var/unique_id //Special ID for a given recipe, allows for referencing later by food objects to save on memory.

	var/class = CHEWIN_USE_OTHER //The classificaiton of the step involved.

	var/group_identifier = "None" //Different for every type of recipe.

	var/image/tooltip_image = null

	var/parent_recipe //The parent recipe of this particular step. Created on initialization with New()

	var/desc		//A description of the step

	var/custom_result_desc //A custom description of the resulting quality on a successful completion.

	var/list/optional_step_list = list() //List of optional steps that can be followed from this point forward.

	var/max_quality_award = 0 //The maximum quality awarded by following a given step to the letter.

	var/base_quality_award = 0

	var/flags = 0

	var/custom_food_buff

	var/finish_text

	//The next required step for the parent recipe
	var/datum/chewin_cooking/recipe_step/next_step

	//The previous required step for the current recipe
	var/datum/chewin_cooking/recipe_step/previous_step

	var/auto_complete_enabled = FALSE //If the step can be completed without any further input.



/datum/chewin_cooking/recipe_step/New(var/datum/chewin_cooking/recipe/our_recipe)
	parent_recipe = our_recipe
	unique_id = sequential_id("recipe_step")

	if(!tooltip_image)
		src.set_image()

	//Add the recipe to our dictionary for future reference.
	if(!GLOB.chewin_step_dictionary_ordered["[class]"])
		GLOB.chewin_step_dictionary_ordered["[class]"] = list()
	GLOB.chewin_step_dictionary_ordered["[class]"]["[unique_id]"] = src
	GLOB.chewin_step_dictionary["[unique_id]"] = src

/datum/chewin_cooking/recipe_step/proc/set_image()


//Calculate how well the recipe step was followed to the letter.
/datum/chewin_cooking/recipe_step/proc/calculate_quality(var/obj/added_item, var/obj/item/reagent_containers/container)
	return 0

//Check if the conditions of a recipe step was followed correctly.
/datum/chewin_cooking/recipe_step/proc/check_conditions_met()
	return CHEWIN_CHECK_VALID

//Check if a given step is in the same option chain as another step.
/datum/chewin_cooking/recipe_step/proc/in_option_chain(var/datum/chewin_cooking/recipe_step/step)
	if(!step)
		return FALSE
	if(!(flags & CHEWIN_IS_OPTION_CHAIN) || !(step.flags & CHEWIN_IS_OPTION_CHAIN))
		return FALSE

	var/datum/chewin_cooking/recipe_step/target_step = src.previous_step
	//traverse backwards on the chain.
	while(target_step && !(target_step & CHEWIN_IS_OPTION_CHAIN))
		if(step.unique_id == target_step.unique_id)
			return TRUE
		target_step = target_step.previous_step

	//Traverse forwards on the chain.
	target_step = src.next_step
	while(target_step && !(target_step & CHEWIN_IS_OPTION_CHAIN))
		if(step.unique_id == target_step.unique_id)
			return TRUE
		target_step = src.next_step

	//We didn't find anything. Return False.
	return FALSE

//Automatically clamps food based on their maximum and minimum quality, if they are set.
/datum/chewin_cooking/recipe_step/proc/clamp_quality(var/raw_quality)
	if((flags & CHEWIN_BASE_QUALITY_ENABLED) && (flags & CHEWIN_MAX_QUALITY_ENABLED))
		return clamp(raw_quality, base_quality_award, max_quality_award)
	if(flags & CHEWIN_BASE_QUALITY_ENABLED)
		return max(raw_quality, base_quality_award)
	if(flags & CHEWIN_MAX_QUALITY_ENABLED)
		return min(raw_quality, max_quality_award)
	return raw_quality

/datum/chewin_cooking/recipe_step/proc/get_step_result_text(var/obj/used_obj, step_quality)
	if(custom_result_desc)
		return custom_result_desc
	else
		return "skip"

/datum/chewin_cooking/recipe_step/proc/follow_step(var/obj/added_item, var/obj/item/reagent_containers/container)
	return CHEWIN_SUCCESS

//Special function to check if the step has been satisfied. Sometimed just following the step is enough, but not always.
/datum/chewin_cooking/recipe_step/proc/is_complete(var/obj/added_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	return TRUE
