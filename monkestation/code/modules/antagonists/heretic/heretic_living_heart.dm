/datum/action/cooldown/track_target/Activate(atom/target)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(owner)
	var/datum/heretic_knowledge/sac_knowledge = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!LAZYLEN(heretic_datum.current_sac_targets))
		owner.balloon_alert(owner, "no targets, visit a rune!")
		StartCooldown(1 SECONDS)
		return TRUE

	var/list/targets_to_choose = list()
	var/list/mob/living/living_targets = list()
	for(var/datum/weakref/target_ref as anything in heretic_datum.current_sac_targets)
		var/datum/mind/target_mind = target_ref?.resolve()
		if(QDELETED(target_mind))
			continue
		var/mob/living/living_target = target_mind.current
		if(QDELETED(living_target))
			continue
		var/sac_name = trimtext(target_mind.name || living_target.real_name || living_target.name)
		living_targets[sac_name] = living_target
		var/mutable_appearance/target_appearance = new(living_target)
		target_appearance.appearance_flags = KEEP_TOGETHER
		target_appearance.layer = FLOAT_LAYER
		target_appearance.plane = FLOAT_PLANE
		target_appearance.dir = SOUTH
		target_appearance.pixel_x = living_target.base_pixel_x
		target_appearance.pixel_y = living_target.base_pixel_y
		target_appearance.pixel_z = 0 /* living_target.base_pixel_z */
		targets_to_choose[sac_name] = strip_appearance_underlays(target_appearance)

	// If we don't have a last tracked name, open a radial to set one.
	// If we DO have a last tracked name, we skip the radial if they right click the action.
	if(isnull(last_tracked_name) || !right_clicked)
		radial_open = TRUE
		last_tracked_name = show_radial_menu(
			owner,
			owner,
			targets_to_choose,
			custom_check = CALLBACK(src, PROC_REF(check_menu)),
			radius = 40,
			require_near = TRUE,
			tooltips = TRUE,
		)
		radial_open = FALSE

	// If our last tracked name is still null, skip the trigger
	if(isnull(last_tracked_name))
		return FALSE

	var/mob/living/tracked_mob = living_targets[last_tracked_name]
	if(QDELETED(tracked_mob))
		last_tracked_name = null
		return FALSE

	playsound(owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	owner.balloon_alert(owner, get_balloon_message(tracked_mob))

	// Let them know how to sacrifice people if they're able to be sac'd
	if(tracked_mob.stat == DEAD)
		to_chat(owner, span_hierophant("[tracked_mob] is dead. Bring them to a transmutation rune \
			and invoke \"[sac_knowledge.name]\" to sacrifice them!"))

	StartCooldown()
	return TRUE

/// Gets the balloon message for who we're tracking.
/datum/action/cooldown/track_target/proc/get_balloon_message(mob/living/tracked_mob)
	var/balloon_message = "error text!"
	var/turf/their_turf = get_turf(tracked_mob)
	var/turf/our_turf = get_turf(owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

	var/is_alone = TRUE
	for(var/mob/living/watcher in view(7, tracked_mob))
		if(QDELETED(watcher.client) || watcher == tracked_mob)
			continue
		if(IS_HERETIC_OR_MONSTER(watcher) || (watcher.mind?.enslaved_to?.resolve() == owner) || HAS_TRAIT(watcher, TRAIT_GHOST_CRITTER))
			continue
		if(watcher.stat == DEAD || watcher.is_blind())
			continue
		is_alone = FALSE
		break

	// One of us is in somewhere we shouldn't be
	if(!our_z || !their_z)
		// "Hell if I know"
		balloon_message = "on another plane!"

	// They're not on the same z-level as us
	else if(our_z != their_z)
		// They're on the station
		if(is_station_level(their_z))
			// We're on a multi-z station
			if(is_station_level(our_z))
				if(our_z > their_z)
					balloon_message = "below you!"
				else
					balloon_message = "above you!"
			// We're off station, they're not
			else
				balloon_message = "on station!"

		// Mining
		else if(is_mining_level(their_z))
			balloon_message = "on lavaland!"

		// In the gateway
		else if(is_away_level(their_z) || is_secret_level(their_z))
			balloon_message = "beyond the gateway!"

		// On a shuttle
		else if(is_reserved_level(their_z) && istype(get_area(their_turf), /area/shuttle))
			balloon_message = "on a shuttle!"

		// They're somewhere we probably can't get too - sacrifice z-level, centcom, etc
		else
			balloon_message = "on another plane!"

	// They're on the same z-level as us!
	else
		var/dist = get_dist(our_turf, their_turf)
		var/dir = get_dir(our_turf, their_turf)

		switch(dist)
			if(0 to 15)
				balloon_message = "very near, [dir2text(dir)]!"
			if(16 to 31)
				balloon_message = "near, [dir2text(dir)]!"
			if(32 to 127)
				balloon_message = "far, [dir2text(dir)]!"
			else
				balloon_message = "very far!"

	if(tracked_mob.stat == DEAD || isbrain(tracked_mob))
		balloon_message = "they're dead, " + balloon_message
	else if(is_alone)
		balloon_message = "they're alone, " + balloon_message

	return balloon_message
