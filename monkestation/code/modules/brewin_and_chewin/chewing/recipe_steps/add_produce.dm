//A cooking step that involves using SPECIFICALLY Grown foods
/datum/chewin_cooking/recipe_step/add_produce
	class=CHEWIN_ADD_PRODUCE
	var/required_produce_type
	var/base_potency
	var/reagent_skip = FALSE
	var/inherited_quality_modifier

	var/list/exclude_reagents = list()

/datum/chewin_cooking/recipe_step/add_produce/New(var/obj/item/food/grown/produce, var/datum/chewin_cooking/recipe/our_recipe)
	if(produce)
		desc = "Add \a [produce] into the recipe."
		required_produce_type = produce
		group_identifier = produce

		var/obj/item/food/grown/grown =  new produce
		var/obj/item/seeds/plant_seed = grown.seed
		base_potency = initial(plant_seed.potency)
		qdel(grown)
	else
		CRASH("/datum/chewin_cooking/recipe_step/add_produce/New: [produce] not found. Exiting.")
	..(base_quality_award, our_recipe)

/datum/chewin_cooking/recipe_step/add_produce/check_conditions_met(var/obj/added_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	#ifdef CHEWIN_DEBUG
	log_debug("Called add_produce/check_conditions_met for [added_item] against [required_produce_type]")
	#endif

	if(!istype(added_item, /obj/item/food/grown))
		return CHEWIN_CHECK_INVALID

	var/obj/item/food/grown/added_produce = added_item

	if(added_produce.type == required_produce_type)
		return CHEWIN_CHECK_VALID

	return CHEWIN_CHECK_INVALID

/datum/chewin_cooking/recipe_step/add_produce/calculate_quality(var/obj/added_item, var/datum/chewin_cooking/recipe_tracker/tracker)

	var/obj/item/food/grown/added_produce = added_item

	var/potency_raw = round(base_quality_award + (added_produce.seed.potency - base_potency) * inherited_quality_modifier)

	return clamp_quality(potency_raw)

/datum/chewin_cooking/recipe_step/add_produce/follow_step(var/obj/added_item, var/datum/chewin_cooking/recipe_tracker/tracker)
	#ifdef CHEWIN_DEBUG
	log_debug("Called: /datum/chewin_cooking/recipe_step/add_produce/follow_step")
	#endif
	var/obj/item/container = tracker.holder_ref.resolve()
	if(container)
		if(usr.canUnEquip(added_item))
			usr.dropItemToGround(added_item)
			added_item.forceMove(container)
		else
			added_item.forceMove(container)
	return CHEWIN_SUCCESS
