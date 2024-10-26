
/**
 * Component for clothing items that can pick up blood from decals and spread it around everywhere when walking, such as shoes or suits with integrated shoes.
 */
/datum/component/bloodysoles
	/*
	/// The type of the last grub pool we stepped in, used to decide the type of footprints to make
	var/last_blood_state = BLOOD_STATE_NOT_BLOODY

	/// How much of each grubby type we have on our feet
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	*/ //Monkestation removal: BLOOD_DATUMS

	// Monkestation Addition: BLOOD_DATUMS
	/// What percentage of the bloodiness is deposited on the ground per step
	var/blood_dropped_per_step = 3
	/// Bloodiness on our clothines
	VAR_FINAL/total_bloodiness = 0
	// Monkestation Addition: BLOOD_DATUMS

	/// The ITEM_SLOT_* slot the item is equipped on, if it is.
	var/equipped_slot

	/// Either the mob carrying the item, or the mob itself for the /feet component subtype
	VAR_FINAL/mob/living/carbon/wielder

	/// The world.time when we last picked up blood
	VAR_FINAL/last_pickup

	var/footprint_sprite = FOOTPRINT_SPRITE_SHOES

/datum/component/bloodysoles/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/bloodysoles/Destroy()
	wielder = null
	return ..()

/**
 * Unregisters from the wielder if necessary
 */
/datum/component/bloodysoles/proc/unregister()
	if(!QDELETED(wielder))
		UnregisterSignal(wielder, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(wielder, COMSIG_STEP_ON_BLOOD)
	wielder = null
	equipped_slot = null

/**
 * Returns true if the parent item is obscured by something else that the wielder is wearing
 */
/datum/component/bloodysoles/proc/is_obscured()
	return wielder.check_obscured_slots(TRUE) & equipped_slot

/**
 * Run to update the icon of the parent
 */
/datum/component/bloodysoles/proc/update_icon()
	var/obj/item/parent_item = parent
	parent_item.update_slot_icon()

///called whenever the value of bloody_soles changes
/datum/component/bloodysoles/proc/change_blood_amount(some_amount)
	total_bloodiness = clamp(round(total_bloodiness + some_amount, 0.1), 0, BLOOD_ITEM_MAX)
	if(!wielder)
		return
	if(total_bloodiness <= BLOOD_FOOTPRINTS_MIN * 2)//need twice that amount to make footprints
		UnregisterSignal(wielder, COMSIG_MOVABLE_MOVED)
	else
		RegisterSignal(wielder, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved), override = TRUE)
	update_icon()

/**
 * Run to equally share the blood between us and a decal
 */
/datum/component/bloodysoles/proc/share_blood(obj/effect/decal/cleanable/pool)
	// Share the blood between our boots and the blood pool
	var/new_total_bloodiness = min(BLOOD_ITEM_MAX, pool.bloodiness + total_bloodiness / 2)
	if(new_total_bloodiness == total_bloodiness || new_total_bloodiness == 0)
		return

	var/delta = new_total_bloodiness - total_bloodiness
	pool.adjust_bloodiness(-1 * delta)
	change_blood_amount(delta)

	var/atom/parent_atom = parent
	parent_atom.add_blood_DNA(GET_ATOM_BLOOD_DNA(pool))

/**
 * Adds blood to an existing (or new) footprint
 */
/datum/component/bloodysoles/proc/add_blood_to_footprint(obj/effect/decal/cleanable/blood/footprints/footprint, bloodiness_to_add, exiting = FALSE)
	var/atom/atom_parent = parent
	add_parent_to_footprint(footprint)
	footprint.adjust_bloodiness(bloodiness_to_add)
	footprint.add_blood_DNA(GET_ATOM_BLOOD_DNA(atom_parent))
	if(exiting)
		footprint.exited_dirs |= wielder.dir
	else
		footprint.entered_dirs |= wielder.dir
	footprint.update_appearance()

/**
 * Adds the parent type to the footprint's shoe_types var
 */
/datum/component/bloodysoles/proc/add_parent_to_footprint(obj/effect/decal/cleanable/blood/footprints/footprint)
	footprint.shoe_types |= parent.type

/**
 * Called when the parent item is equipped by someone
 *
 * Used to register our wielder
 */
/datum/component/bloodysoles/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!iscarbon(equipper))
		return
	var/obj/item/parent_item = parent
	if(!(parent_item.slot_flags & slot))
		unregister()
		return

	equipped_slot = slot
	wielder = equipper
	if(total_bloodiness > BLOOD_FOOTPRINTS_MIN * 2)
		RegisterSignal(wielder, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(wielder, COMSIG_STEP_ON_BLOOD, PROC_REF(on_step_blood))

/**
 * Called when the parent item has been dropped
 *
 * Used to deregister our wielder
 */
/datum/component/bloodysoles/proc/on_drop(datum/source, mob/dropper)
	SIGNAL_HANDLER

	unregister()

/**
 * Called when the wielder has moved
 *
 * Used to make bloody footprints on the ground
 */
/datum/component/bloodysoles/proc/on_moved(datum/source, atom/old_loc, Dir, Forced)
	SIGNAL_HANDLER

	if(total_bloodiness <= 0)
		return
	if(QDELETED(wielder) || is_obscured())
		return
	if(wielder.body_position == LYING_DOWN || !wielder.has_gravity(wielder.loc))
		return

	var/atom/parent_atom = parent
	var/blood_used = round(total_bloodiness / 3, 0.01)

	// Add footprints in old loc if we have enough cream
	if(blood_used >= BLOOD_FOOTPRINTS_MIN)
		var/turf/old_loc_turf = get_turf(old_loc)
		var/obj/effect/decal/cleanable/blood/footprints/old_loc_prints = locate() in old_loc_turf
		if(old_loc_prints)
			add_blood_to_footprint(old_loc_prints, 0, TRUE) // Add no actual blood, just update sprite

		else if(locate(/obj/effect/decal/cleanable/blood) in old_loc_turf)
			// No footprints in the tile we left, but there was some other blood pool there. Add exit footprints on it
			change_blood_amount(-1 * blood_used)
			old_loc_prints = new(old_loc_turf)
			if(!QDELETED(old_loc_prints)) // prints merged
				add_blood_to_footprint(old_loc_prints, blood_used, TRUE)

			blood_used = round(total_bloodiness / 3, 0.01)

	// If we picked up the blood on this tick in on_step_blood, don't make footprints at the same place
	if(last_pickup && last_pickup == world.time)
		return

	// Create new footprints
	if(blood_used >= BLOOD_FOOTPRINTS_MIN)
		var/turf/new_loc_turf = get_turf(parent_atom)
		var/obj/effect/decal/cleanable/blood/footprints/new_loc_prints = locate() in new_loc_turf
		if(new_loc_prints)
			add_blood_to_footprint(new_loc_prints, 0, FALSE) // Add no actual blood, just update sprite

		else
			change_blood_amount(-1 * blood_used)
			new_loc_prints = new(new_loc_turf)
			if(!QDELETED(new_loc_prints)) // prints merged
				add_blood_to_footprint(new_loc_prints, blood_used, FALSE)


/**
 * Called when the wielder steps in a pool of blood
 *
 * Used to make the parent item bloody
 */
/datum/component/bloodysoles/proc/on_step_blood(datum/source, obj/effect/decal/cleanable/pool)
	SIGNAL_HANDLER

	if(QDELETED(wielder) || is_obscured() || !wielder.has_gravity(wielder.loc))
		return
	/// The character is agile enough to not mess their clothing and hands just from one blood splatter at floor
	if(HAS_TRAIT(wielder, TRAIT_LIGHT_STEP))
		return
	// Don't share from other feetprints, not super realistic but I think it ruins the effect a bit
	if(istype(pool, /obj/effect/decal/cleanable/blood/footprints))
		return

	share_blood(pool)
	last_pickup = world.time

/**
 * Called when the parent item is being washed
 */
/datum/component/bloodysoles/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if(!(clean_types & CLEAN_TYPE_BLOOD) || total_bloodiness <= 0)
		return NONE

	total_bloodiness = 0
	update_icon()
	return COMPONENT_CLEANED


/**
 * Like its parent but can be applied to carbon mobs instead of clothing items
 */
/datum/component/bloodysoles/feet
	equipped_slot = ITEM_SLOT_FEET
	var/static/mutable_appearance/bloody_feet

/datum/component/bloodysoles/feet/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	wielder = parent
	if(footprint_sprite)
		src.footprint_sprite = footprint_sprite
	if(!bloody_feet)
		bloody_feet = mutable_appearance('icons/effects/blood.dmi', "shoeblood", SHOES_LAYER)

	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_STEP_ON_BLOOD, PROC_REF(on_step_blood))
	RegisterSignal(parent, COMSIG_CARBON_UNEQUIP_SHOECOVER, PROC_REF(unequip_shoecover))
	RegisterSignal(parent, COMSIG_CARBON_EQUIP_SHOECOVER, PROC_REF(equip_shoecover))

/datum/component/bloodysoles/feet/update_icon()
	if(!ishuman(wielder) || HAS_TRAIT(wielder, TRAIT_NO_BLOOD_OVERLAY))
		return
	wielder.remove_overlay(SHOES_LAYER)
	if(total_bloodiness > 0 && !is_obscured())
		bloody_feet.color = wielder.get_blood_dna_color()
		wielder.overlays_standing[SHOES_LAYER] = bloody_feet
		wielder.apply_overlay(SHOES_LAYER)
	else
		wielder.update_worn_shoes()

/datum/component/bloodysoles/feet/add_parent_to_footprint(obj/effect/decal/cleanable/blood/footprints/footprint)
	if(!ishuman(wielder))
		footprint.species_types |= "unknown"
		return

	// Find any leg of our human and add that to the footprint, instead of the default which is to just add the human type
	for(var/obj/item/bodypart/affecting as anything in wielder.bodyparts)
		if(!affecting.bodypart_disabled && (affecting.body_part == LEG_RIGHT || affecting.body_part == LEG_LEFT))
			footprint.species_types |= affecting.limb_id
			break


/datum/component/bloodysoles/feet/is_obscured()
	if(wielder.shoes)
		return TRUE
	return wielder.check_obscured_slots(TRUE) & ITEM_SLOT_FEET

/datum/component/bloodysoles/feet/on_moved(datum/source, OldLoc, Dir, Forced)
	if(wielder.num_legs >= 2)
		return ..()

/datum/component/bloodysoles/feet/on_step_blood(datum/source, obj/effect/decal/cleanable/pool)
	if(wielder.num_legs >= 2)
		return ..()

/datum/component/bloodysoles/feet/proc/unequip_shoecover(datum/source)
	SIGNAL_HANDLER

	update_icon()

/datum/component/bloodysoles/feet/proc/equip_shoecover(datum/source)
	SIGNAL_HANDLER

	update_icon()
