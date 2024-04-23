SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = INIT_ORDER_MAPPING
	runlevels = ALL

	loading_points = 11 SECONDS // Yogs -- loading times

	var/list/nuke_tiles = list()
	var/list/nuke_threats = list()

	var/datum/map_config/config
	var/datum/map_config/next_map_config

	/// Has the map for the next round been voted for already?
	var/map_voted = FALSE
	/// Has the map for the next round been deliberately chosen by an admin?
	var/map_force_chosen = FALSE
	/// Has the map vote been rocked?
	var/map_vote_rocked = FALSE

	var/list/map_templates = list()

	var/list/ruins_templates = list()
	var/list/space_ruins_templates = list()
	var/list/lava_ruins_templates = list()
	var/list/ice_ruins_templates = list()
	var/list/ice_ruins_underground_templates = list()
	//Yogs edit 
	var/list/jungleland_proper_ruins_templates = list()
	var/list/jungleland_dying_ruins_templates = list()
	var/list/jungleland_swamp_ruins_templates = list()
	var/list/jungleland_barren_ruins_templates = list()
	var/list/jungleland_general_ruins_templates = list()
	//Yogs end

	var/list/shuttle_templates = list()
	var/list/shelter_templates = list()
	var/list/holodeck_templates = list()

	var/list/station_minimaps = list()

	var/list/areas_in_z = list()
	/// List of z level (as number) -> plane offset of that z level
	/// Used to maintain the plane cube
	var/list/z_level_to_plane_offset = list()
	/// List of z level (as number) -> list of all z levels vertically connected to ours
	/// Useful for fast grouping lookups and such
	var/list/z_level_to_stack = list()
	/// List of z level (as number) -> The lowest plane offset in that z stack
	var/list/z_level_to_lowest_plane_offset = list()
	// This pair allows for easy conversion between an offset plane, and its true representation
	// Both are in the form "input plane" -> output plane(s)
	/// Assoc list of string plane values to their true, non offset representation
	var/list/plane_offset_to_true
	/// Assoc list of true string plane values to a list of all potential offset planess
	var/list/true_to_offset_planes
	/// Assoc list of string plane to the plane's offset value
	var/list/plane_to_offset
	/// List of planes that do not allow for offsetting
	var/list/plane_offset_blacklist
	/// List of render targets that do not allow for offsetting
	var/list/render_offset_blacklist
	/// List of plane masters that are of critical priority
	var/list/critical_planes
	/// The largest plane offset we've generated so far
	var/max_plane_offset = 0

	var/loading_ruins = FALSE
	var/list/turf/unused_turfs = list() //Not actually unused turfs they're unused but reserved for use for whatever requests them. "[zlevel_of_turf]" = list(turfs)
	var/list/datum/turf_reservations //list of turf reservations
	var/list/used_turfs = list() //list of turf = datum/turf_reservation
	/// List of lists of turfs to reserve
	var/list/lists_to_reserve = list()

	var/list/reservation_ready = list()
	var/clearing_reserved_turfs = FALSE

	///All possible biomes in assoc list as type || instance
	var/list/biomes = list()

	// Z-manager stuff
	var/station_start  // should only be used for maploading-related tasks
	var/space_levels_so_far = 0
	///list of all z level datums in the order of their z (z level 1 is at index 1, etc.)
	var/list/datum/space_level/z_list
	///list of all z level indices that form multiz connections and whether theyre linked up or down.
	///list of lists, inner lists are of the form: list("up or down link direction" = TRUE)
	var/list/multiz_levels = list()
	var/datum/space_level/transit
	var/datum/space_level/empty_space
	var/num_of_res_levels = 1
	/// True when in the process of adding a new Z-level, global locking
	var/adding_new_zlevel = FALSE

	///shows the default gravity value for each z level. recalculated when gravity generators change.
	///List in the form: list(z level num = max generator gravity in that z level OR the gravity level trait)
	var/list/gravity_by_z_level = list()

	/// list of traits and their associated z leves
	var/list/z_trait_levels = list()

	/// list of lazy templates that have been loaded
	var/list/loaded_lazy_templates

/datum/controller/subsystem/mapping/PreInit()
	..()
#ifdef FORCE_MAP
	config = load_map_config(FORCE_MAP, FORCE_MAP_DIRECTORY)
#else
	config = load_map_config(error_if_missing = FALSE)
#endif

/datum/controller/subsystem/mapping/Initialize(timeofday)
	if(initialized)
		return SS_INIT_SUCCESS
	if(config.defaulted)
		var/old_config = config
		config = global.config.defaultmap
		if(!config || config.defaulted)
			to_chat(world, span_boldannounce("Unable to load next or default map config, defaulting to Box Station"))
			config = old_config
	plane_offset_to_true = list()
	true_to_offset_planes = list()
	plane_to_offset = list()
	// VERY special cases for FLOAT_PLANE, so it will be treated as expected by plane management logic
	// Sorry :(
	plane_offset_to_true["[FLOAT_PLANE]"] = FLOAT_PLANE
	true_to_offset_planes["[FLOAT_PLANE]"] = list(FLOAT_PLANE)
	plane_to_offset["[FLOAT_PLANE]"] = 0
	plane_offset_blacklist = list()
	// You aren't allowed to offset a floatplane that'll just fuck it all up
	plane_offset_blacklist["[FLOAT_PLANE]"] = TRUE
	render_offset_blacklist = list()
	critical_planes = list()
	create_plane_offsets(0, 0)
	initialize_biomes()
	loadWorld()
	require_area_resort()
	process_teleport_locs()			//Sets up the wizard teleport locations
	preloadTemplates()

	var/list/jungle_ruins = levels_by_trait(ZTRAIT_JUNGLE_RUINS)
	//this is really fuckign hacky, but we need to have a very specific order for these things, and if jungleland isn't even being loaded then i dont fucking care.
	if(jungle_ruins.len)
		seedRuins(jungle_ruins, CONFIG_GET(number/jungleland_budget), list(/area/pregen), jungleland_general_ruins_templates, clear_below = TRUE)
		run_map_generation()
		seedRuins(jungle_ruins, CONFIG_GET(number/jungleland_budget), list(/area/jungleland/proper), jungleland_proper_ruins_templates, clear_below = TRUE)
		seedRuins(jungle_ruins, CONFIG_GET(number/jungleland_budget), list(/area/jungleland/dying_forest), jungleland_dying_ruins_templates, clear_below = TRUE)
		seedRuins(jungle_ruins, CONFIG_GET(number/jungleland_budget), list(/area/jungleland/toxic_pit), jungleland_swamp_ruins_templates, clear_below = TRUE)
		seedRuins(jungle_ruins, CONFIG_GET(number/jungleland_budget), list(/area/jungleland/barren_rocks), jungleland_barren_ruins_templates, clear_below = TRUE)
	else
		run_map_generation()
	//YOGS EDIT
#ifndef LOWMEMORYMODE
	//Pregenerate generic jungleland ruins that are biome-nonspecific 

	//YOGS END
	
	// Create space ruin levels
	while (space_levels_so_far < config.space_ruin_levels)
		++space_levels_so_far
		add_new_zlevel("Empty Area [space_levels_so_far]", ZTRAITS_SPACE)
	// and one level with no ruins
	for (var/i in 1 to config.space_empty_levels)
		++space_levels_so_far
		empty_space = add_new_zlevel("Empty Area [space_levels_so_far]", list(ZTRAIT_LINKAGE = CROSSLINKED))

	// Pick a random away mission.
	if(CONFIG_GET(flag/roundstart_away))
		createRandomZlevel(prob(CONFIG_GET(number/config_gateway_chance)))

	// Load the virtual reality hub
	if(CONFIG_GET(flag/virtual_reality))
		to_chat(world, span_boldannounce("Loading virtual reality..."))
		load_new_z_level("_maps/RandomZLevels/VR/vrhub.dmm", "Virtual Reality Hub")
		to_chat(world, span_boldannounce("Virtual reality loaded."))


	// Generate mining ruins
	loading_ruins = TRUE
	var/list/lava_ruins = levels_by_trait(ZTRAIT_LAVA_RUINS)
	if (lava_ruins.len)
		seedRuins(lava_ruins, CONFIG_GET(number/lavaland_budget), list(/area/lavaland/surface/outdoors/unexplored), lava_ruins_templates, clear_below = TRUE)
		for (var/lava_z in lava_ruins)
			spawn_rivers(lava_z)

	var/list/ice_ruins = levels_by_trait(ZTRAIT_ICE_RUINS)
	if (ice_ruins.len)
		// needs to be whitelisted for underground too so place_below ruins work
		seedRuins(ice_ruins, CONFIG_GET(number/icemoon_budget), list(/area/icemoon/surface/outdoors/unexplored, /area/icemoon/underground/unexplored), ice_ruins_templates, clear_below = TRUE)

	var/list/ice_ruins_underground = levels_by_trait(ZTRAIT_ICE_RUINS_UNDERGROUND)
	if (ice_ruins_underground.len)
		seedRuins(ice_ruins_underground, CONFIG_GET(number/icemoon_budget), list(/area/icemoon/underground/unexplored), ice_ruins_underground_templates, clear_below = TRUE)

	// Generate deep space ruins
	var/list/space_ruins = levels_by_trait(ZTRAIT_SPACE_RUINS)
	if (space_ruins.len)
		seedRuins(space_ruins, CONFIG_GET(number/space_budget), list(/area/space), space_ruins_templates)
	seedStation()
	loading_ruins = FALSE
	
	//Load Reebe
	var/list/errorList = list()
	SSmapping.LoadGroup(errorList, "Reebe", "map_files/generic", "City_of_Cogs.dmm", default_traits = ZTRAITS_REEBE, silent = TRUE)
	if(errorList.len)	// reebe failed to load
		message_admins("Reebe failed to load!")
		log_game("Reebe failed to load!")
	//Load an Arena
	errorList = list()
	SSmapping.LoadGroup(errorList, "Arena", "templates", "arena.dmm", silent = TRUE)
	if(errorList.len)	// arena failed to load
		message_admins("A shuttle arena failed to load!")
		log_game("A shuttle arena failed to load!")
#endif
	// Add the transit level
	var/datum/space_level/base_transit = add_reservation_zlevel()
	require_area_resort()
	// Set up Z-level transitions.
	setup_map_transitions()
	generate_station_area_list()
	initialize_reserved_level(base_transit.z_value)
	calculate_default_z_level_gravities()
	// Build minimaps
	build_minimaps()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/mapping/fire(resumed)
	// Cache for sonic speed
	var/list/unused_turfs = src.unused_turfs
	var/list/world_contents = GLOB.areas_by_type[world.area].contents
	var/list/world_turf_contents = GLOB.areas_by_type[world.area].contained_turfs
	var/list/lists_to_reserve = src.lists_to_reserve
	var/index = 0
	while(index < length(lists_to_reserve))
		var/list/packet = lists_to_reserve[index + 1]
		var/packetlen = length(packet)
		while(packetlen)
			if(MC_TICK_CHECK)
				if(index)
					lists_to_reserve.Cut(1, index)
				return
			var/turf/T = packet[packetlen]
			T.empty(RESERVED_TURF_TYPE, RESERVED_TURF_TYPE, null, TRUE)
			LAZYINITLIST(unused_turfs["[T.z]"])
			unused_turfs["[T.z]"] |= T
			var/area/old_area = T.loc
			old_area.turfs_to_uncontain += T
			T.turf_flags = UNUSED_RESERVATION_TURF
			world_contents += T
			world_turf_contents += T
			packet.len--
			packetlen = length(packet)

		index++
	lists_to_reserve.Cut(1, index)

/datum/controller/subsystem/mapping/proc/calculate_default_z_level_gravities()
	for(var/z_level in 1 to length(z_list))
		calculate_z_level_gravity(z_level)

/datum/controller/subsystem/mapping/proc/generate_z_level_linkages()
	for(var/z_level in 1 to length(z_list))
		generate_linkages_for_z_level(z_level)

/datum/controller/subsystem/mapping/proc/generate_linkages_for_z_level(z_level)
	if(!isnum(z_level) || z_level <= 0)
		return FALSE

	if(multiz_levels.len < z_level)
		multiz_levels.len = z_level

	var/z_above = level_trait(z_level, ZTRAIT_UP)
	var/z_below = level_trait(z_level, ZTRAIT_DOWN)
	if(!(z_above == TRUE || z_above == FALSE || z_above == null) || !(z_below == TRUE || z_below == FALSE || z_below == null))
		stack_trace("Warning, numeric mapping offsets are deprecated. Instead, mark z level connections by setting UP/DOWN to true if the connection is allowed")
	multiz_levels[z_level] = new /list(LARGEST_Z_LEVEL_INDEX)
	multiz_levels[z_level][Z_LEVEL_UP] = !!z_above
	multiz_levels[z_level][Z_LEVEL_DOWN] = !!z_below

/datum/controller/subsystem/mapping/proc/calculate_z_level_gravity(z_level_number)
	if(!isnum(z_level_number) || z_level_number < 1)
		return FALSE

	var/max_gravity = 0

	for(var/obj/machinery/gravity_generator/main/grav_gen as anything in GLOB.gravity_generators["[z_level_number]"])
		max_gravity = max(grav_gen.setting, max_gravity)

	max_gravity = max_gravity || level_trait(z_level_number, ZTRAIT_GRAVITY) || 0//just to make sure no nulls
	gravity_by_z_level[z_level_number] = max_gravity
	return max_gravity

/datum/controller/subsystem/mapping/proc/wipe_reservations(wipe_safety_delay = 100)
	if(clearing_reserved_turfs || !initialized) //in either case this is just not needed.
		return
	clearing_reserved_turfs = TRUE
	SSshuttle.transit_requesters.Cut()
	message_admins("Clearing dynamic reservation space.")
	var/list/obj/docking_port/mobile/in_transit = list()
	for(var/i in SSshuttle.transit_docking_ports)
		var/obj/docking_port/stationary/transit/T = i
		if(!istype(T))
			continue
		in_transit[T] = T.get_docked()
	var/go_ahead = world.time + wipe_safety_delay
	if(in_transit.len)
		message_admins("Shuttles in transit detected. Attempting to fast travel. Timeout is [wipe_safety_delay/10] seconds.")
	var/list/cleared = list()
	for(var/i in in_transit)
		INVOKE_ASYNC(src, PROC_REF(safety_clear_transit_dock), i, in_transit[i], cleared)
	UNTIL((go_ahead < world.time) || (cleared.len == in_transit.len))
	do_wipe_turf_reservations()
	clearing_reserved_turfs = FALSE

/datum/controller/subsystem/mapping/proc/safety_clear_transit_dock(obj/docking_port/stationary/transit/T, obj/docking_port/mobile/M, list/returning)
	M.setTimer(0)
	var/error = M.initiate_docking(M.destination, M.preferred_direction)
	if(!error)
		returning += M
		qdel(T, TRUE)

/datum/controller/subsystem/mapping/proc/get_reservation_from_turf(turf/T)
	RETURN_TYPE(/datum/turf_reservation)
	return used_turfs[T]

/* Nuke threats, for making the blue tiles on the station go RED
   Used by the AI doomsday and the self destruct nuke.
*/

/datum/controller/subsystem/mapping/proc/add_nuke_threat(datum/nuke)
	nuke_threats[nuke] = TRUE
	check_nuke_threats()

/datum/controller/subsystem/mapping/proc/remove_nuke_threat(datum/nuke)
	nuke_threats -= nuke
	check_nuke_threats()

/datum/controller/subsystem/mapping/proc/check_nuke_threats()
	for(var/datum/d in nuke_threats)
		if(!istype(d) || QDELETED(d))
			nuke_threats -= d

	for(var/N in nuke_tiles)
		var/turf/open/floor/circuit/C = N
		C.update_appearance(UPDATE_ICON)

/datum/controller/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	initialized = SSmapping.initialized
	map_templates = SSmapping.map_templates
	ruins_templates = SSmapping.ruins_templates
	space_ruins_templates = SSmapping.space_ruins_templates
	lava_ruins_templates = SSmapping.lava_ruins_templates
	ice_ruins_templates = SSmapping.ice_ruins_templates
	ice_ruins_underground_templates = SSmapping.ice_ruins_underground_templates
	shuttle_templates = SSmapping.shuttle_templates
	shelter_templates = SSmapping.shelter_templates
	unused_turfs = SSmapping.unused_turfs
	turf_reservations = SSmapping.turf_reservations
	used_turfs = SSmapping.used_turfs

	config = SSmapping.config
	next_map_config = SSmapping.next_map_config

	clearing_reserved_turfs = SSmapping.clearing_reserved_turfs

	z_list = SSmapping.z_list
	multiz_levels = SSmapping.multiz_levels
	loaded_lazy_templates = SSmapping.loaded_lazy_templates

#define INIT_ANNOUNCE(X) to_chat(world, span_boldannounce("[X]")); log_world(X)
/datum/controller/subsystem/mapping/proc/LoadGroup(list/errorList, name, path, files, list/traits, list/default_traits, silent = FALSE)
	. = list()
	var/start_time = REALTIMEOFDAY

	if (!islist(files))  // handle single-level maps
		files = list(files)

	// check that the total z count of all maps matches the list of traits
	var/total_z = 0
	var/list/parsed_maps = list()
	for (var/file in files)
		var/full_path = "_maps/[path]/[file]"
		var/datum/parsed_map/pm = new(file(full_path))
		var/bounds = pm?.bounds
		if (!bounds)
			errorList |= full_path
			continue
		parsed_maps[pm] = total_z  // save the start Z of this file
		total_z += bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1

	if (!length(traits))  // null or empty - default
		for (var/i in 1 to total_z)
			traits += list(default_traits)
	else if (total_z != traits.len)  // mismatch
		INIT_ANNOUNCE("WARNING: [traits.len] trait sets specified for [total_z] z-levels in [path]!")
		if (total_z < traits.len)  // ignore extra traits
			traits.Cut(total_z + 1)
		while (total_z > traits.len)  // fall back to defaults on extra levels
			traits += list(default_traits)

	// preload the relevant space_level datums
	var/start_z = world.maxz + 1
	var/i = 0
	for (var/level in traits)
		add_new_zlevel("[name][i ? " [i + 1]" : ""]", level, contain_turfs = FALSE)
		++i

	// load the maps
	for (var/P in parsed_maps)
		var/datum/parsed_map/pm = P
		var/bounds = pm.bounds
		var/x_offset = bounds ? round(world.maxx / 2 - bounds[MAP_MAXX] / 2) + 1 : 1
		var/y_offset = bounds ? round(world.maxy / 2 - bounds[MAP_MAXY] / 2) + 1 : 1
		if (!pm.load(x_offset, y_offset, start_z + parsed_maps[P], no_changeturf = TRUE, new_z = TRUE))
			errorList |= pm.original_path
	if(!silent)
		INIT_ANNOUNCE("Loaded [name] in [(REALTIMEOFDAY - start_time)/10]s!")
	return parsed_maps

/datum/controller/subsystem/mapping/proc/loadWorld()
	//if any of these fail, something has gone horribly, HORRIBLY, wrong
	var/list/FailedZs = list()

	// ensure we have space_level datums for compiled-in maps
	InitializeDefaultZLevels()

	// load the station
	station_start = world.maxz + 1
	INIT_ANNOUNCE("Loading [config.map_name]...")
	LoadGroup(FailedZs, "Station", config.map_path, config.map_file, config.traits, ZTRAITS_STATION)

	if(SSdbcore.Connect())
		var/datum/DBQuery/query_round_map_name = SSdbcore.NewQuery({"
			UPDATE [format_table_name("round")] SET map_name = :map_name WHERE id = :round_id
		"}, list("map_name" = config.map_name, "round_id" = GLOB.round_id))
		query_round_map_name.Execute()
		qdel(query_round_map_name)

#ifndef LOWMEMORYMODE
	// TODO: remove this when the DB is prepared for the z-levels getting reordered
	while (world.maxz < (5 - 1) && space_levels_so_far < config.space_ruin_levels)
		++space_levels_so_far
		add_new_zlevel("Empty Area [space_levels_so_far]", ZTRAITS_SPACE)

	// load mining
	if(config.minetype == "lavaland")
		LoadGroup(FailedZs, "Lavaland", "map_files/mining", "Lavaland.dmm", default_traits = ZTRAITS_LAVALAND) //Yogs, yoglavaland
		GLOB.minetype = MINETYPE_LAVALAND
	//Yogs begin, jungleland gen
	else if(config.minetype == "jungleland")
		LoadGroup(FailedZs, "Jungleland", "map_files/mining", "Jungleland.dmm", default_traits = ZTRAITS_JUNGLELAND)
		GLOB.minetype = MINETYPE_JUNGLE
		
	else if(config.minetype == "jungle_and_lavaland")
		SSpersistence.LoadMinetype()
		var/determinant = SSpersistence.next_minetype
		switch(determinant)
			if(2)
				if(prob(50))
					LoadGroup(FailedZs, "Lavaland", "map_files/mining", "Lavaland.dmm", default_traits = ZTRAITS_LAVALAND)
					GLOB.minetype = MINETYPE_LAVALAND
				else 
					LoadGroup(FailedZs, "Jungleland", "map_files/mining", "Jungleland.dmm", default_traits = ZTRAITS_JUNGLELAND) 
					GLOB.minetype = MINETYPE_JUNGLE
			
			if(1)
				LoadGroup(FailedZs, "Lavaland", "map_files/mining", "Lavaland.dmm", default_traits = ZTRAITS_LAVALAND)
				GLOB.minetype = MINETYPE_LAVALAND
			
			if(0)
				LoadGroup(FailedZs, "Jungleland", "map_files/mining", "Jungleland.dmm", default_traits = ZTRAITS_JUNGLELAND)
				GLOB.minetype = MINETYPE_JUNGLE
			 
	//Yogs end
	else if (!isnull(config.minetype) && config.minetype != "none")
		INIT_ANNOUNCE("WARNING: An unknown minetype '[config.minetype]' was set! This is being ignored! Update the maploader code!")

	LoadGroup(FailedZs, "Automated Exploration Hub", "RandomZLevels/VR", "netmin_hub.dmm", default_traits = ZTRAITS_AWAY_SECRET)
#endif

	if(LAZYLEN(FailedZs))	//but seriously, unless the server's filesystem is messed up this will never happen
		var/msg = "RED ALERT! The following map files failed to load: [FailedZs[1]]"
		if(FailedZs.len > 1)
			for(var/I in 2 to FailedZs.len)
				msg += ", [FailedZs[I]]"
		msg += ". Yell at your server host!"
		INIT_ANNOUNCE(msg)
#undef INIT_ANNOUNCE

GLOBAL_LIST_EMPTY(the_station_areas)

/datum/controller/subsystem/mapping/proc/generate_station_area_list()
	var/list/station_areas_blacklist = typecacheof(list(/area/space, /area/mine, /area/ruin, /area/asteroid/nearstation))
	for(var/area/A in GLOB.areas)
		if (is_type_in_typecache(A, station_areas_blacklist))
			continue
		if (!A.contents.len || !A.unique)
			continue
		var/turf/picked = A.contents[1]
		if (is_station_level(picked.z))
			GLOB.the_station_areas += A.type

	if(!GLOB.the_station_areas.len)
		log_world("ERROR: Station areas list failed to generate!")

/datum/controller/subsystem/mapping/proc/run_map_generation()
	for(var/area/A as anything in GLOB.areas)
		A.RunGeneration()

/datum/controller/subsystem/mapping/proc/maprotate()
	if(map_voted)
		map_voted = FALSE
		return

	var/players = GLOB.clients.len
	var/list/mapvotes = list()
	//count votes
	var/pmv = CONFIG_GET(flag/preference_map_voting)
	if(pmv)
		for (var/client/c in GLOB.clients)
			var/vote = c.prefs.read_preference(/datum/preference/choiced/preferred_map)
			if (!vote)
				if (global.config.defaultmap)
					mapvotes[global.config.defaultmap.map_name] += 1
				continue
			mapvotes[vote] += 1
	else
		for(var/M in global.config.maplist)
			mapvotes[M] = 1
	var/previous_maps = get_map_weights()

	//filter votes
	for (var/map in mapvotes)
		if (!map)
			mapvotes.Remove(map)
		if (!(map in global.config.maplist))
			mapvotes.Remove(map)
			continue
		var/datum/map_config/VM = global.config.maplist[map]
		if (!VM)
			mapvotes.Remove(map)
			continue
		if (VM.voteweight <= 0)
			mapvotes.Remove(map)
			continue
		if (VM.config_min_users > 0 && players < VM.config_min_users)
			mapvotes.Remove(map)
			continue
		if (VM.config_max_users > 0 && players > VM.config_max_users)
			mapvotes.Remove(map)
			continue
		if(previous_maps[VM.map_name] > 7)
			mapvotes.Remove(map)
			continue

		if(pmv)
			mapvotes[map] = mapvotes[map]*VM.voteweight

	var/pickedmap = pickweight(mapvotes)
	if (!pickedmap)
		return
	var/datum/map_config/VM = global.config.maplist[pickedmap]
	message_admins("Randomly rotating map to [VM.map_name].")
	. = changemap(VM)
	if (. && VM.map_name != config.map_name)
		to_chat(world, span_boldannounce("Map rotation has chosen [VM.map_name] for next round!"))

/datum/controller/subsystem/mapping/proc/changemap(datum/map_config/change_to)
	if(!change_to.MakeNextMap())
		next_map_config = load_default_map_config()
		message_admins("Failed to set new map with next_map.json for [change_to.map_name]! Using default as backup!")
		return

	var/filter_threshold = get_active_player_count(alive_check = FALSE, afk_check = TRUE, human_check = FALSE)
	if (change_to.config_min_users > 0 && filter_threshold != 0 && filter_threshold < change_to.config_min_users)
		message_admins("[change_to.map_name] was chosen for the next map, despite there being less current players than its set minimum population range!")
		log_game("[change_to.map_name] was chosen for the next map, despite there being less current players than its set minimum population range!")
	if (change_to.config_max_users > 0 && filter_threshold > change_to.config_max_users)
		message_admins("[change_to.map_name] was chosen for the next map, despite there being more current players than its set maximum population range!")
		log_game("[change_to.map_name] was chosen for the next map, despite there being more current players than its set maximum population range!")

	next_map_config = change_to
	return TRUE

/datum/controller/subsystem/mapping/proc/preloadTemplates(path = "_maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

	preloadRuinTemplates()
	preloadShuttleTemplates()
	preloadShelterTemplates()

/datum/controller/subsystem/mapping/proc/preloadRuinTemplates()
	// Still supporting bans by filename
	var/list/banned = generateMapList("[global.config.directory]/lavaruinblacklist.txt")
	banned += generateMapList("[global.config.directory]/spaceruinblacklist.txt")
	banned += generateMapList("[global.config.directory]/iceruinblacklist.txt")
	banned += generateMapList("[global.config.directory]/jungleruinblacklist.txt")

	for(var/item in sortList(subtypesof(/datum/map_template/ruin), /proc/cmp_ruincost_priority))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		if(banned.Find(R.mappath))
			continue

		map_templates[R.name] = R
		ruins_templates[R.name] = R


		if(istype(R, /datum/map_template/ruin/lavaland))
			lava_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/icemoon/underground))
			ice_ruins_underground_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/icemoon))
			ice_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/space))
			space_ruins_templates[R.name] = R
		//Yogs begin
		else if(istype(R, /datum/map_template/ruin/station)) 
			station_room_templates[R.name] = R 
		else if(istype(R,/datum/map_template/ruin/jungle/proper))
			jungleland_proper_ruins_templates[R.name] = R
		else if(istype(R,/datum/map_template/ruin/jungle/dying))
			jungleland_dying_ruins_templates[R.name] = R
		else if(istype(R,/datum/map_template/ruin/jungle/swamp))
			jungleland_swamp_ruins_templates[R.name] = R
		else if(istype(R,/datum/map_template/ruin/jungle/barren))
			jungleland_barren_ruins_templates[R.name] = R
		else if(istype(R,/datum/map_template/ruin/jungle/all))
			jungleland_general_ruins_templates[R.name] = R
		//Yogs end

/datum/controller/subsystem/mapping/proc/preloadShuttleTemplates()
	var/list/unbuyable = generateMapList("unbuyableshuttles.txt")

	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!(initial(shuttle_type.suffix)))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()
		if(unbuyable.Find(S.mappath))
			S.credit_cost = INFINITY
			S.who_can_purchase = null

		shuttle_templates[S.shuttle_id] = S
		map_templates[S.shuttle_id] = S

/datum/controller/subsystem/mapping/proc/preloadShelterTemplates()
	for(var/item in subtypesof(/datum/map_template/shelter))
		var/datum/map_template/shelter/shelter_type = item
		if(!(initial(shelter_type.mappath)))
			continue
		var/datum/map_template/shelter/S = new shelter_type()

		shelter_templates[S.shelter_id] = S
		map_templates[S.shelter_id] = S

//Manual loading of away missions.
/client/proc/admin_away()
	set name = "Load Away Mission"
	set category = "Misc.Server Debug"

	if(!holder ||!check_rights(R_FUN))
		return


	if(!GLOB.the_gateway)
		if(tgui_alert(usr, "There's no home gateway on the station. You sure you want to continue ?", "Uh oh", list("Yes", "No")) != "Yes")
			return

	var/list/possible_options = GLOB.potentialRandomZlevels + "Custom"
	var/away_name
	var/datum/space_level/away_level
	var/secret = FALSE
	if(tgui_alert(usr, "Do you want your mission secret? (This will prevent ghosts from looking at your map in any way other than through a living player's eyes.)", "Are you $$$ekret?", list("Yes", "No")) != "No")
		secret = TRUE
	var/answer = input("What kind?","Away") as null|anything in possible_options
	switch(answer)
		if("Custom")
			var/mapfile = input("Pick file:", "File") as null|file
			if(!mapfile)
				return
			away_name = "[mapfile] custom"
			to_chat(usr,span_notice("Loading [away_name]..."))
			var/datum/map_template/template = new(mapfile, "Away Mission")
			away_level = template.load_new_z(secret)
		else
			if(answer in GLOB.potentialRandomZlevels)
				away_name = answer
				to_chat(usr,span_notice("Loading [away_name]..."))
				var/datum/map_template/template = new(away_name, "Away Mission")
				away_level = template.load_new_z(secret)
			else
				return

	message_admins("Admin [key_name_admin(usr)] has loaded [away_name] away mission.")
	log_admin("Admin [key_name(usr)] has loaded [away_name] away mission.")
	if(!away_level)
		message_admins("Loading [away_name] failed!")
		return


	if(GLOB.the_gateway)
		//Link any found away gate with station gate
		var/obj/machinery/gateway/centeraway/new_gate
		for(var/obj/machinery/gateway/centeraway/G in GLOB.machines)
			if(G.z == away_level.z_value) //I'll have to refactor gateway shitcode before multi-away support.
				new_gate = G
				break
		//Link station gate with away gate and remove wait time.
		GLOB.the_gateway.awaygate = new_gate
		GLOB.the_gateway.wait = world.time

/// Adds a new reservation z level. A bit of space that can be handed out on request
/// Of note, reservations default to transit turfs, to make their most common use, shuttles, faster
/datum/controller/subsystem/mapping/proc/add_reservation_zlevel(for_shuttles)
	num_of_res_levels++
	return add_new_zlevel("Transit/Reserved #[num_of_res_levels]", list(ZTRAIT_RESERVED = TRUE))

/// Requests a /datum/turf_reservation based on the given width, height, and z_size. You can specify a z_reservation to use a specific z level, or leave it null to use any z level.
/datum/controller/subsystem/mapping/proc/request_turf_block_reservation(
	width,
	height,
	z_size = 1,
	z_reservation = null,
	reservation_type = /datum/turf_reservation,
	turf_type_override = null,
)
	UNTIL((!z_reservation || reservation_ready["[z_reservation]"]) && !clearing_reserved_turfs)
	var/datum/turf_reservation/reserve = new reservation_type
	if(!isnull(turf_type_override))
		reserve.turf_type = turf_type_override
	if(!z_reservation)
		for(var/i in levels_by_trait(ZTRAIT_RESERVED))
			if(reserve.reserve(width, height, z_size, i))
				return reserve
		//If we didn't return at this point, theres a good chance we ran out of room on the exisiting reserved z levels, so lets try a new one
		var/datum/space_level/newReserved = add_reservation_zlevel()
		initialize_reserved_level(newReserved.z_value)
		if(reserve.reserve(width, height, z_size, newReserved.z_value))
			return reserve
	else
		if(!level_trait(z_reservation, ZTRAIT_RESERVED))
			qdel(reserve)
			return
		else
			if(reserve.reserve(width, height, z_size, z_reservation))
				return reserve
	QDEL_NULL(reserve)

///Sets up a z level as reserved
///This is not for wiping reserved levels, use wipe_reservations() for that.
///If this is called after SSatom init, it will call Initialize on all turfs on the passed z, as its name promises
/datum/controller/subsystem/mapping/proc/initialize_reserved_level(z)
	UNTIL(!clearing_reserved_turfs) //regardless, lets add a check just in case.
	clearing_reserved_turfs = TRUE //This operation will likely clear any existing reservations, so lets make sure nothing tries to make one while we're doing it.
	if(!level_trait(z,ZTRAIT_RESERVED))
		clearing_reserved_turfs = FALSE
		CRASH("Invalid z level prepared for reservations.")
	var/turf/A = get_turf(locate(SHUTTLE_TRANSIT_BORDER,SHUTTLE_TRANSIT_BORDER,z))
	var/turf/B = get_turf(locate(world.maxx - SHUTTLE_TRANSIT_BORDER,world.maxy - SHUTTLE_TRANSIT_BORDER,z))
	var/block = block(A, B)
	for(var/turf/T as anything in block)
		// No need to empty() these, because they just got created and are already /turf/open/space/basic.
		T.turf_flags = UNUSED_RESERVATION_TURF
		CHECK_TICK

	// Gotta create these suckers if we've not done so already
	if(SSatoms.initialized)
		SSatoms.InitializeAtoms(Z_TURFS(z))

	unused_turfs["[z]"] = block
	reservation_ready["[z]"] = TRUE
	clearing_reserved_turfs = FALSE

/// Schedules a group of turfs to be handed back to the reservation system's control
/// If await is true, will sleep until the turfs are finished work
/datum/controller/subsystem/mapping/proc/reserve_turfs(list/turfs, await = FALSE)
	lists_to_reserve += list(turfs)
	if(await)
		UNTIL(!length(turfs))

//DO NOT CALL THIS PROC DIRECTLY, CALL wipe_reservations().
/datum/controller/subsystem/mapping/proc/do_wipe_turf_reservations()
	PRIVATE_PROC(TRUE)
	UNTIL(initialized) //This proc is for AFTER init, before init turf reservations won't even exist and using this will likely break things.
	for(var/i in turf_reservations)
		var/datum/turf_reservation/TR = i
		if(!QDELETED(TR))
			qdel(TR, TRUE)
	UNSETEMPTY(turf_reservations)
	var/list/clearing = list()
	for(var/l in unused_turfs) //unused_turfs is an assoc list by z = list(turfs)
		if(islist(unused_turfs[l]))
			clearing |= unused_turfs[l]
	clearing |= used_turfs //used turfs is an associative list, BUT, reserve_turfs() can still handle it. If the code above works properly, this won't even be needed as the turfs would be freed already.
	unused_turfs.Cut()
	used_turfs.Cut()
	reserve_turfs(clearing, await = TRUE)

///Initialize all biomes, assoc as type || instance
/datum/controller/subsystem/mapping/proc/initialize_biomes()
	for(var/biome_path in subtypesof(/datum/biome))
		var/datum/biome/biome_instance = new biome_path()
		biomes[biome_path] += biome_instance

/datum/controller/subsystem/mapping/proc/build_minimaps()
	to_chat(world, span_boldannounce("Building minimaps..."))
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		station_minimaps += new /datum/minimap(z)

/datum/controller/subsystem/mapping/proc/reg_in_areas_in_z(list/areas)
	for(var/B in areas)
		var/area/A = B
		A.reg_in_areas_in_z()

/// Takes a z level datum, and tells the mapping subsystem to manage it
/// Also handles things like plane offset generation, and other things that happen on a z level to z level basis
/datum/controller/subsystem/mapping/proc/manage_z_level(datum/space_level/new_z, filled_with_space, contain_turfs = TRUE)
	// First, add the z
	z_list += new_z

	// Then we build our lookup lists
	var/z_value = new_z.z_value
	// We are guarenteed that we'll always grow bottom up
	// Suck it jannies
	z_level_to_plane_offset.len += 1
	z_level_to_lowest_plane_offset.len += 1
	gravity_by_z_level.len += 1
	z_level_to_stack.len += 1
	//Bare minimum we have ourselves
	z_level_to_stack[z_value] = list(z_value)
	//0's the default value, we'll update it later if required
	z_level_to_plane_offset[z_value] = 0
	z_level_to_lowest_plane_offset[z_value] = 0

	// Now we check if this plane is offset or not
	var/below_offset = new_z.traits[ZTRAIT_DOWN]
	if(below_offset)
		update_plane_tracking(new_z)

	if(contain_turfs)
		build_area_turfs(z_value, filled_with_space)

	// And finally, misc global generation

	// We'll have to update this if offsets change, because we load lowest z to highest z
	generate_lighting_appearance_by_z(z_value)

/datum/controller/subsystem/mapping/proc/build_area_turfs(z_level, space_guaranteed)
	// If we know this is filled with default tiles, we can use the default area
	// Faster
	if(space_guaranteed)
		var/area/global_area = GLOB.areas_by_type[world.area]
		global_area.contained_turfs += Z_TURFS(z_level)
		return

	for(var/turf/to_contain as anything in Z_TURFS(z_level))
		var/area/our_area = to_contain.loc
		our_area.contained_turfs += to_contain

/datum/controller/subsystem/mapping/proc/update_plane_tracking(datum/space_level/update_with)
	// We're essentially going to walk down the stack of connected z levels, and set their plane offset as we go
	var/plane_offset = 0
	var/datum/space_level/current_z = update_with
	var/list/datum/space_level/levels_checked = list()
	var/list/z_stack = list()
	while(TRUE)
		var/z_level = current_z.z_value
		z_stack += z_level
		z_level_to_plane_offset[z_level] = plane_offset
		levels_checked += current_z
		if(!current_z.traits[ZTRAIT_DOWN]) // If there's nothing below, stop looking
			break
		// Otherwise, down down down we go
		current_z = z_list[z_level - 1]
		plane_offset += 1

	/// Updates the lowest offset value
	for(var/datum/space_level/level_to_update in levels_checked)
		z_level_to_lowest_plane_offset[level_to_update.z_value] = plane_offset
		z_level_to_stack[level_to_update.z_value] = z_stack

	// This can be affected by offsets, so we need to update it
	// PAIN
	for(var/i in 1 to length(z_list))
		generate_lighting_appearance_by_z(i)

	var/old_max = max_plane_offset
	max_plane_offset = max(max_plane_offset, plane_offset)
	if(max_plane_offset == old_max)
		return

	generate_offset_lists(old_max + 1, max_plane_offset)
	SEND_SIGNAL(src, COMSIG_PLANE_OFFSET_INCREASE, old_max, max_plane_offset)
	// Sanity check
	if(max_plane_offset > MAX_EXPECTED_Z_DEPTH)
		stack_trace("We've loaded a map deeper then the max expected z depth. Preferences won't cover visually disabling all of it!")

/// Takes an offset to generate misc lists to, and a base to start from
/// Use this to react globally to maintain parity with plane offsets
/datum/controller/subsystem/mapping/proc/generate_offset_lists(gen_from, new_offset)
	create_plane_offsets(gen_from, new_offset)
	for(var/offset in gen_from to new_offset)
		GLOB.starlight_objects += starlight_object(offset)
		GLOB.starlight_overlays += starlight_overlay(offset)

	// [Yog] pretty sure auxmos would shit if this was included
	// for(var/datum/gas/gas_type as anything in GLOB.meta_gas_info)
	// 	var/list/gas_info = GLOB.meta_gas_info[gas_type]
	// 	if(initial(gas_type.moles_visible) != null)
	// 		gas_info[META_GAS_OVERLAY] += generate_gas_overlays(gen_from, new_offset, gas_type)

/datum/controller/subsystem/mapping/proc/create_plane_offsets(gen_from, new_offset)
	for(var/plane_offset in gen_from to new_offset)
		for(var/atom/movable/screen/plane_master/master_type as anything in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/rendering_plate)
			var/plane_to_use = initial(master_type.plane)
			var/string_real = "[plane_to_use]"

			var/offset_plane = GET_NEW_PLANE(plane_to_use, plane_offset)
			var/string_plane = "[offset_plane]"

			if(!initial(master_type.allows_offsetting))
				plane_offset_blacklist[string_plane] = TRUE
				var/render_target = initial(master_type.render_target)
				if(!render_target)
					render_target = get_plane_master_render_base(initial(master_type.name))
				render_offset_blacklist[render_target] = TRUE
				if(plane_offset != 0)
					continue

			if(initial(master_type.critical) & PLANE_CRITICAL_DISPLAY)
				critical_planes[string_plane] = TRUE

			plane_offset_to_true[string_plane] = plane_to_use
			plane_to_offset[string_plane] = plane_offset

			if(!true_to_offset_planes[string_real])
				true_to_offset_planes[string_real] = list()

			true_to_offset_planes[string_real] |= offset_plane

/// Takes a turf or a z level, and returns a list of all the z levels that are connected to it
/datum/controller/subsystem/mapping/proc/get_connected_levels(turf/connected)
	var/z_level = connected
	if(isturf(z_level))
		z_level = connected.z
	return z_level_to_stack[z_level]

/datum/controller/subsystem/mapping/proc/lazy_load_template(template_key, force = FALSE)
	RETURN_TYPE(/datum/turf_reservation)

	UNTIL(initialized)
	var/static/lazy_loading = FALSE
	UNTIL(!lazy_loading)

	lazy_loading = TRUE
	. = _lazy_load_template(template_key, force)
	lazy_loading = FALSE
	return .

/datum/controller/subsystem/mapping/proc/_lazy_load_template(template_key, force = FALSE)
	PRIVATE_PROC(TRUE)

	if(LAZYACCESS(loaded_lazy_templates, template_key)  && !force)
		var/datum/lazy_template/template = GLOB.lazy_templates[template_key]
		return template.reservations[1]
	LAZYSET(loaded_lazy_templates, template_key, TRUE)

	var/datum/lazy_template/target = GLOB.lazy_templates[template_key]
	if(!target)
		CRASH("Attempted to lazy load a template key that does not exist: '[template_key]'")
	return target.lazy_load()

/proc/generate_lighting_appearance_by_z(z_level)
	if(length(GLOB.default_lighting_underlays_by_z) < z_level)
		GLOB.default_lighting_underlays_by_z.len = z_level
	GLOB.default_lighting_underlays_by_z[z_level] = mutable_appearance(LIGHTING_ICON, "transparent", z_level * 0.01, null, LIGHTING_PLANE, 255, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM, offset_const = GET_Z_PLANE_OFFSET(z_level))

/// Returns true if the map we're playing on is on a planet
/datum/controller/subsystem/mapping/proc/is_planetary()
	return config.planetary

/datum/controller/subsystem/mapping/proc/get_map_weights()
	var/list/previous_maps = list()
	if(SSdbcore.Connect())
		var/datum/DBQuery/query_previous_maps = SSdbcore.NewQuery({"
			SELECT map_name FROM [format_table_name("round")] WHERE id BETWEEN lower = :lower AND upper = :upper
		"}, list("lower" = "[text2num(GLOB.round_id) - 9]", "upper" = GLOB.round_id))
		if(!query_previous_maps.Execute())
			qdel(query_previous_maps)
		for(var/i = 1 to 10)
			var/next_map = query_previous_maps.NextRow()
			if(!next_map)
				continue
			previous_maps[next_map[1]] += 1 / (11 - i) //this lessens the influence of rounds that were longer ago
		qdel(query_previous_maps)
	return previous_maps

/client/proc/debug_map_weights()
	set name = "See Map Weights"
	set category = "Misc.Server Debug"
	var/weights = SSmapping.get_map_weights()
	if(!length(weights))
		to_chat(src, "Map Weights list is empty.")
		return
	for(var/key in weights)
		to_chat(src, "[key]: [weights[key]]")
