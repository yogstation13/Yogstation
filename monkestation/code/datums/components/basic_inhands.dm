/datum/component/basic_inhands/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/basic_inhands/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/datum/component/basic_inhands/proc/on_examine(datum/source, mob/user, list/examine_info)
	SIGNAL_HANDLER
	var/mob/living/parent = src.parent
	for(var/obj/item/held_thing in parent.held_items)
		if(held_thing.item_flags & (ABSTRACT | EXAMINE_SKIP | HAND_ITEM))
			continue
		examine_info += span_info("[parent.p_They()] [parent.p_are()] holding [held_thing.get_examine_string(user)] in [parent.p_their()] [parent.get_held_index_name(parent.get_held_index_of_item(held_thing))].")
