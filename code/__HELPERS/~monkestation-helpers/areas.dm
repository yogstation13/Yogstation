/proc/is_station_area_or_adjacent(area/area)
	var/static/list/blacklisted_areas = typecacheof(list(
		/area/centcom,
		/area/forestplanet,
		/area/icemoon,
		/area/lavaland,
		/area/misc,
		/area/ocean,
		/area/ruin,
		/area/shipbreak,
		/area/shuttle,
		/area/space,
		/area/station/asteroid,
	))
	var/static/list/outdoor_areas = typecacheof(list(
		/area/forestplanet,
		/area/icemoon,
	))
	if(!isarea(area))
		if(ispath(area, /area))
			area = GLOB.areas_by_type[area]
		else if(isatom(area))
			area = get_area(get_turf(area))
		else
			return FALSE
	if(isnull(area) || is_type_in_typecache(area, blacklisted_areas))
		return FALSE
	if(GLOB.the_station_areas.Find(area.type))
		return TRUE
	var/list/edge_areas = list()
	for(var/adjacent_areas_list in get_area_edge_turfs(area, return_adjacent_areas = TRUE)) // returns a list of lists for some reason
		edge_areas |= adjacent_areas_list
	for(var/area/adjacent_area as anything in edge_areas)
		if(GLOB.the_station_areas.Find(adjacent_area.type) || is_type_in_typecache(adjacent_area, outdoor_areas)) // yeah sure you can make a neat little base in an icebox cabin
			return TRUE
	return FALSE

