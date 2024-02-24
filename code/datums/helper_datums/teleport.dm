/**
  * Teleport an atom
  *
  * Teleports a atom to a destination along with being able to randomly teleport them
  * You can also control the effects, such as sound, and sparks
  * Arguments:
  * * teleatom - The atom to teleport
  * * destination - Destination of the atom
  * * percision - How precise is the teleport, 0(default) is the most precise
  * * effectin - effect to spawn before teleportation
  * * effectout - effect to show right after teleportation
  * * asoundin - soundfile to play before teleportation
  * * asoundout - soundfile to play after teleportation
  * * forceMove - if false, teleport will use Move() proc (dense objects will prevent teleportation)
  * * no_effects - disable the default effectin/effectout of sparks
  * * forced - whether or not to ignore no_teleport
  */
/proc/do_teleport(atom/movable/teleatom, atom/destination, precision=null, forceMove = TRUE, datum/effect_system/effectin=null, datum/effect_system/effectout=null, asoundin=null, asoundout=null, no_effects=FALSE, channel=TELEPORT_CHANNEL_BLUESPACE, forced = FALSE)
	// teleporting most effects just deletes them
	var/static/list/delete_atoms = typecacheof(list(
		/obj/effect,
		)) - typecacheof(list(
		/obj/effect/dummy/chameleon,
		/obj/effect/wisp,
		/obj/effect/mob_spawn,
		))
	if(delete_atoms[teleatom.type])
		qdel(teleatom)
		return FALSE

	// argument handling
	// if the precision is not specified, default to 0, but apply BoH penalties
	if (isnull(precision))
		precision = 0

	switch(channel)
		if(TELEPORT_CHANNEL_BLUESPACE)
			if(istype(teleatom, /obj/item/storage/backpack/holding))
				precision = rand(1,100)

			var/static/list/bag_cache = typecacheof(/obj/item/storage/backpack/holding)
			var/list/bagholding = typecache_filter_list(teleatom.get_all_contents(), bag_cache)
			if(bagholding.len)
				precision = max(rand(1,100)*bagholding.len,100)
				if(isliving(teleatom))
					var/mob/living/MM = teleatom
					to_chat(MM, span_warning("The bluespace interface on your bag of holding interferes with the teleport!"))
					MM.adjust_disgust(20+(precision/10))	//20-30 disgust, pretty nasty
					MM.adjust_confusion(10 + precision/20)		//10-15 confusion, little wobbly

			// if effects are not specified and not explicitly disabled, sparks
			if ((!effectin || !effectout) && !no_effects)
				var/datum/effect_system/spark_spread/sparks = new
				sparks.set_up(5, 1, teleatom)
				if (!effectin)
					effectin = sparks
				if (!effectout)
					effectout = sparks
		if(TELEPORT_CHANNEL_QUANTUM)
			// if effects are not specified and not explicitly disabled, rainbow sparks
			if ((!effectin || !effectout) && !no_effects)
				var/datum/effect_system/spark_spread/quantum/sparks = new
				sparks.set_up(5, 1, teleatom)
				if (!effectin)
					effectin = sparks
				if (!effectout)
					effectout = sparks

	// perform the teleport
	var/turf/curturf = get_turf(teleatom)
	var/turf/destturf = get_teleport_turf(get_turf(destination), precision)

	if(!destturf || !curturf || destturf.is_transition_turf())
		return FALSE

	if(!forced)
		if(!check_teleport_valid(teleatom, destination, channel))
			teleatom.balloon_alert(teleatom, "something holds you back!")
			return FALSE

	if(isobserver(teleatom))
		teleatom.abstract_move(destturf)
		return TRUE

	tele_play_specials(teleatom, curturf, effectin, asoundin)
	var/success = forceMove ? teleatom.forceMove(destturf) : teleatom.Move(destturf)
	if (success)
		log_game("[key_name(teleatom)] has teleported from [loc_name(curturf)] to [loc_name(destturf)]")
		tele_play_specials(teleatom, destturf, effectout, asoundout)
		if(ismegafauna(teleatom))
			message_admins("[teleatom] [ADMIN_FLW(teleatom)] has teleported from [ADMIN_VERBOSEJMP(curturf)] to [ADMIN_VERBOSEJMP(destturf)].")

	if(ismob(teleatom))
		var/mob/M = teleatom
		M.cancel_camera()

	SEND_SIGNAL(teleatom, COMSIG_MOVABLE_POST_TELEPORT)

	return TRUE

/**
  * Plays the effects/sound set in do_teleport
  *
  * Plays the effects/sound set in do_teleport
  * Arguments:
  * * teleatom - used to check if they exist
  * * location - location of the effect/sound to play
  * * effect - effect to spawn
  * * sound - sound to play
  */
/proc/tele_play_specials(atom/movable/teleatom, atom/location, datum/effect_system/effect, sound)
	if (location && !isobserver(teleatom))
		if (sound)
			playsound(location, sound, 60, 1)
		if (effect)
			effect.attach(location)
			effect.start()

/**
  * Finds a safe turf on a given Z level
  *
  * Finds a safe turf on a given Z level and has safety checks
  * Arguments:
  * * zlevel - Z-level to check for a safe turf
  * * zlevels - list of z-levels to check for a safe turf
  * * extended_safety_checks - check for lava
  */
/proc/find_safe_turf(zlevel, list/zlevels, extended_safety_checks = FALSE, dense_atoms = TRUE)
	if(!zlevels)
		if (zlevel)
			zlevels = list(zlevel)
		else
			zlevels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	var/cycles = 1000
	for(var/cycle in 1 to cycles)
		// DRUNK DIALLING WOOOOOOOOO
		var/x = rand(1, world.maxx)
		var/y = rand(1, world.maxy)
		var/z = pick(zlevels)
		var/random_location = locate(x,y,z)
		
		if(istype(get_area(random_location), /area/mine/laborcamp))
			continue
		if(!isfloorturf(random_location))
			continue
		var/turf/open/floor/F = random_location
		if(!F.air)
			continue

		var/datum/gas_mixture/A = F.air
		var/trace_gases
		for(var/id in A.get_gases())
			if(id in GLOB.hardcoded_gases)
				continue
			trace_gases = TRUE
			break

		// Can most things breathe?
		if(trace_gases)
			continue
		if(A.get_moles(GAS_O2) < 16)
			continue
		if(A.get_moles(GAS_PLASMA))
			continue
		if(A.get_moles(GAS_CO2) >= 10)
			continue

		// Aim for goldilocks temperatures and pressure
		if((A.return_temperature() <= 270) || (A.return_temperature() >= 360))
			continue
		var/pressure = A.return_pressure()
		if((pressure <= 20) || (pressure >= 550))
			continue

		if(extended_safety_checks)
			if(islava(F)) //chasms aren't /floor, and so are pre-filtered
				var/turf/open/lava/L = F
				if(!L.is_safe())
					continue
					
		// Check that we're not warping onto a table or window
		if(!dense_atoms)
			var/density_found = FALSE
			for(var/atom/movable/found_movable in F)
				if(found_movable.density)
					density_found = TRUE
					break
			if(density_found)
				continue

		// DING! You have passed the gauntlet, and are "probably" safe.
		return F

/proc/get_teleport_turfs(turf/center, precision = 0)
	if(is_centcom_level(center.z))
		precision = 0
	if(!precision)
		return list(center)
	var/list/posturfs = list()
	for(var/turf/T in range(precision,center))
		if(T.is_transition_turf())
			continue // Avoid picking these.
		var/area/A = T.loc
		if(!A.noteleport)
			posturfs.Add(T)
	return posturfs

/proc/get_teleport_turf(turf/center, precision = 0)
	return safepick(get_teleport_turfs(center, precision))

/// Validates that the teleport being attempted is valid or not
/proc/check_teleport_valid(atom/teleported_atom, atom/destination, channel)
	var/area/origin_area = get_area(teleported_atom)
	var/turf/origin_turf = get_turf(teleported_atom)

	var/area/destination_area = get_area(destination)
	var/turf/destination_turf = get_turf(destination)

	if(HAS_TRAIT(teleported_atom, TRAIT_NO_TELEPORT))
		return FALSE

	if((origin_area.area_flags & NOTELEPORT) || (destination_area.area_flags & NOTELEPORT))
		return FALSE

	if(SEND_SIGNAL(teleported_atom, COMSIG_MOVABLE_TELEPORTING, destination, channel) & COMPONENT_BLOCK_TELEPORT)
		return FALSE

	if(SEND_SIGNAL(destination_turf, COMSIG_ATOM_INTERCEPT_TELEPORTING, channel, origin_turf, destination_turf) & COMPONENT_BLOCK_TELEPORT)
		return FALSE

	SEND_SIGNAL(teleported_atom, COMSIG_MOVABLE_TELEPORTED, destination, channel)
	SEND_SIGNAL(destination_turf, COMSIG_ATOM_INTERCEPT_TELEPORTED, channel, origin_turf, destination_turf)

	return TRUE
