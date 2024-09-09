//A cooking step that involves adding a reagent to the food.
/datum/chewin_cooking/recipe_step/add_reagent
	class=CHEWIN_ADD_REAGENT
	auto_complete_enabled = TRUE
	var/expected_total
	var/required_reagent_id
	var/required_reagent_amount
	var/remain_percent = 1 //What percentage of the reagent ends up in the product

//reagent_id: The id of the required reagent to be added, E.G. 'salt'.
//amount: The amount of the required reagent that needs to be added.
//base_quality_award: The quality awarded by following this step.
//our_recipe: The parent recipe object,
/datum/chewin_cooking/recipe_step/add_reagent/New(var/reagent_id,  var/amount, var/datum/chewin_cooking/recipe/our_recipe)

	var/datum/reagent/global_reagent = GLOB.chemical_reagents_list[reagent_id]
	if(global_reagent)
		desc = "Add [amount] unit[amount>1 ? "s" : ""] of [global_reagent.name]."

		required_reagent_id = reagent_id
		group_identifier = reagent_id

		required_reagent_amount = amount
	else
		CRASH("/datum/chewin_cooking/recipe_step/add/reagent/New(): Reagent [reagent_id] not found. Recipe: [our_recipe]")

	..(our_recipe)


/datum/chewin_cooking/recipe_step/add_reagent/check_conditions_met(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/container = tracker.holder_ref.resolve()


	if((container.reagents.total_volume + required_reagent_amount - container.reagents.get_reagent_amount(required_reagent_id)) > container.reagents.maximum_volume)
		return CHEWIN_CHECK_FULL

	if(!istype(used_item, /obj/item/reagent_containers))
		return CHEWIN_CHECK_INVALID
	if(!(used_item.reagents?.flags & OPENCONTAINER))
		return CHEWIN_CHECK_INVALID

	var/obj/item/reagent_containers/our_item = used_item
	if(our_item.amount_per_transfer_from_this <= 0)
		return CHEWIN_CHECK_INVALID
	if(our_item.reagents.total_volume == 0)
		return CHEWIN_CHECK_INVALID

	return CHEWIN_CHECK_VALID

//Reagents are calculated in two areas. Here and /datum/chewin_cooking/recipe/proc/calculate_reagent_quality
/datum/chewin_cooking/recipe_step/add_reagent/calculate_quality(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/container = tracker.holder_ref.resolve()
	var/data = container.reagents.get_data(required_reagent_id)
	var/cooked_quality = 0
	if(data && istype(data, /list) && data["FOOD_QUALITY"])
		cooked_quality = data["FOOD_QUALITY"]
	return cooked_quality


/datum/chewin_cooking/recipe_step/add_reagent/follow_step(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/our_item = used_item
	var/obj/item/container = tracker.holder_ref.resolve()

	var/trans = our_item.reagents.trans_to(container, our_item.amount_per_transfer_from_this)

	playsound(usr,'monkestation/sound/chemistry/transfer/beakerpour_0-10-1.ogg',50,1)
	to_chat(usr, span_notice("You transfer [trans] units to \the [container]."))

	return CHEWIN_SUCCESS

/datum/chewin_cooking/recipe_step/add_reagent/is_complete(var/obj/used_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/our_item = used_item
	var/obj/item/container = tracker.holder_ref.resolve()

	var/incoming_amount = max(0, min(our_item.amount_per_transfer_from_this, our_item.reagents.total_volume, (container.reagents.maximum_volume - container.reagents.total_volume)))

	var/incoming_valid_amount = incoming_amount

	var/resulting_total = container.reagents.get_reagent_amount(required_reagent_id) + incoming_valid_amount
	if(resulting_total >= required_reagent_amount)
		return TRUE
	return FALSE
