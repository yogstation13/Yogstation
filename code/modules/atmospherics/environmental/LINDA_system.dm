/atom
	///Check if atmos can pass in this atom (ATMOS_PASS_YES, ATMOS_PASS_NO, ATMOS_PASS_DENSITY, ATMOS_PASS_PROC)
	var/CanAtmosPass = ATMOS_PASS_YES

/atom/proc/CanAtmosPass(turf/T, vertical = FALSE)
	switch (CanAtmosPass)
		if (ATMOS_PASS_PROC)
			return ATMOS_PASS_YES
		if (ATMOS_PASS_DENSITY)
			return !density
		else
			return CanAtmosPass

/turf
	CanAtmosPass = ATMOS_PASS_NO

/turf/open
	CanAtmosPass = ATMOS_PASS_PROC

///Do NOT use this to see if 2 turfs are connected, it mutates state, and we cache that info anyhow.
///Use TURFS_CAN_SHARE or TURF_SHARES depending on your usecase
/turf/open/CanAtmosPass(turf/target_turf, vertical = FALSE)
	var/can_pass = TRUE
	var/direction = vertical? get_dir_multiz(src, target_turf) : get_dir(src, target_turf)
	var/opposite_direction = dir_inverse_multiz(direction)
	if(vertical && !(zAirOut(direction, target_turf) && target_turf.zAirIn(direction, src)))
		can_pass = FALSE
	if(blocks_air || target_turf.blocks_air)
		can_pass = FALSE
	//This path is a bit weird, if we're just checking with ourselves no sense asking objects on the turf
	if (target_turf == src)
		return can_pass

	//Can't just return if canpass is false here, we need to set superconductivity
	for(var/obj/checked_object in contents + target_turf.contents)
		var/turf/other = (checked_object.loc == src ? target_turf : src)
		if(CANATMOSPASS(checked_object, other, vertical))
			continue
		can_pass = FALSE
		//the direction and open/closed are already checked on can_atmos_pass() so there are no arguments
		if(checked_object.BlockSuperconductivity())
			atmos_supeconductivity |= direction
			target_turf.atmos_supeconductivity |= opposite_direction
			return FALSE //no need to keep going, we got all we asked (Is this even faster? fuck you it's soul)

	//Superconductivity is a bitfield of directions we can't conduct with
	//Yes this is really weird. Fuck you
	atmos_supeconductivity &= ~direction
	target_turf.atmos_supeconductivity &= ~opposite_direction

	return can_pass

/atom/movable/proc/BlockSuperconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return FALSE

/// This proc is a more deeply optimized version of immediate_calculate_adjacent_turfs
/// It contains dumbshit, and also stuff I just can't do at runtime
/// If you're not editing behavior, just read that proc. It's less bad
/turf/proc/init_immediate_calculate_adjacent_turfs()
	//Basic optimization, if we can't share why bother asking other people ya feel?
	// You know it's gonna be stupid when they include a unit test in the atmos code
	// Yes, inlining the string concat does save 0.1 seconds
	#ifdef UNIT_TESTS
	ASSERT(UP == 16)
	ASSERT(DOWN == 32)
	#endif
	LAZYINITLIST(src.atmos_adjacent_turfs)
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs
	var/canpass = CANATMOSPASS(src, src, FALSE)
	for(var/direction in GLOB.cardinals_multiz)
		// Yes this is a reimplementation of get_step_mutliz. It's faster tho. fuck you
		// Oh also yes UP and DOWN do just point to +1 and -1 and not z offsets
		// Multiz is shitcode welcome home
		var/turf/current_turf = get_step_multiz(src, direction)
		if(!isopenturf(current_turf)) // not interested in you brother
			continue
		// The assumption is that ONLY DURING INIT if two tiles have the same cycle, there's no way canpass(a->b) will be different then canpass(b->a), so this is faster
		// Saves like 1.2 seconds
		// Note: current cycle here goes DOWN as we sleep. this is to ensure we can use the >= logic in the first step of process_cell
		// It's not a massive thing, and I'm sorry for the cursed code, but it be this way
		if(current_turf.current_cycle <= current_cycle)
			continue

		//Can you and me form a deeper relationship, or is this just a passing wind
		// (direction & (UP | DOWN)) is just "is this vertical" by the by
		if(canpass && CANATMOSPASS(current_turf, src, (direction & (UP|DOWN))) && !(blocks_air || current_turf.blocks_air))
			LAZYINITLIST(current_turf.atmos_adjacent_turfs)
			atmos_adjacent_turfs[current_turf] = direction
			var/opp_dir = dir_inverse_multiz(direction)
			current_turf.atmos_adjacent_turfs[src] = opp_dir
			current_turf.__update_extools_adjacent_turfs()
		else
			atmos_adjacent_turfs -= current_turf
			if (current_turf.atmos_adjacent_turfs)
				current_turf.atmos_adjacent_turfs -= src
				current_turf.__update_extools_adjacent_turfs()
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)

	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs
	__update_extools_adjacent_turfs()

/turf/proc/immediate_calculate_adjacent_turfs()
	LAZYINITLIST(src.atmos_adjacent_turfs)
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs
	var/canpass = CANATMOSPASS(src, src, FALSE)
	for(var/direction in GLOB.cardinals_multiz)
		var/turf/current_turf = get_step_multiz(src, direction)
		if(!isopenturf(current_turf)) // not interested in you brother
			continue

		//Can you and me form a deeper relationship, or is this just a passing wind
		// (direction & (UP | DOWN)) is just "is this vertical" by the by
		if(canpass && CANATMOSPASS(current_turf, src, (direction & (UP|DOWN))) && !(blocks_air || current_turf.blocks_air))
			LAZYINITLIST(current_turf.atmos_adjacent_turfs)
			atmos_adjacent_turfs[current_turf] = direction
			var/opp_dir = dir_inverse_multiz(direction)
			current_turf.atmos_adjacent_turfs[src] = opp_dir
			current_turf.__update_extools_adjacent_turfs()
		else
			atmos_adjacent_turfs -= current_turf
			if (current_turf.atmos_adjacent_turfs)
				current_turf.atmos_adjacent_turfs -= src
				current_turf.__update_extools_adjacent_turfs()
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)

	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs
	__update_extools_adjacent_turfs()

/turf/proc/__update_extools_adjacent_turfs()


//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = 0)
	var/adjacent_turfs
	if (atmos_adjacent_turfs)
		adjacent_turfs = atmos_adjacent_turfs.Copy()
	else
		adjacent_turfs = list()

	if (!alldir)
		return adjacent_turfs

	var/turf/curloc = src

	for (var/direction in GLOB.diagonals_multiz)
		var/matchingDirections = 0
		var/turf/S = get_step_multiz(curloc, direction)
		if(!S)
			continue

		for (var/checkDirection in GLOB.cardinals_multiz)
			var/turf/checkTurf = get_step(S, checkDirection)
			if(!S.atmos_adjacent_turfs || !S.atmos_adjacent_turfs[checkTurf])
				continue

			if (adjacent_turfs[checkTurf])
				matchingDirections++

			if (matchingDirections >= 2)
				adjacent_turfs += S
				break

	return adjacent_turfs

/atom/proc/air_update_turf(command = 0)
	if(!isturf(loc) && command)
		return
	var/turf/T = get_turf(loc)
	T.air_update_turf(command)

/turf/air_update_turf(command = 0)
	if(command)
		immediate_calculate_adjacent_turfs()
	SSair.add_to_active(src,command)

/atom/movable/proc/move_update_air(turf/T)
    if(isturf(T))
        T.air_update_turf(1)
    air_update_turf(1)

/atom/proc/atmos_spawn_air(text) //because a lot of people loves to copy paste awful code lets just make an easy proc to spawn your plasma fires
	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(text)

/turf/open/atmos_spawn_air(text)
	if(!text || !air)
		return

	var/datum/gas_mixture/turf_mixture = SSair.parse_gas_string(text, /datum/gas_mixture/turf)

	air.merge(turf_mixture)
	archive()
	SSair.add_to_active(src, 0)
