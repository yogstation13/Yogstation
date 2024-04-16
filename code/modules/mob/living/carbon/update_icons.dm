//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying != lying_prev && rotate_on_lying)
		changed++
		ntransform.TurnTo(lying_prev , lying)
		if(!lying) //Lying to standing
			final_pixel_y = get_standard_pixel_y_offset()
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				pixel_y = get_standard_pixel_y_offset()
				final_pixel_y = get_standard_pixel_y_offset(lying)
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 0.2 SECONDS, pixel_y = final_pixel_y, dir = final_dir, easing = EASE_IN|EASE_OUT)
		setMovetype(movement_type & ~FLOATING)  // If we were without gravity, the bouncing animation got stopped, so we make sure we restart it in next life().

/mob/living/carbon
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/proc/apply_overlay(cache_index)
	if((. = overlays_standing[cache_index]))
		add_overlay(.)

/mob/living/carbon/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		cut_overlay(I)
		overlays_standing[cache_index] = null

/mob/living/carbon/regenerate_icons()
	if(notransform)
		return 1
	update_inv_hands()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_fire()


/mob/living/carbon/update_inv_hands()
	. = ..()
	remove_overlay(HANDS_LAYER)
	if (handcuffed)
		drop_all_held_items()
		return

	var/list/hands = list()
	for(var/obj/item/I in held_items)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			I.screen_loc = ui_hand_position(get_held_index_of_item(I))
			client.screen += I
			if(observers && observers.len)
				for(var/M in observers)
					var/mob/dead/observe = M
					if(observe.client && observe.client.eye == src)
						observe.client.screen += I
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break

		var/t_state = I.item_state
		if(!t_state)
			t_state = I.icon_state

		var/icon_file = I.lefthand_file
		if(get_held_index_of_item(I) % 2 == 0)
			icon_file = I.righthand_file

		hands += I.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)

	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_LAYER)
	
/mob/living/carbon/update_fire_overlay(stacks, on_fire, last_icon_state, suffix = "")
	var/fire_icon = "[dna?.species.fire_overlay || "human"]_[stacks > MOB_BIG_FIRE_STACK_THRESHOLD ? "big_fire" : "small_fire"][suffix]"

	if(!GLOB.fire_appearances[fire_icon])
		GLOB.fire_appearances[fire_icon] = mutable_appearance('icons/mob/effects/onfire.dmi', fire_icon, -FIRE_LAYER, appearance_flags = RESET_COLOR)

	if((stacks > 0 && on_fire))
		if(fire_icon == last_icon_state)
			return last_icon_state

		remove_overlay(FIRE_LAYER)
		overlays_standing[FIRE_LAYER] = GLOB.fire_appearances[fire_icon]
		apply_overlay(FIRE_LAYER)
		return fire_icon

	if(!last_icon_state)
		return last_icon_state

	remove_overlay(FIRE_LAYER)
	apply_overlay(FIRE_LAYER)
	return null

/mob/living/carbon/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/mutable_appearance/damage_overlay = mutable_appearance('icons/mob/dam_mob.dmi', "blank", -DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER] = damage_overlay

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.dmg_overlay_type)
			if(BP.brutestate)
				var/image/brute_overlay = image('icons/mob/dam_mob.dmi', "[BP.dmg_overlay_type]_[BP.body_zone]_[BP.brutestate]0")
				if(BP.use_damage_color)
					brute_overlay.color = BP.damage_color
				damage_overlay.add_overlay(brute_overlay)
			if(BP.burnstate)
				damage_overlay.add_overlay("[BP.dmg_overlay_type]_[BP.body_zone]_0[BP.burnstate]")

	apply_overlay(DAMAGE_LAYER)


/mob/living/carbon/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(wear_mask)
		if(!(ITEM_SLOT_MASK in check_obscured_slots()))
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/clothing/mask/mask.dmi')
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/update_inv_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(wear_neck)
		if(!(ITEM_SLOT_NECK in check_obscured_slots()))
			overlays_standing[NECK_LAYER] = wear_neck.build_worn_icon(default_layer = NECK_LAYER, default_icon_file = 'icons/mob/clothing/neck/neck.dmi')
		update_hud_neck(wear_neck)

	apply_overlay(NECK_LAYER)

/mob/living/carbon/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(back)
		overlays_standing[BACK_LAYER] = back.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = 'icons/mob/clothing/back.dmi')
		update_hud_back(back)

	apply_overlay(BACK_LAYER)

/mob/living/carbon/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(head)
		overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/head.dmi')
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		var/mutable_appearance/cuffs = mutable_appearance('icons/mob/restraints.dmi', handcuffed.item_state, -HANDCUFF_LAYER)
		cuffs.color = handcuffed.color

		overlays_standing[HANDCUFF_LAYER] = cuffs
		apply_overlay(HANDCUFF_LAYER)

/mob/living/carbon/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	clear_alert("legcuffed")
	if(legcuffed)
		var/mutable_appearance/legcuffs = mutable_appearance('icons/mob/restraints.dmi', legcuffed.item_state, -LEGCUFF_LAYER)
		legcuffs.color = legcuffed.color

		overlays_standing[LEGCUFF_LAYER] = legcuffs
		apply_overlay(LEGCUFF_LAYER)
		throw_alert("legcuffed", /atom/movable/screen/alert/restrained/legcuffed, new_master = legcuffed)

//mob HUD updates for items in our inventory

//update whether handcuffs appears on our hud.
/mob/living/carbon/proc/update_hud_handcuffed()
	if(hud_used)
		for(var/hand in hud_used.hand_slots)
			var/atom/movable/screen/inventory/hand/H = hud_used.hand_slots[hand]
			if(H)
				H.update_appearance(UPDATE_ICON)

//update whether our head item appears on our hud.
/mob/living/carbon/proc/update_hud_head(obj/item/I)
	return

//update whether our mask item appears on our hud.
/mob/living/carbon/proc/update_hud_wear_mask(obj/item/I)
	return

//update whether our neck item appears on our hud.
/mob/living/carbon/proc/update_hud_neck(obj/item/I)
	return

//update whether our back item appears on our hud.
/mob/living/carbon/proc/update_hud_back(obj/item/I)
	return



//Overlays for the worn overlay so you can overlay while you overlay
//eg: ammo counters, primed grenade flashing, etc.
//"icon_file" is used automatically for inhands etc. to make sure it gets the right inhand file
/obj/item/proc/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	SEND_SIGNAL(src, COMSIG_ITEM_GET_WORN_OVERLAYS, ., standing, isinhands, icon_file)

/mob/living/carbon/proc/assign_bodypart_ownership()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		BP.original_owner = src

/mob/living/carbon/update_body()
	update_body_parts()

/mob/living/carbon/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	update_z_overlays(GET_TURF_PLANE_OFFSET(new_turf), TRUE)

/mob/living/carbon/proc/refresh_loop(iter_cnt, rebuild = FALSE)
	for(var/i in 1 to iter_cnt)
		update_z_overlays(1, rebuild)
		sleep(0.3 SECONDS)
		update_z_overlays(0, rebuild)
		sleep(0.3 SECONDS)

#define NEXT_PARENT_COMMAND "next_parent"
/// Takes a list of mutable appearances
/// Returns a list in the form:
/// 1 - a list of all mutable appearances that would need to be updated to change planes in the event of a z layer change, alnongside the commands required
/// 	to properly track parents to update
/// 2 - a list of all parents that will require updating
/proc/build_planeed_apperance_queue(list/mutable_appearance/appearances)
	var/list/queue
	if(islist(appearances))
		queue = appearances.Copy()
	else
		queue = list(appearances)
	var/queue_index = 0
	var/list/parent_queue = list()

	// We are essentially going to unroll apperance overlays into a flattened list here, so we can filter out floating planes laster
	// It will look like "overlay overlay overlay (change overlay parent), overlay overlay etc"
	// We can use this list to dynamically update these non floating planes, later
	while(queue_index < length(queue))
		queue_index++
		// If it's not a command, we assert that it's an appearance
		var/mutable_appearance/appearance = queue[queue_index]
		if(!appearance || appearance == NEXT_PARENT_COMMAND) // Who fucking adds nulls to their sublists god you people are the worst
			continue

		var/mutable_appearance/new_appearance = new /mutable_appearance()
		new_appearance.appearance = appearance
		// Now check its children
		if(length(appearance.overlays))
			queue += NEXT_PARENT_COMMAND
			parent_queue += appearance
			for(var/mutable_appearance/child_appearance as anything in appearance.overlays)
				queue += child_appearance

	// Now we have a flattened list of parents and their children
	// Setup such that walking the list backwards will allow us to properly update overlays
	// (keeping in mind that overlays only update if an apperance is removed and added, and this pattern applies in a nested fashion)

	// If we found no results, return null
	if(!length(queue))
		return null

	// ALRIGHT MOTHERFUCKER
	// SO
	// DID YOU KNOW THAT OVERLAY RENDERING BEHAVIOR DEPENDS PARTIALLY ON THE ORDER IN WHICH OVERLAYS ARE ADDED?
	// WHAT WE'RE DOING HERE ENDS UP REVERSING THE OVERLAYS ADDITION ORDER (when it's walked back to front)
	// SO GUESS WHAT I'VE GOTTA DO, I'VE GOTTA SWAP ALLLL THE MEMBERS OF THE SUBLISTS
	// I HATE IT HERE
	var/lower_parent = 0
	var/upper_parent = 0
	var/queue_size = length(queue)
	while(lower_parent <= queue_size)
		// Let's reorder our "lists" (spaces between parent changes)
		// We've got a delta index, and we're gonna essentially use it to get "swap" positions from the top and bottom
		// We only need to loop over half the deltas to swap all the entries, any more and it'd be redundant
		// We floor so as to avoid over flipping, and ending up flipping "back" a delta
		// etc etc
		var/target = FLOOR((upper_parent - lower_parent) / 2, 1)
		for(var/delta_index in 1 to target)
			var/old_lower = queue[lower_parent + delta_index]
			queue[lower_parent + delta_index] = queue[upper_parent - delta_index]
			queue[upper_parent - delta_index] = old_lower

		// lower bound moves to the old upper, upper bound finds a new home
		// Note that the end of the list is a valid upper bound
		lower_parent = upper_parent // our old upper bound is now our lower bound
		while(upper_parent <= queue_size)
			upper_parent += 1
			if(length(queue) < upper_parent) // Parent found
				break
			if(queue[upper_parent] == NEXT_PARENT_COMMAND) // We found em lads
				break

	// One more thing to do
	// It's much more convinient for the parent queue to be a list of indexes pointing at queue locations
	// Rather then a list of copied appearances
	// Let's turn what we have now into that yeah?
	// This'll require a loop over both queues
	// We're using an assoc list here rather then several find()s because I feel like that's more sane
	var/list/apperance_to_position = list()
	for(var/i in 1 to length(queue))
		apperance_to_position[queue[i]] = i

	var/list/parent_indexes = list()
	for(var/mutable_appearance/parent as anything in parent_queue)
		parent_indexes += apperance_to_position[parent]

	// Alright. We should now have two queues, a command/appearances one, and a parents queue, which contain no fluff
	// And when walked backwards allow for proper plane updating
	var/list/return_pack = list(queue, parent_indexes)
	return return_pack

// Rebuilding is a hack. We should really store a list of indexes into our existing overlay list or SOMETHING
// IDK. will work for now though, which is a lot better then not working at all
/mob/living/carbon/proc/update_z_overlays(new_offset, rebuild = FALSE)
	// Null entries will be filtered here
	for(var/i in 1 to length(overlays_standing))
		var/list/cache_grouping = overlays_standing[i]
		if(cache_grouping && !islist(cache_grouping))
			cache_grouping = list(cache_grouping)
		// Need this so we can have an index, could build index into the list if we need to tho, check
		if(!length(cache_grouping))
			continue
		overlays_standing[i] = update_appearance_planes(cache_grouping, new_offset)

/atom/proc/update_appearance_planes(list/mutable_appearance/appearances, new_offset)
	var/list/build_list = build_planeed_apperance_queue(appearances)

	if(!length(build_list))
		return appearances

	// hand_back contains a new copy of the passed in list, with updated values
	var/list/hand_back = list()

	var/list/processing_queue = build_list[1]
	var/list/parents_queue = build_list[2]
	// Now that we have our queues, we're going to walk them forwards to remove, and backwards to add
	// Note, we need to do this separately because you can only remove a mutable appearance when it
	// Exactly matches the appearance it had when it was first "made static" (by being added to the overlays list)
	var/parents_index = 0
	for(var/item in processing_queue)
		if(item == NEXT_PARENT_COMMAND)
			parents_index++
			continue
		var/mutable_appearance/iter_apper = item
		if(parents_index)
			var/parent_src_index = parents_queue[parents_index]
			var/mutable_appearance/parent = processing_queue[parent_src_index]
			parent.overlays -= iter_apper.appearance
		else // Otherwise, we're at the end of the list, and our parent is the mob
			cut_overlay(iter_apper)

	// Now the back to front stuff, to readd the updated appearances
	var/queue_index = length(processing_queue)
	parents_index = length(parents_queue)
	while(queue_index >= 1)
		var/item = processing_queue[queue_index]
		if(item == NEXT_PARENT_COMMAND)
			parents_index--
			queue_index--
			continue
		var/mutable_appearance/new_iter = new /mutable_appearance()
		new_iter.appearance = item
		if(new_iter.plane != FLOAT_PLANE)
			// Here, finally, is where we actually update the plane offsets
			SET_PLANE_W_SCALAR(new_iter, PLANE_TO_TRUE(new_iter.plane), new_offset)
		if(parents_index)
			var/parent_src_index = parents_queue[parents_index]
			var/mutable_appearance/parent = processing_queue[parent_src_index]
			parent.overlays += new_iter.appearance
		else
			add_overlay(new_iter)
			// chant a protective overlays.Copy to prevent appearance theft and overlay sticking
			// I'm not joking without this overlays can corrupt and be replaced by other appearances
			// the compiler might call it useless but I swear it works
			// we conjure the spirits of the computer with our spells, we conjur- (Hey lemon make a damn issue report already)
			var/list/does_nothing = new_iter.overlays.Copy()
			pass(does_nothing)
			hand_back += new_iter

		queue_index--
	return hand_back

#undef NEXT_PARENT_COMMAND

/mob/living/carbon/proc/update_body_parts()
	//CHECK FOR UPDATE
	var/oldkey = icon_render_key
	icon_render_key = generate_icon_render_key()
	if(oldkey == icon_render_key)
		return

	remove_overlay(BODYPARTS_LAYER)

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		BP.update_limb()

	//LOAD ICONS
	if(limb_icon_cache[icon_render_key])
		load_limb_from_cache()
		return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		new_limbs += BP.get_limb_icon()
	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs
		limb_icon_cache[icon_render_key] = new_limbs

	apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()



/////////////////////
// Limb Icon Cache //
/////////////////////
/*
	Called from update_body_parts() these procs handle the limb icon cache.
	the limb icon cache adds an icon_render_key to a human mob, it represents:
	- skin_tone (if applicable)
	- gender
	- limbs (stores as the limb name and whether it is removed/fine, organic/robotic)
	These procs only store limbs as to increase the number of matching icon_render_keys
	This cache exists because drawing 6/7 icons for humans constantly is quite a waste
	See RemieRichards on irc.rizon.net #coderbus
*/

//produces a key based on the mob's limbs

/mob/living/carbon/proc/generate_icon_render_key()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += "-[BP.body_zone]"
		if(BP.use_digitigrade)
			. += "-digitigrade[BP.use_digitigrade]"
		if(BP.animal_origin)
			. += "-[BP.animal_origin]"
		if(BP.status == BODYPART_ORGANIC)
			. += "-organic"
		else
			. += "-robotic"

	if(HAS_TRAIT(src, TRAIT_HUSK))
		. += "-husk"


//change the mob's icon to the one matching its key
/mob/living/carbon/proc/load_limb_from_cache()
	if(limb_icon_cache[icon_render_key])
		remove_overlay(BODYPARTS_LAYER)
		overlays_standing[BODYPARTS_LAYER] = limb_icon_cache[icon_render_key]
		apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()
