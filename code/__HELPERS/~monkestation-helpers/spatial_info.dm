#define EDGE_STATE_SOUTH_BORDER 1
#define EDGE_STATE_MAP_BOTTOM 2
#define EDGE_STATE_MAP_TOP 3
#define SET_DIR_LIST(dir_list, edge_state) \
	switch(edge_state) { \
		if(EDGE_STATE_MAP_BOTTOM) { \
			##dir_list = GLOB.cardinals - SOUTH;\
			} \
		if(EDGE_STATE_MAP_TOP) { \
			##dir_list = GLOB.cardinals - NORTH;\
			} \
		else { \
			##dir_list = GLOB.cardinals;\
			} \
	}

#define ADD_NEW_AREAS(dir_list, step_turf, step_of, checked, added_to) \
	for(var/dir in dir_list) { \
		##step_turf = get_step(step_of, dir);\
		if(step_turf && step_turf.loc != checked) { \
			##added_to |= step_turf.loc;\
			} \
	}

///Returns all turfs on the border of an area
/proc/get_area_edge_turfs(area/checked, return_adjacent_areas = FALSE) as /list
	RETURN_TYPE(/list)
	var/list/returned_list = list()
	for(var/i in 1 to length(checked.turfs_by_zlevel))
		var/list/z_turfs = checked.turfs_by_zlevel[i]
		var/list/new_list = list()
		var/last_y = 0
		var/edge_state = FALSE
		var/turf/last_checked
		returned_list.len++
		returned_list[i] = new_list
		for(var/turf/z_turf in z_turfs)
			if(z_turf.y != last_y)
				last_y = z_turf.y
				if(last_checked)
					if(return_adjacent_areas)
						var/list/dir_list
						SET_DIR_LIST(dir_list, edge_state)
						var/turf/step_turf
						ADD_NEW_AREAS(dir_list, step_turf, last_checked, checked, new_list)
					else
						new_list += last_checked

				if(z_turf.y == 1)
					edge_state = EDGE_STATE_MAP_BOTTOM
				else if(last_y == 0)
					edge_state = EDGE_STATE_SOUTH_BORDER
				else if(z_turf.y == world.maxy)
					edge_state = EDGE_STATE_MAP_TOP
				else
					edge_state = FALSE

				if(return_adjacent_areas)
					var/list/dir_list
					SET_DIR_LIST(dir_list, edge_state)
					var/turf/step_turf
					ADD_NEW_AREAS(dir_list, step_turf, z_turf, checked, new_list)
				else
					new_list += z_turf
				last_checked = null
				continue

			if(edge_state)
				if(return_adjacent_areas)
					var/list/dir_list
					SET_DIR_LIST(dir_list, edge_state)
					var/turf/step_turf
					ADD_NEW_AREAS(dir_list, step_turf, z_turf, checked, new_list)
				else
					new_list += z_turf
				continue

			var/turf/north_turf = get_step(z_turf, NORTH)
			if(north_turf.loc != checked) //if we dont have a step something else already broke as map borders have already been handled
				if(return_adjacent_areas)
					var/list/dir_list = GLOB.cardinals - NORTH
					if(edge_state == EDGE_STATE_MAP_BOTTOM)
						dir_list -= SOUTH
					var/turf/step_turf
					ADD_NEW_AREAS(dir_list, step_turf, z_turf, checked, new_list)
				new_list |= (return_adjacent_areas ? north_turf.loc : z_turf)
				last_checked = null
			else
				last_checked = z_turf
	return returned_list

#undef EDGE_STATE_SOUTH_BORDER
#undef EDGE_STATE_MAP_BOTTOM
#undef EDGE_STATE_MAP_TOP
#undef SET_DIR_LIST
#undef ADD_NEW_AREAS
