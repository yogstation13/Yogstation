/**
 * - is_valid_z_level
 *
 * Checks if source_loc and checking_loc is both on the station, or on the same z level.
 * This is because the station's several levels aren't considered the same z, so multi-z stations need this special case.
 *
 * Args:
 * source_loc - turf of the source we're comparing.
 * checking_loc - turf we are comparing to source_loc.
 *
 * returns TRUE if connection is valid, FALSE otherwise.
 */
/proc/is_valid_z_level(turf/source_loc, turf/checking_loc)
	// if either locs are null, then well, it's not valid, is it?
	if(isnull(source_loc) || isnull(checking_loc))
		return FALSE
	// if we're both on "station", regardless of multi-z, we'll pass by.
	if(is_station_level(source_loc.z) && is_station_level(checking_loc.z))
		return TRUE
	if(source_loc.z == checking_loc.z)
		return TRUE
	return FALSE

/**
 * Gets the angle between two linked z-levels.
 * Returns an angle (in degrees) if the z-levels are crosslinked/neighbors,
 * or null if they are not.
 *
 * Arguments:
 * * start: The starting Z level. Can either be a numeric z-level, or a [/datum/space_level].
 * * end: The destination Z level. Can either be a numeric z-level, or a [/datum/space_level].
 */
/proc/get_linked_z_angle(datum/space_level/start, datum/space_level/end)
	if(isnum(start))
		start = SSmapping.get_level(start)
	if(isnum(end))
		end = SSmapping.get_level(end)
	// Check the neighbors first, and return the appropiate angle if it is a neighbor.
	for(var/direction in start.neigbours)
		var/datum/space_level/neighbor = start.neigbours[direction]
		if(neighbor == end)
			var/angle = GLOB.cardinal_angles[direction]
			if(!isnull(angle))
				return angle
	// Otherwise, if they're both crosslinked, calculate the angle using their grid coordinates.
	if(start.linkage == CROSSLINKED && end.linkage == CROSSLINKED)
		var/dx = end.xi - start.xi
		var/dy = end.yi - start.yi
		return round(delta_to_angle(dy, dx))
	return null
