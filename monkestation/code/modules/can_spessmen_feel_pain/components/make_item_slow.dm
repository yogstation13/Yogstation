/**
 * Simple component that handles making an item slow the person holding it,
 * as well as reverting it to its prior state when deleted.
 */
/datum/component/make_item_slow
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The amount of slowdown applied to the item.
	var/applied_slowdown = 1
	/// The slowdown of [parent] before the component was applied.
	var/initial_slowdown = 0

/datum/component/make_item_slow/Initialize(applied_slowdown = 1)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent

	if(item_parent.item_flags & SLOWS_WHILE_IN_HAND) // it already does it!
		return COMPONENT_INCOMPATIBLE

	src.initial_slowdown = item_parent.slowdown
	src.applied_slowdown = applied_slowdown

	make_slow()

/datum/component/make_item_slow/Destroy()
	revert_slow()
	return ..()

/**
 * If this component is applied to a parent that already has the same typer component, just update the slowness to the new value.
 */
/datum/component/make_item_slow/InheritComponent(datum/component/make_item_slow/passed_component, original, applied_slowdown = 1)
	src.applied_slowdown = applied_slowdown
	make_slow()

/**
 * Apply our slowness to the attatched item.
 */
/datum/component/make_item_slow/proc/make_slow()
	var/obj/item/item_parent = parent
	var/mob/living/carbon/mob_holder = item_parent.loc

	item_parent.slowdown = applied_slowdown
	item_parent.item_flags |= SLOWS_WHILE_IN_HAND

	if(istype(mob_holder))
		mob_holder.update_equipment_speed_mods()

/**
 * Remove our slowness from the attatched item.
 */
/datum/component/make_item_slow/proc/revert_slow()
	var/obj/item/item_parent = parent
	var/mob/living/carbon/mob_holder = item_parent.loc

	item_parent.slowdown = initial_slowdown
	item_parent.item_flags &= ~SLOWS_WHILE_IN_HAND

	if(istype(mob_holder))
		mob_holder.update_equipment_speed_mods()
