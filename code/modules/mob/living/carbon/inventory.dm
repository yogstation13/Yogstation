/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_NECK)
			return wear_neck
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed

	return ..()

/mob/living/carbon/get_slot_by_item(obj/item/looking_for)
	if(looking_for == back)
		return ITEM_SLOT_BACK

	if(back && (looking_for in back))
		return ITEM_SLOT_BACKPACK

	if(looking_for == wear_mask)
		return ITEM_SLOT_MASK

	if(looking_for == wear_neck)
		return ITEM_SLOT_NECK

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	if(looking_for == handcuffed)
		return ITEM_SLOT_HANDCUFFED

	if(looking_for == legcuffed)
		return ITEM_SLOT_LEGCUFFED

	return ..()

/mob/living/carbon/proc/equip_in_one_of_slots(obj/item/I, list/slots, qdel_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(I, slots[slot], qdel_on_fail = 0, disable_warning = TRUE))
			return slot
	if(qdel_on_fail)
		qdel(I)
	return null

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
/mob/living/carbon/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return
	if(!istype(I))
		return

	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null
	if(client)
		client.screen -= I
	if(observers && observers.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client)
				observe.client.screen -= I
	I.forceMove(src)
	SET_PLANE_EXPLICIT(I, ABOVE_HUD_PLANE, src)
	I.appearance_flags |= NO_CLIENT_COLOR
	var/not_handled = FALSE
	switch(slot)
		if(ITEM_SLOT_BACK)
			back = I
			update_inv_back()
		if(ITEM_SLOT_MASK)
			wear_mask = I
			wear_mask_update(I, toggle_off = 0)
		if(ITEM_SLOT_HEAD)
			head = I
			SEND_SIGNAL(src, COMSIG_CARBON_EQUIP_HAT, I)
			head_update(I)
		if(ITEM_SLOT_NECK)
			wear_neck = I
			update_inv_neck(I)
		if(ITEM_SLOT_HANDCUFFED)
			set_handcuffed(I)
			update_handcuffed()
		if(ITEM_SLOT_LEGCUFFED)
			legcuffed = I
			update_inv_legcuffed()
		if(ITEM_SLOT_HANDS)
			put_in_hands(I)
			update_inv_hands()
		if(ITEM_SLOT_BACKPACK)
			if(!back || !SEND_SIGNAL(back, COMSIG_TRY_STORAGE_INSERT, I, src, TRUE))
				not_handled = TRUE
		else
			not_handled = TRUE

	//Item has been handled at this point and equipped callback can be safely called
	//We cannot call it for items that have not been handled as they are not yet correctly
	//in a slot (handled further down inheritance chain, probably living/carbon/human/equip_to_slot
	if(!not_handled)
		I.equipped(src, slot)

	return not_handled

/mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	. = ..() //Sets the default return value to what the parent returns.
	if(!. || !I) //We don't want to set anything to null if the parent returned 0.
		return

	if(I == head)
		head = null
		if(!QDELETED(src))
			SEND_SIGNAL(src, COMSIG_CARBON_UNEQUIP_HAT, I, force, newloc, no_move, invdrop, silent)
			head_update(I)
	else if(I == back)
		back = null
		if(!QDELETED(src))
			update_inv_back()
	else if(I == wear_mask)
		wear_mask = null
		if(!QDELETED(src))
			wear_mask_update(I, toggle_off = 1)
	if(I == wear_neck)
		wear_neck = null
		if(!QDELETED(src))
			update_inv_neck(I)
	else if(I == handcuffed)
		set_handcuffed(null)
		if(buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		if(!QDELETED(src))
			update_handcuffed()
	else if(I == legcuffed)
		legcuffed = null
		if(!QDELETED(src))
			update_inv_legcuffed()

	// Not an else-if because we're probably equipped in another slot
	if(I == internal && (QDELETED(src) || QDELETED(I) || I.loc != src))
		cutoff_internals()
		if(!QDELETED(src))
			update_mob_action_buttons(UPDATE_BUTTON_STATUS)

/// Returns TRUE if an air tank compatible helmet is equipped.
/mob/living/carbon/proc/can_breathe_helmet()
	if (isclothing(head) && (head.clothing_flags & HEADINTERNALS))
		return TRUE

/// Returns TRUE if an air tank compatible mask is equipped.
/mob/living/carbon/proc/can_breathe_mask()
	if (isclothing(wear_mask) && (wear_mask.clothing_flags & MASKINTERNALS))
		return TRUE

/// Returns TRUE if a breathing tube is equipped.
/mob/living/carbon/proc/can_breathe_tube()
	if (getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		return TRUE

/// Returns TRUE if an air tank compatible mask or breathing tube is equipped.
/mob/living/carbon/proc/can_breathe_internals()
	return can_breathe_tube() || can_breathe_mask() || can_breathe_helmet()

/// Returns truthy if air tank is open and mob lacks apparatus, or if the tank moved away from the mob.
/mob/living/carbon/proc/invalid_internals()
	return (internal || external) && (!can_breathe_internals() || (internal && internal.loc != src))

/**
 * Open the internal air tank without checking for any breathing apparatus.
 * Returns TRUE if the air tank was opened successfully.
 * Closes any existing tanks before opening another one.
 *
 * Arguments:
 * * tank - The given tank to open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!target_tank)
		return
	close_all_airtanks()
	if (is_external)
		external = target_tank
	else
		internal = target_tank
	target_tank.after_internals_opened(src)
	update_mob_action_buttons()
	return TRUE

/**
 * Opens the given internal air tank if a breathing apparatus is found. Returns TRUE if successful, FALSE otherwise.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank we will attempt to toggle open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/try_open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!can_breathe_internals())
		return
	return open_internals(target_tank, is_external)

/**
 * Actually closes the active internal or external air tank.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/close_internals(is_external = FALSE)
	var/obj/item/tank/target_tank = is_external ? external : internal
	if (!target_tank)
		return
	if (is_external)
		external = null
	else
		internal = null
	target_tank.after_internals_closed(src)
	update_mob_action_buttons()
	return TRUE

/// Close the the currently open external (that's EX-ternal) air tank. Returns TREUE if successful.
/mob/living/carbon/proc/close_externals()
	return close_internals(TRUE)

/// Quickly/lazily close all airtanks without any returns or notifications.
/mob/living/carbon/proc/close_all_airtanks()
	if (external)
		close_externals()
	if (internal)
		close_internals()

/**
 * Prepares to open the internal air tank and notifies the mob in chat.
 * Handles displaying messages to the user before doing the actual opening.
 * Returns TRUE if the tank was opened/closed successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from.
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/toggle_open_internals(obj/item/tank/target_tank, is_external = FALSE)
	if (!target_tank)
		return
	if(internal || (is_external && external))
		to_chat(src, span_notice("You switch your internals to [target_tank]."))
	else
		to_chat(src, span_notice("You open [target_tank] valve."))
	return open_internals(target_tank, is_external)

/**
 * Prepares to close the currently open internal air tank and notifies in chat.
 * Handles displaying messages to the user before doing the actual closing.
 * Returns TRUE if
 *
 * Arguments:
 * * is_external - A boolean which indicates if the air tank must be equipped, or stored elsewhere.
 */
/mob/living/carbon/proc/toggle_close_internals(is_external = FALSE)
	if (!internal && !external)
		return
	to_chat(src, span_notice("You close [is_external ? external : internal] valve."))
	return close_internals(is_external)

/// Prepares emergency disconnect from open air tanks and notifies in chat. Usually called after mob suddenly unequips breathing apparatus.
/mob/living/carbon/proc/cutoff_internals()
	if (!external && !internal)
		return
	to_chat(src, span_notice("Your internals disconnect from [external || internal] and the valve closes."))
	close_all_airtanks()

/**
 * Toggles the given internal air tank open, or close the currently open one, if a compatible breathing apparatus is found.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from internally.
 */
/mob/living/carbon/proc/toggle_internals(obj/item/tank)
	// Carbons can't open their own internals tanks.
	return FALSE

/**
 * Toggles the given external (that's EX-ternal) air tank open, or close the currently open one, if a compatible breathing apparatus is found.
 * Returns TRUE if the tank was opened successfully.
 *
 * Arguments:
 * * tank - The given tank to toggle open and start breathing from externally.
 */
/mob/living/carbon/proc/toggle_externals(obj/item/tank)
	// Carbons can't open their own externals tanks.
	return FALSE

/// Handle stuff to update when a mob equips/unequips a mask.
/mob/living/proc/wear_mask_update(obj/item/I, toggle_off = 1)
	update_inv_wear_mask()

/mob/living/carbon/wear_mask_update(obj/item/I, toggle_off = 1)
	var/obj/item/clothing/C = I
	if(istype(C) && (C.tint || initial(C.tint)))
		update_tint()
	update_inv_wear_mask()

/// Handle stuff to update when a mob equips/unequips a headgear.
/mob/living/carbon/proc/head_update(obj/item/I, forced)
	if(istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if(C.tint || initial(C.tint))
			update_tint()
		update_sight()
	if(I.flags_inv & HIDEMASK || forced)
		update_inv_wear_mask()
	update_inv_head()

/mob/living/carbon/proc/get_holding_bodypart_of_item(obj/item/I)
	var/index = get_held_index_of_item(I)
	return index && hand_bodyparts[index]

  /*
  Proc called when giving an item to another player

  This handles creating an alert and adding an overlay to it
  */
/mob/living/carbon/give()
	. = ..()
	var/obj/item/receiving = get_active_held_item()
	if(!receiving)
		to_chat(src, span_warning("You're not holding anything to give!"))
		return
	visible_message(span_notice("[src] is offering [receiving]."), \
					span_notice("You offer [receiving]."), null, 2)
	for(var/mob/living/carbon/C in orange(1, src))
		if(!CanReach(C))
			return
		var/atom/movable/screen/alert/give/G = C.throw_alert("[src]", /atom/movable/screen/alert/give)
		if(!G)
			return
		G.setup(C, src, receiving)

  /*
  Proc called when the player clicks the give alert

  Handles checking if the player taking the item has open slots and is in range of the giver
  Also deals with the actual transferring of the item to the players hands
  Arguments:
  * giver - The person giving the original item
  * I - The item being given by the giver
  */
/mob/living/carbon/proc/take(mob/living/carbon/giver, obj/item/I)
	clear_alert("[giver]")
	if(get_dist(src, giver) > 1)
		to_chat(src, span_warning("[giver] is out of range! "))
		return
	if(!I || giver.get_active_held_item() != I)
		to_chat(src, span_warning("[giver] is no longer holding the item they were offering! "))
		return
	if(!get_empty_held_indexes())
		to_chat(src, span_warning("You have no empty hands!"))
		return
	if(!giver.temporarilyRemoveItemFromInventory(I))
		visible_message("<span class='notice'>[src] tries to hand over [I] but it's stuck to them....", \
						"<span class'notice'> You make a fool of yourself trying to give away an item stuck to your hands")
		return
	put_in_hands(I)
