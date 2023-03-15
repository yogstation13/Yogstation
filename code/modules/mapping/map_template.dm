/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/loaded = 0 // Times loaded this round
	var/datum/parsed_map/cached_map
	var/keep_cached_map = FALSE

/datum/map_template/New(path = null, rename = null, cache = FALSE)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath, cache)
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path, cache = FALSE)
	var/datum/parsed_map/parsed = new(file(path))
	var/bounds = parsed?.bounds
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
		if(cache)
			cached_map = parsed
	return bounds

/datum/map_template/proc/initTemplateBounds(list/bounds)
	if (!bounds) //something went wrong
		stack_trace("[name] template failed to initialize correctly!")
		return

	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/obj/structure/ethernet_cable/ethernet_cables = list()
	var/list/atom/movable/movables = list()
	var/list/obj/docking_port/stationary/ports = list()
	var/list/area/areas = list()

	var/list/turfs = block(
		locate(
			bounds[MAP_MINX],
			bounds[MAP_MINY],
			bounds[MAP_MINZ]
			),
		locate(
			bounds[MAP_MAXX],
			bounds[MAP_MAXY],
			bounds[MAP_MAXZ]
			)
		)
	for(var/turf/current_turf as anything in turfs)
		var/area/current_turfs_area = current_turf.loc
		areas |= current_turfs_area
		if(!SSatoms.initialized)
			continue

		for(var/movable_in_turf in current_turf)
			if(istype(movable_in_turf, /obj/docking_port/mobile))
				continue // mobile docking ports need to be initialized after their template has finished loading, to ensure that their bounds are setup
			movables += movable_in_turf
			if(istype(movable_in_turf, /obj/structure/cable))
				cables += movable_in_turf
				continue
			if(istype(movable_in_turf, /obj/structure/ethernet_cable))
				ethernet_cables += movable_in_turf
				continue
			if(istype(movable_in_turf, /obj/machinery/atmospherics))
				atmos_machines += movable_in_turf
			if(istype(movable_in_turf, /obj/docking_port/stationary))
				ports += movable_in_turf

	// Not sure if there is some importance here to make sure the area is in z
	// first or not.  Its defined In Initialize yet its run first in templates
	// BEFORE so... hummm
	SSmapping.reg_in_areas_in_z(areas)
	//SSnetworks.assign_areas_root_ids(areas, src)
	if(!SSatoms.initialized)
		return

	SSatoms.InitializeAtoms(areas + turfs + movables)

	for(var/turf/unlit as anything in turfs)
		var/area/loc_area = unlit.loc
		if(!IS_DYNAMIC_LIGHTING(loc_area))
			continue
		unlit.lighting_build_overlay()

	// NOTE, now that Initialize and LateInitialize run correctly, do we really
	// need these two below?
	SSmachines.setup_template_powernets(cables)
	SSmachines.setup_template_ainets(ethernet_cables)
	SSair.setup_template_machinery(atmos_machines)
	SSshuttle.setup_shuttles(ports)

	//calculate all turfs inside the border
	var/list/template_and_bordering_turfs = block(
		locate(
			max(bounds[MAP_MINX]-1, 1),
			max(bounds[MAP_MINY]-1, 1),
			bounds[MAP_MINZ]
			),
		locate(
			min(bounds[MAP_MAXX]+1, world.maxx),
			min(bounds[MAP_MAXY]+1, world.maxy),
			bounds[MAP_MAXZ]
			)
		)
	for(var/turf/affected_turf as anything in template_and_bordering_turfs)
		affected_turf.air_update_turf(TRUE, TRUE)
		affected_turf.levelupdate()

/datum/map_template/proc/load_new_z(secret = FALSE)
	var/x = round((world.maxx - width)/2)
	var/y = round((world.maxy - height)/2)

	var/datum/space_level/level = SSmapping.add_new_zlevel(name, secret ? ZTRAITS_AWAY_SECRET : ZTRAITS_AWAY, contain_turfs = FALSE)
	var/datum/parsed_map/parsed = load_map(file(mappath), x, y, level.z_value, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=TRUE, new_z = TRUE)
	var/list/bounds = parsed.bounds
	if(!bounds)
		return FALSE

	require_area_resort()
	//initialize things that are normally initialized after map load
	initTemplateBounds(bounds)
	smooth_zlevel(world.maxz)
	log_game("Z-level [name] loaded at at [x],[y],[world.maxz]")

	return level

/datum/map_template/proc/load(turf/T, centered = FALSE)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if((T.x+width) - 1 > world.maxx)
		return
	if((T.y+height) - 1 > world.maxy)
		return

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	var/datum/parsed_map/parsed = cached_map || new(file(mappath))
	cached_map = keep_cached_map ? parsed : null
	if(!parsed.load(T.x, T.y, T.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=TRUE))
		return
	var/list/bounds = parsed.bounds
	if(!bounds)
		return

	require_area_resort()

	//initialize things that are normally initialized after map load
	initTemplateBounds(bounds)

	log_game("[name] loaded at at [T.x],[T.y],[T.z]")
	return bounds

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))


//for your ever biggening badminnery kevinz000
//❤ - Cyberboss

/proc/load_new_z_level(file, name, secret)
	var/datum/map_template/template = new(file, name, TRUE)
	if(!template.cached_map || template.cached_map.check_for_errors())
		return FALSE
	template.load_new_z(secret)
	return TRUE
