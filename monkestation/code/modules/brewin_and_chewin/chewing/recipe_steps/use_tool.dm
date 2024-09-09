//A cooking step that involves using an item on the food.
/datum/chewin_cooking/recipe_step/use_tool
	class=CHEWIN_USE_ITEM
	var/tool_type
	var/tool_quality
	var/inherited_quality_modifier = 0.1

//item_type: The type path of the object we are looking for.
//base_quality_award: The quality awarded by following this step.
//our_recipe: The parent recipe object
/datum/chewin_cooking/recipe_step/use_tool/New(var/type, var/quality, var/datum/chewin_cooking/recipe/our_recipe)

	desc = "Use \a [type] tool of quality [quality] or higher."

	tool_type = type
	tool_quality = quality

	..(our_recipe)


/datum/chewin_cooking/recipe_step/use_tool/check_conditions_met(var/obj/item/added_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	if(!initial(added_item.tool_behaviour))
		return CHEWIN_CHECK_INVALID

	return CHEWIN_CHECK_VALID

/datum/chewin_cooking/recipe_step/use_tool/follow_step(var/obj/added_item, var/obj/item/reagent_containers/cooking_container/container)
	var/obj/item/our_tool = added_item
	to_chat(usr, span_notice("You use the [added_item] according to the recipe."))

	if(our_tool.toolspeed < tool_quality)
		return to_chat(usr, span_notice("The low quality of the tool hurts the quality of the dish."))

	return CHEWIN_SUCCESS

//Think about a way to make this more intuitive?
/datum/chewin_cooking/recipe_step/use_tool/calculate_quality(var/obj/added_item)
	var/obj/item/our_tool = added_item
	var/raw_quality = (our_tool.toolspeed - tool_quality) * inherited_quality_modifier
	return clamp_quality(raw_quality)
