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

	return ..()

/*
	Adjacency (to anything else):
	* Must be on a turf
*/
/atom/movable/Adjacent(var/atom/neighbor)
	if(neighbor == loc)
		return TRUE
	var/turf/T = loc
	if(!istype(T))
		return FALSE
	if((islist(locs) && locs.len > 1) && (bound_width != world.icon_size || bound_height != world.icon_size))
		for(var/turf/place in locs) //this is to handle multi tile objects
			if(place.Adjacent(neighbor, src, src))
				return TRUE
	else if(T.Adjacent(neighbor,target = neighbor, mover = src))
		return TRUE
	return FALSE
