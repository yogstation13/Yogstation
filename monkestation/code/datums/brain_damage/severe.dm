/datum/brain_trauma/severe/kleptomaniac
	var/pickpocket_chance_percent = 25

// this proc is so terribly made
// i wish i could access /datum/element/strippable
/datum/brain_trauma/severe/kleptomaniac/proc/steal_from_someone()
	// Owner must be currently able to strip others.
	if(HAS_TRAIT(owner, TRAIT_CANT_STRIP))
		return
	if(!HAS_TRAIT(owner, TRAIT_CAN_STRIP))
		return

	var/list/potential_victims = list()
	for(var/mob/living/carbon/human/potential_victim in view(1, owner))
		if(potential_victim == owner)
			continue
		var/list/items_in_pockets = potential_victim.get_pockets()
		if(!length(items_in_pockets))
			return
		potential_victims += potential_victim

	if(!length(potential_victims))
		return

	var/mob/living/carbon/human/victim = pick(potential_victims)

	// `items_in_pockets` should never be empty, given that we excluded them above. If it *is*
	// empty, something is horribly wrong!
	var/obj/item/item_to_steal = pick(victim.get_pockets())
	owner.visible_message(
		span_warning("[owner] attempts to remove [item_to_steal] from [victim]'s pocket!"),
		span_warning("You attempt to remove [item_to_steal] from [victim]'s pocket."),
		span_hear("You hear rustling."),
	)

	if(victim.is_blind())
		to_chat(victim, span_userdanger("You feel someone fumble with your belongings."))

	owner.log_message(
		"is pickpocketing [item_to_steal] out of [key_name(victim)]'s pockets (kleptomania).",
		LOG_ATTACK,
		color = "red",
	)
	victim.log_message(
		"is having [item_to_steal] pickpocketed by [key_name(owner)] (kleptomania).",
		LOG_VICTIM,
		color = "orange",
		log_globally = FALSE,
	)

	if(!do_after(owner, item_to_steal.strip_delay, victim) || !victim.temporarilyRemoveItemFromInventory(item_to_steal))
		owner.visible_message(
			span_warning("[owner] fails to pickpocket [victim]."),
			span_warning("You fail to pick [victim]'s pocket."),
			null
		)
		return

	owner.log_message(
		"has pickpocketed [key_name(victim)] of [item_to_steal] (kleptomania).",
		LOG_ATTACK,
		color = "red",
	)
	victim.log_message(
		"has been pickpocketed of [item_to_steal] by [key_name(owner)] (kleptomania).",
		LOG_VICTIM,
		color = "orange",
		log_globally = FALSE,
	)

	owner.visible_message(
		span_warning("[owner] removes [item_to_steal] from [victim]'s pocket!"),
		span_warning("You remove [item_to_steal] from [victim]'s pocket."),
		null
	)

	if(QDELETED(item_to_steal))
		return

	var/hand_index_to_steal_to = owner.active_hand_index
	if(owner.get_active_held_item())
		hand_index_to_steal_to = owner.get_inactive_hand_index()
	if(!owner.putItemFromInventoryInHandIfPossible(item_to_steal, hand_index_to_steal_to, TRUE))
		item_to_steal.forceMove(owner.drop_location())

/mob/living/carbon/human/proc/get_pockets()
	var/list/pockets = list()
	if(l_store)
		pockets += l_store
	if(r_store)
		pockets += r_store
	if(s_store)
		pockets += s_store
	return pockets
