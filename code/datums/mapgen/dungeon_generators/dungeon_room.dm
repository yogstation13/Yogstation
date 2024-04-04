/** 
 * This datum represents a "room" which is created by the Dungeon Generator process. Whether you use Binary Space Partition(BSP) or Random Room Placement(RRP),
 * the Rust algorith will populate the given area with rooms, which are just squares and rectangles of various dimensions with X and Y coordinates. I created
 * this datum to give better control over the data the generator is using. So you can look through the list of rooms for feedback or to understand what's happening.
 * 
 * The datum has procs to construct itself at the given coordinates, and procs to furnish itself according to the randomly assigned "theme" it chooses for itself
 * on init.
 */
/datum/dungeon_room
	///Some kind of identifier. Will default to the number of the rooms in the list, like "Random room 5"
	var/id
	
	///X coordinate of the bottom left corner
	var/x1 
	///Y coordinate of the bottom left corner
	var/y1 
	
	///X coordinate of the top right corner
	var/x2
	///Y coordinate of the top right corner
	var/y2
	
	///z-level of the room
	var/z
	
	///Tile width of the room, including walls. A 5 width room is a 3 tile wide interior with a wall on each side
	var/width
	///Tile height of the room, including walls. A 5 height room is a 3 tile tall interior with a wall on each side
	var/height
	
	///The center tile of a room, or at least as close to center as it can get if the room is of different dimensions, or equal dimensions with no center
	var/turf/center = null

	/** 
	 * A list of the outermost turfs. This is used to generate walls and doors
	 *  
	 * *  exterior = Full room  -  interior			  
	 * * [X][X][X][X] = [X][X][X][X] - [0][0][0][0]	
	 * * [X][0][0][X] = [X][X][X][X] - [0][X][X][0]		
	 * * [X][0][0][X] = [X][X][X][X] - [0][X][X][0]
	 * * [X][X][X][X] = [X][X][X][X] - [0][0][0][0]
	 */
	var/list/exterior = list()
	
	/**
	 * A list of the turfs inside the outer walls. This is the room for activities and decorations 
	 * * Interior area of full room
	 * * [0][0][0][0]
	 * * [0][X][X][0]
	 * * [0][X][X][0]
	 * * [0][0][0][0]
	 */
	var/list/interior = list()

	var/min_doors = 1
	var/max_doors = 4
	///A list of the doors belonging to a room
	var/list/datum/weakref/doors = list()
	var/list/datum/weakref/features = list()
	var/list/datum/weakref/mobs = list()

	/** 
	 * List of protected atom types. Rooms use turf.empty() to replace turfs and delete their contents at the same time. This is so that if a room overlaps another,
	 * lingering elements like walls, doors, windows, and even mobs will be removed. This is also helpful if you want to generate over elements that are already
	 * placed by map editors, like in the case of pipes and cables for atmos and station power.
	 */
	var/static/list/protected_atoms = typecacheof(list(
		/obj/machinery/atmospherics/pipe,
		/obj/structure/cable,
		))
	
	///If this room needed to get trimmed because it overlapped an area that shouldn't be touched
	var/completed_room = TRUE

	var/datum/map_generator/dungeon_generator/generator_ref
	
	var/list/weighted_open_turf_types = list()
	var/list/weighted_closed_turf_types = list()
	
	var/datum/dungeon_room_theme/room_theme

	///for differentiating room types yourself. like maybe 1 is a ruin, and 2 is empty
	var/room_type

	var/room_danger_level
	
	var/area/area_ref = null

/datum/dungeon_room/New(
	_id = "randomly generated room", 
	_x1 = 1, 
	_y1 = 1, 
	_x2 = 1, 
	_y2 = 1, 
	_z = 1, 
	_width = 1, 
	_height = 1, 
	_room_type, 
	_room_danger_level, datum/map_generator/dungeon_generator/_generator_ref)

	id = _id
	x1 = _x1
	y1 = _y1
	x2 = _x2
	y2 = _y2
	z = _z
	width = _width
	height = _height

	center = locate(ROUND_UP(x1+width/2), ROUND_UP(y1+height/2), z)

	area_ref = get_area(center)
	if(_room_type)
		room_type = _room_type
	if(_room_danger_level)
		room_danger_level = _room_danger_level
	
	interior = block(locate(x1+1,y1+1,z),locate(x2-1,y2-1,z))
	exterior = block(locate(x1,y1,z),locate(x2,y2,z)) - interior

	generator_ref = _generator_ref

	if(generator_ref.open_turf_types)
		weighted_open_turf_types = generator_ref.open_turf_types
	if(generator_ref.closed_turf_types)
		weighted_closed_turf_types = generator_ref.closed_turf_types

///Override this for each new room type so you know whether to trim or discard rooms that overlap areas that should remain untouched
/datum/dungeon_room/proc/Initialize()
	validation_check()
	
	generate_room_theme()
	

/datum/dungeon_room/proc/generate_room_theme()
	if(!room_danger_level)
		room_danger_level = ROOM_RATING_SAFE
	if(!room_type)
		room_type = ROOM_TYPE_RANDOM
	if(!room_theme)
		room_theme = new generator_ref.room_theme_path(src)
		room_theme.Initialize()

///checks if the room overlaps areas it shouldn't and if it does remove that tile from the room
/datum/dungeon_room/proc/validation_check()
	for(var/turf/tile in exterior)
		var/area/area_to_check = get_area(tile)
		if(!is_type_in_typecache(area_to_check, generator_ref.overlappable_areas))
			exterior -= tile
			completed_room = FALSE

	for(var/turf/tile in interior)
		var/area/area_to_check = get_area(tile)
		if(!is_type_in_typecache(area_to_check, generator_ref.overlappable_areas))
			interior -= tile
			completed_room = FALSE

///If you're making an area that has ruin map files, you can use this to determine if it should be a ruin room
/datum/dungeon_room/proc/is_ruin_compatible()
	return FALSE

///Construct yourself in the game world NOW. Assuming you have a theme to pull from, otherwise stay theoretical. 
/datum/dungeon_room/proc/generate()
	if(isnull(room_theme))
		return FALSE
	
	if(room_theme.room_flags & ROOM_HAS_FLOORS)
		build_flooring()
	
	if(room_theme.room_flags & ROOM_HAS_WALLS || room_theme.room_flags & ROOM_HAS_WINDOWS)
		build_walls()
	
	if(room_theme.room_flags & ROOM_HAS_DOORS)
		add_doors()
	
	if(room_theme.room_flags & ROOM_HAS_SPECIAL_FEATURES)
		add_special_features()

	if(room_theme.room_flags & ROOM_HAS_FEATURES)
		add_features()
	
	if(room_theme.room_flags & ROOM_HAS_MOBS)
		add_mobs()
	
	room_theme.post_generate()
	
	generator_ref.owned_mobs |= mobs
	
	/**
	 * This loop is for setting the inside of a room to match the area of its center. The reason we also fuck around with the lighting overlays is because
	 * at the time of generation, the lighting subsystem isn't initialized yet, so we'll handle calling the building and clearing of area lighting diffs ourselves.
	 */
	for(var/turf/room_turf in (interior + exterior))
		var/area/old_area = get_area(room_turf)
		if(area_ref != old_area && !generator_ref.areas_included.Find(old_area))
			area_ref.contents += room_turf
			area_ref.contained_turfs += room_turf
			old_area.turfs_to_uncontain += room_turf
			room_turf.change_area(old_area, area_ref)
	
	return TRUE

///For each tile in the exterior, build a wall to keep the assistants out. Or a window if the room theme calls for it
/datum/dungeon_room/proc/build_walls()
	if(!(room_theme.room_flags & ROOM_HAS_WALLS || room_theme.room_flags & ROOM_HAS_WINDOWS))
		return
	for(var/turf/room_turf in exterior)
		//we use the generator flooring for this because the space rooms only have space flooring
		room_turf.empty(pickweight(weighted_open_turf_types), ignore_typecache = protected_atoms, flags = CHANGETURF_DEFER_CHANGE | CHANGETURF_IGNORE_AIR)
		if(room_theme.room_flags & ROOM_HAS_WINDOWS && prob(room_theme.window_weight) || room_theme.room_flags & ROOM_HAS_ONLY_WINDOWS)

			var/obj/window_to_spawn = room_theme.get_random_window()
			new window_to_spawn(room_turf)
		else
			if(!room_theme.weighted_possible_wall_types.Find(room_turf.type))
				
				room_turf.place_on_top(pick(room_theme.get_random_wall()), flags = CHANGETURF_DEFER_CHANGE | CHANGETURF_IGNORE_AIR)
	return

///Build the flooring for the room. Potentially not necessary based on the build area, but making sure the room doesn't construct over space or gen turf is a good idea
/datum/dungeon_room/proc/build_flooring()
	if(!(room_theme.room_flags & ROOM_HAS_FLOORS))
		return
	for(var/turf/room_turf in interior)
		//we want to remove everything in the loc but don't want to change the loc type in this way
		room_turf.empty(null, ignore_typecache = protected_atoms)
		room_turf.place_on_top(pick(room_theme.get_random_flooring()), flags = CHANGETURF_DEFER_CHANGE | CHANGETURF_IGNORE_AIR)
		
	return

///Add a random number of doors to the room. If you're lucky, people will actually be able to access the room. If not, it's a ~super secret room~
/datum/dungeon_room/proc/add_doors()
	if(!(room_theme.room_flags & ROOM_HAS_DOORS))
		return
	var/num_of_doors_to_gen = rand(min_doors, max_doors)
	var/list/directions = GLOB.cardinals.Copy()
	var/max_attempts = 5
	var/attempts_left = 5
	while(doors.len < num_of_doors_to_gen && directions.len && attempts_left > 0 )
		var/turf/door_spot = null
		var/wall_side = pick_n_take(directions)
		switch(wall_side)
			if(NORTH)
				door_spot = locate(ROUND_UP(x2-width/2),y2,z)
			if(SOUTH)
				door_spot = locate(ROUND_UP(x2-width/2),y1,z)
			if(EAST)
				door_spot = locate(x2,ROUND_UP(y2-height/2),z)
			if(WEST)
				door_spot = locate(x1,ROUND_UP(y2-height/2),z)
		
		if(exterior.Find(door_spot))
			var/turf/other_side_of_door = get_step(door_spot, wall_side)
			if(istype(other_side_of_door, /turf/open/space))
				num_of_doors_to_gen--
				continue
			door_spot.empty(pick(room_theme.get_random_flooring()), ignore_typecache = protected_atoms, flags = CHANGETURF_DEFER_CHANGE | CHANGETURF_IGNORE_AIR)
			var/door_path = room_theme.get_random_door()
			if(ispath(door_path))
				var/obj/machinery/door/new_door = new door_path(door_spot)
				doors += WEAKREF(new_door)
				attempts_left = max_attempts
		attempts_left--

///Sprinkle in the flavor from the room's theme like blood splatters, trash, or items. The number of flavor items is based on the room size and feature weight
/datum/dungeon_room/proc/add_special_features()
	if(!(room_theme.room_flags & ROOM_HAS_SPECIAL_FEATURES) || !interior.len)
		return
	
	var/special_feature_path = room_theme.get_special_feature()
	if(ispath(special_feature_path))
		var/obj/special_feature = new special_feature_path(locate(x1+1, y1+1, z))
		features += WEAKREF(special_feature)
		return TRUE
	return FALSE

///Sprinkle in the flavor from the room's theme like blood splatters, trash, or items. The number of flavor items is based on the room size and feature weight
/datum/dungeon_room/proc/add_features()
	if(!(room_theme.room_flags & ROOM_HAS_FEATURES) || !interior.len)
		return
	
	var/features_to_spawn = round( (interior.len) * (room_theme.feature_weight * 0.01), 1 )
	var/max_attempts = 10
	var/attempts_left = 10
	while(features_to_spawn > 0 && attempts_left > 0)
		var/turf/spawn_point = pick(interior)
		if(!spawn_point.is_blocked_turf())
			var/selected_feature_path = room_theme.get_random_feature()
			if(islist(selected_feature_path))
				for(var/path_to_check in selected_feature_path)
					if(ispath(path_to_check))
						var/obj/new_feature = new path_to_check(spawn_point)
						features += WEAKREF(new_feature)
				features_to_spawn = clamp(features_to_spawn-1, 0, max_attempts)
				//if we successfully spawn something, reset the attempt count
				attempts_left = max_attempts
			
			else if(ispath(selected_feature_path))
				var/obj/new_feature = new selected_feature_path(spawn_point)
				features += WEAKREF(new_feature)
				features_to_spawn = clamp(features_to_spawn-1, 0, max_attempts)
				//if we successfully spawn something, reset the attempt count
				attempts_left = max_attempts
			
			else
				attempts_left = clamp(attempts_left-1, 0, max_attempts) 

///Add mobs if the room's theme has any, be it rats or space dragons lmao. The number of mobs is based on the room size and mob weight
/datum/dungeon_room/proc/add_mobs()
	if(!(room_theme.room_flags & ROOM_HAS_MOBS) || !interior.len)
		return

	var/mobs_to_spawn = round( log(interior.len) * ((interior.len/100) + 1), 1 )
	var/max_attempts = 10
	var/attempts_left = 10
	while(mobs_to_spawn > 0 && attempts_left > 0)
		if(!prob(room_theme.mob_spawn_chance))
			mobs_to_spawn = clamp(mobs_to_spawn-1, 0, mobs_to_spawn)
			continue
		var/turf/spawn_point = pick(interior)
		if(!spawn_point.is_blocked_turf())
			var/selected_mob_path = room_theme.get_random_mob()
			if(ispath(selected_mob_path, /mob/living/simple_animal))
				var/mob/living/simple_animal/new_mob = new selected_mob_path(spawn_point)
				/**
				 * We toggle the mob AI off as they're created because if the generator is being ran slowly and taking a while to generate, 
				 * mobs can break out of their rooms and start fighting before the generator is even done
				 */
				new_mob.toggle_ai(AI_OFF)
				mobs += WEAKREF(new_mob)
				mobs_to_spawn = clamp(mobs_to_spawn-1, 0, mobs_to_spawn)
				//if we successfully spawn a mob, reset the attempt count
				attempts_left = max_attempts
		attempts_left = clamp(attempts_left-1, 0, max_attempts) 


/**	
 * Experimental and buggy, but calling this SHOULD remove the room from the game world, along with all the room's tiles and items. 
 * leaving the area looking how it did before generation. just thanos snap the room off the map like it never existed. however with rooms overlapping
 * and intersecting this may just remove a chunk of another room
 */
/datum/dungeon_room/proc/delete_self()
	for(var/turf/room_turf in interior)
		//again we want to clean the tile of any mobs or props before reverting it to the pre-room setting
		room_turf.empty(null, ignore_typecache = protected_atoms)
		room_turf.ScrapeAway()
	
	for(var/turf/room_turf in exterior)
		//again we want to clean the tile of any mobs or props before reverting it to the pre-room setting
		room_turf.empty(null, ignore_typecache = protected_atoms)
		room_turf.ScrapeAway()
