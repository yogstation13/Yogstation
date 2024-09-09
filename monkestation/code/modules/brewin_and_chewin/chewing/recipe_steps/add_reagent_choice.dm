//A cooking step that involves adding a reagent to the food.
/datum/chewin_cooking/recipe_step/add_reagent_choice
	class=CHEWIN_ADD_REAGENT_CHOICE
	auto_complete_enabled = TRUE
	var/expected_total
	var/list/reagent_ids
	var/required_reagent_amount
	var/remain_percent = 1 //What percentage of the reagent ends up in the product

//reagent_ids: list of reagent_id = quality from step.
//amount: The amount of the required reagent that needs to be added.
//base_quality_award: The quality awarded by following this step.
//our_recipe: The parent recipe object,
/datum/chewin_cooking/recipe_step/add_reagent_choice/New(var/list/reagent_ids = list(),  var/amount, var/datum/chewin_cooking/recipe/our_recipe)

	if(!length(reagent_ids))
		CRASH("/datum/chewin_cooking/recipe_step/add/reagent/New(): No Reagent List Given")

	group_identifier = ""
	for(var/datum/reagent/reagent as anything in reagent_ids)
		var/datum/reagent/global_reagent = GLOB.chemical_reagents_list[reagent]
		if(global_reagent)
			desc = "Add [amount] unit[amount>1 ? "s" : ""] of [global_reagent.name]."

			group_identifier += "[initial(reagent.name)] "
		else
			CRASH("/datum/chewin_cooking/recipe_step/add/reagent/New(): Reagent [reagent] not found. Recipe: [our_recipe]")

	required_reagent_amount = amount
	src.reagent_ids = reagent_ids

	..(our_recipe)


/datum/chewin_cooking/recipe_step/add_reagent_choice/check_conditions_met(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/container = tracker.holder_ref.resolve()


	var/return_type = CHEWIN_CHECK_VALID
	for(var/datum/reagent/required_reagent_id as anything in reagent_ids)
		return_type = CHEWIN_CHECK_VALID
		if((container.reagents.total_volume + required_reagent_amount - container.reagents.get_reagent_amount(required_reagent_id)) > container.reagents.maximum_volume)
			return_type = CHEWIN_CHECK_FULL

		if(!istype(used_item, /obj/item/reagent_containers))
			return_type =  CHEWIN_CHECK_INVALID
		if(!(used_item.reagents?.flags & OPENCONTAINER))
			return_type = CHEWIN_CHECK_INVALID

		var/obj/item/reagent_containers/our_item = used_item
		if(our_item.amount_per_transfer_from_this <= 0)
			return_type = CHEWIN_CHECK_INVALID
		if(our_item.reagents.total_volume == 0)
			return_type =  CHEWIN_CHECK_INVALID

		if(return_type == CHEWIN_CHECK_VALID)
			return return_type

	return return_type

//Reagents are calculated in two areas. Here and /datum/chewin_cooking/recipe/proc/calculate_reagent_quality
/datum/chewin_cooking/recipe_step/add_reagent_choice/calculate_quality(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/container = tracker.holder_ref.resolve()
	for(var/datum/reagent/reagent as anything in container.reagents.reagent_list)
		if(!(reagent.type in reagent_ids))
			continue
		if(reagent.volume < required_reagent_amount)
			continue
		return reagent_ids[reagent.type]


/datum/chewin_cooking/recipe_step/add_reagent_choice/follow_step(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/our_item = used_item
	var/obj/item/container = tracker.holder_ref.resolve()

	var/trans = our_item.reagents.trans_to(container, our_item.amount_per_transfer_from_this)

	playsound(usr,'monkestation/sound/chemistry/transfer/beakerpour_0-10-1.ogg',50,1)
	to_chat(usr, span_notice("You transfer [trans] units to \the [container]."))

	return CHEWIN_SUCCESS

/datum/chewin_cooking/recipe_step/add_reagent_choice/is_complete(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/our_item = used_item
	var/obj/item/container = tracker.holder_ref.resolve()

	var/incoming_amount = max(0, min(our_item.amount_per_transfer_from_this, our_item.reagents.total_volume, (container.reagents.maximum_volume - container.reagents.total_volume)))

	var/incoming_valid_amount = incoming_amount

	for(var/datum/reagent/required_reagent_id as anything in reagent_ids)
		var/resulting_total = container.reagents.get_reagent_amount(required_reagent_id) + incoming_valid_amount
		if(resulting_total >= required_reagent_amount)
			return TRUE
	return FALSE
