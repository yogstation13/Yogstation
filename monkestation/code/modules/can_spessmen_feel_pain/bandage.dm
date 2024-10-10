/// Gets overlays to apply to the mob when damaged.
/obj/item/bodypart/proc/get_bodypart_damage_state()
	if(!dmg_overlay_type)
		return

	var/list/overlays
	if(brutestate)
		var/mutable_appearance/brute_overlay = mutable_appearance(
			icon = 'icons/mob/effects/dam_mob.dmi',
			icon_state = "[dmg_overlay_type]_[body_zone]_[brutestate]0",
			layer = -DAMAGE_LAYER,
		)
		brute_overlay.color = damage_color
		LAZYADD(overlays, brute_overlay)
	if(burnstate)
		var/mutable_appearance/burn_overlay = mutable_appearance(
			icon = 'icons/mob/effects/dam_mob.dmi',
			icon_state = "[dmg_overlay_type]_[body_zone]_0[burnstate]",
			layer = -DAMAGE_LAYER,
		)
		LAZYADD(overlays, burn_overlay)
	if(current_gauze)
		var/mutable_appearance/gauze_overlay = current_gauze.build_worn_icon(
			default_layer = DAMAGE_LAYER - 0.1, // proc inverts it for us
			override_file = 'monkestation/icons/mob/bandage.dmi',
			override_state = current_gauze.worn_icon_state, // future todo : icon states for dirty bandages as well
		)
		LAZYADD(overlays, gauze_overlay)
	return overlays

/obj/item/bodypart/leg/get_bodypart_damage_state()
	if(!(bodytype & BODYTYPE_DIGITIGRADE))
		return ..()
	. = ..()
	for(var/mutable_appearance/appearance in .)
		apply_digitigrade_filters(appearance, owner, bodytype)
	return .

/**
 * apply_gauze() is used to- well, apply gauze to a bodypart
 *
 * As of the Wounds 2 PR, all bleeding is now bodypart based rather than the old bleedstacks system, and 90% of standard bleeding comes from flesh wounds (the exception is embedded weapons).
 * The same way bleeding is totaled up by bodyparts, gauze now applies to all wounds on the same part. Thus, having a slash wound, a pierce wound, and a broken bone wound would have the gauze
 * applying blood staunching to the first two wounds, while also acting as a sling for the third one. Once enough blood has been absorbed or all wounds with the ACCEPTS_GAUZE flag have been cleared,
 * the gauze falls off.
 *
 * Arguments:
 * * gauze- Just the gauze stack we're taking a sheet from to apply here
 */
/obj/item/bodypart/proc/apply_gauze(obj/item/stack/medical/gauze/new_gauze)
	if(!istype(new_gauze) || !new_gauze.absorption_capacity || !new_gauze.use(1))
		return
	if(!isnull(current_gauze))
		remove_gauze(drop_location())

	current_gauze = new new_gauze.type(src, 1)
	current_gauze.worn_icon_state = "[body_zone][rand(1, 3)]"
	if(can_bleed() && (generic_bleedstacks || cached_bleed_rate))
		current_gauze.add_mob_blood(owner)
		if(!QDELETED(new_gauze))
			new_gauze.add_mob_blood(owner)
	SEND_SIGNAL(src, COMSIG_BODYPART_GAUZED, current_gauze, new_gauze)
	owner.update_damage_overlays()

/obj/item/bodypart/proc/remove_gauze(atom/remove_to)
	SEND_SIGNAL(src, COMSIG_BODYPART_UNGAUZED, current_gauze)
	if(remove_to)
		current_gauze.forceMove(remove_to)
	else
		current_gauze.moveToNullspace()
	if(can_bleed() && (generic_bleedstacks || cached_bleed_rate))
		current_gauze.add_mob_blood(owner)
	current_gauze.worn_icon_state = initial(current_gauze.worn_icon_state)
	current_gauze.update_appearance()
	. = current_gauze
	current_gauze = null
	owner.update_damage_overlays()
	return .

/**
 * seep_gauze() is for when a gauze wrapping absorbs blood or pus from wounds, lowering its absorption capacity.
 *
 * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandages falls off and we're left with nothing.
 *
 * Arguments:
 * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
 */
/obj/item/bodypart/proc/seep_gauze(seep_amt = 0)
	if(!current_gauze)
		return
	current_gauze.absorption_capacity -= seep_amt
	current_gauze.update_appearance(UPDATE_NAME)
	if(current_gauze.absorption_capacity > 0)
		return
	owner.visible_message(
		span_danger("[current_gauze] on [owner]'s [name] falls away in rags."),
		span_warning("[current_gauze] on your [name] falls away in rags."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	remove_gauze(drop_location())
	owner.update_damage_overlays()

/**
 * Helper for someone helping to remove our gauze
 */
/obj/item/bodypart/proc/help_remove_gauze(mob/living/helper)
	if(!istype(helper))
		return
	if(helper.incapacitated())
		return
	if(!helper.can_perform_action(owner, NEED_HANDS|FORBID_TELEKINESIS_REACH)) // telekinetic removal can be added later
		return

	var/whose = helper == owner ? "your" : "[owner]'s"
	helper.visible_message(
		span_notice("[helper] starts carefully removing [current_gauze] from [whose] [plaintext_zone]."),
		span_notice("You start carefully removing [current_gauze] from [whose] [plaintext_zone]..."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	helper.balloon_alert(helper, "removing gauze...")
	if(helper != owner)
		helper.balloon_alert(owner, "removing your gauze...")

	if(!do_after(helper, 3 SECONDS, owner))
		return

	if(!current_gauze)
		return

	var/theirs = helper == owner ? helper.p_their() : "[owner]'s"
	helper.visible_message(
		span_notice("[helper] finishes removing [current_gauze] from [theirs] [plaintext_zone]."),
		span_notice("You finish removing [current_gauze] from [theirs] [plaintext_zone]."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)

	helper.balloon_alert(helper, "gauzed removed")
	if(helper != owner)
		helper.balloon_alert(owner, "gauze removed")

	helper.put_in_hands(remove_gauze())

/obj/item/proc/apply_digitigrade_filters(mutable_appearance/appearance, mob/living/carbon/wearer = loc, bodytype)
	if(!istype(wearer) || !(bodytype & BODYTYPE_DIGITIGRADE))
		return

	var/static/list/icon/masks_and_shading
	if(isnull(masks_and_shading))
		masks_and_shading = list(
			"[NORTH]" = list(
				"mask" = icon('icons/effects/digi_filters.dmi', "digi", NORTH),
				"shading" = icon('icons/effects/digi_filters.dmi', "digi_shading", NORTH),
				"size"  = 1,
			),
			"[SOUTH]" = list(
				"mask" = icon('icons/effects/digi_filters.dmi', "digi", SOUTH),
				"shading" = icon('icons/effects/digi_filters.dmi', "digi_shading", SOUTH),
				"size"  = 1,
			),
			"[EAST]" = list(
				"mask" = icon('icons/effects/digi_filters.dmi', "digi", EAST),
				"shading" = icon('icons/effects/digi_filters.dmi', "digi_shading", EAST),
				"size" = 127,
			),
			"[WEST]" = list(
				"mask" = icon('icons/effects/digi_filters.dmi', "digi", WEST),
				"shading" = icon('icons/effects/digi_filters.dmi', "digi_shading", WEST),
				"size" = 127,
			),
		)

	var/dir_to_use = ISDIAGONALDIR(wearer.dir) ? (wearer.dir & (EAST|WEST)) : wearer.dir
	var/icon/icon_to_use = masks_and_shading["[dir_to_use]"]["mask"]
	var/icon/shading_to_use = masks_and_shading["[dir_to_use]"]["shading"]
	var/size = masks_and_shading["[dir_to_use]"]["size"]

	appearance.add_filter("Digitigrade", 1, displacement_map_filter(icon = icon_to_use, size = size))
	appearance.add_filter("Digitigrade_shading", 1, layering_filter(icon = shading_to_use, blend_mode = BLEND_MULTIPLY))
