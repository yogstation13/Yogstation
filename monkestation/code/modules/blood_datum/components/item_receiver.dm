/datum/component/item_receiver
	var/list/item_types = list()
	var/take_message

/datum/component/item_receiver/Initialize(list/types = list(), take_message)
	. = ..()
	var/mob/living/living_parent = parent
	if(!living_parent.usable_hands)
		return COMPONENT_INCOMPATIBLE

	item_types = types
	src.take_message = take_message

/datum/component/item_receiver/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_ITEM_OFFERED_PRECHECK, PROC_REF(precheck_item))
	RegisterSignal(parent, COMSIG_LIVING_GIVE_ITEM_CHECK, PROC_REF(try_take_item))

/datum/component/item_receiver/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_LIVING_ITEM_OFFERED_PRECHECK, COMSIG_LIVING_GIVE_ITEM_CHECK))

/datum/component/item_receiver/proc/precheck_item(datum/source, obj/item/offer)
	if(!length(item_types))
		return TRUE

	for(var/item as anything in item_types)
		if(istype(offer, item))
			return TRUE

	return FALSE


/datum/component/item_receiver/proc/try_take_item(datum/source, atom/movable/screen/alert/give/alert, obj/item/offer)
	var/can_take = FALSE
	for(var/item as anything in item_types)
		if(istype(offer, item))
			can_take = TRUE
			break

	if(!can_take)
		return FALSE

	var/visible_message = TRUE
	if(take_message)
		visible_message = FALSE

	if(!alert.handle_transfer(visible_message))
		return FALSE

	if(take_message)
		var/atom/movable/movable = parent
		movable.visible_message(span_notice("[movable] [take_message] [offer]"))

	return TRUE

