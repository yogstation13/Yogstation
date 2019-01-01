/*
	Adjacency (to turf):
	* If you are in the same turf, always true
	* If you are vertically/horizontally adjacent, ensure there are no border objects
	* If you are diagonally adjacent, ensure you can pass through at least one of the mutually adjacent square.
		* Passing through in this case ignores anything with the LETPASSTHROW pass flag, such as tables, racks, and morgue trays.
*/
/turf/Adjacent(atom/neighbor, atom/target = null, atom/movable/mover = null)
	if(neighbor == src)
		return TRUE //don't be retarded!!

	if(istype(neighbor, /atom/movable)) //fml
		var/atom/movable/AM = neighbor
		if((AM.bound_width != world.icon_size || AM.bound_height != world.icon_size) && (islist(AM.locs) && AM.locs.len > 1))
			for(var/turf/T in AM.locs)
				if(Adjacent(T, target, mover))
					return TRUE
			return FALSE

	var/turf/T0 = get_turf(neighbor)

	if(T0 == src) //same turf
		return TRUE

	if(get_dist(src, T0) > 1 || z != T0.z) //too far
		return FALSE

	// Non diagonal case
	if(T0.x == x || T0.y == y)
		// Check for border blockages
		return T0.ClickCross(get_dir(T0,src), border_only = 1, target_atom = target, mover = mover) && src.ClickCross(get_dir(src,T0), border_only = 1, target_atom = target, mover = mover)

	// Diagonal case
	var/in_dir = get_dir(T0,src) // eg. northwest (1+8) = 9 (00001001)
	var/d1 = in_dir&3		     // eg. north	  (1+8)&3 (0000 0011) = 1 (0000 0001)
	var/d2 = in_dir&12			 // eg. west	  (1+8)&12 (0000 1100) = 8 (0000 1000)

	for(var/d in list(d1,d2))
		if(!T0.ClickCross(d, border_only = 1, target_atom = target, mover = mover))
			continue // could not leave T0 in that direction

		var/turf/T1 = get_step(T0,d)
		if(!T1 || T1.density)
			continue
		if(!T1.ClickCross(get_dir(T1,src), border_only = 0, target_atom = target, mover = mover) || !T1.ClickCross(get_dir(T1,T0), border_only = 0, target_atom = target, mover = mover))
			continue // couldn't enter or couldn't leave T1

		if(!src.ClickCross(get_dir(src,T1), border_only = 1, target_atom = target, mover = mover))
			continue // could not enter src

		return TRUE // we don't care about our own density

	return FALSE

/*
	Adjacency (to anything else):
	* Must be on a turf
*/
/atom/movable/Adjacent(var/atom/neighbor)
	if(neighbor == loc)
		return TRUE
	if(!isturf(loc))
		return FALSE
	if((islist(locs) && locs.len > 1) && (bound_width != world.icon_size || bound_height != world.icon_size))
		for(var/turf/T in locs) //this is to handle multi tile objects
			if(T.Adjacent(neighbor, src, src))
				return TRUE
	else if(loc.Adjacent(neighbor,target = neighbor, mover = src))
		return TRUE
	return FALSE
