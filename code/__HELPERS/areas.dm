#define BP_MAX_ROOM_SIZE 300

//Yogs start -- Fixes a very esoteric, mostly-hypothetical bug involving the fact that the /TG/ version doesn't use list() here
GLOBAL_LIST_INIT(typecache_powerfailure_safe_areas, typecacheof(list(/area/engine/engineering,
															    /area/engine/supermatter,
															    /area/engine/atmos/engine,
															    /area/ai_monitored/turret_protected/ai)))
//Yogs end

// Gets an atmos isolated contained space
// Returns an associative list of turf|dirs pairs
// The dirs are connected turfs in the same space
// break_if_found is a typecache of turf/area types to return false if found
// Please keep this proc type agnostic. If you need to restrict it do it elsewhere or add an arg.
/proc/detect_room(turf/origin, list/break_if_found, max_size=INFINITY)
	if(origin.blocks_air)
		return list(origin)

	. = list()
	var/list/checked_turfs = list()
	var/list/found_turfs = list(origin)
	while(found_turfs.len)
		var/turf/sourceT = found_turfs[1]
		found_turfs.Cut(1, 2)
		var/dir_flags = checked_turfs[sourceT]
		for(var/dir in GLOB.alldirs)
			if(length(.) > max_size)
				return
			if(dir_flags & dir) // This means we've checked this dir before, probably from the other turf
				continue
			var/turf/checkT = get_step(sourceT, dir)
			if(!checkT)
				continue
			checked_turfs[sourceT] |= dir
			checked_turfs[checkT] |= turn(dir, 180)
			.[sourceT] |= dir
			.[checkT] |= turn(dir, 180)
			if(break_if_found[checkT.type] || break_if_found[checkT.loc.type])
				return FALSE
			var/static/list/cardinal_cache = list("[NORTH]"=TRUE, "[EAST]"=TRUE, "[SOUTH]"=TRUE, "[WEST]"=TRUE)
			if(!cardinal_cache["[dir]"] || checkT.blocks_air || !CANATMOSPASS(sourceT, checkT))
				continue
			found_turfs += checkT // Since checkT is connected, add it to the list to be processed

/proc/create_area(mob/creator)
	// Passed into the above proc as list/break_if_found
	var/static/area_or_turf_fail_types = typecacheof(list(
		/turf/open/space,
		/area/shuttle,
		))
	// Ignore these areas and dont let people expand them. They can expand into them though
	var/static/blacklisted_areas = typecacheof(list(
		/area/space,
		))
	var/list/turfs = detect_room(get_turf(creator), area_or_turf_fail_types, BP_MAX_ROOM_SIZE*2)
	if(!turfs)
		to_chat(creator, span_warning("The new area must be completely airtight and not a part of a shuttle."))
		return
	if(turfs.len > BP_MAX_ROOM_SIZE)
		to_chat(creator, span_warning("The room you're in is too big. It is [turfs.len >= BP_MAX_ROOM_SIZE *2 ? "more than 100" : ((turfs.len / BP_MAX_ROOM_SIZE)-1)*100]% larger than allowed."))
		return
	var/list/areas = list("New Area" = /area)
	for(var/i in 1 to turfs.len)
		var/area/place = get_area(turfs[i])
		if(blacklisted_areas[place.type])
			continue
		if(!place.requires_power || place.noteleport || place.hidden)
			continue // No expanding powerless rooms etc
		areas[place.name] = place
	var/area_choice = input(creator, "Choose an area to expand or make a new area.", "Area Expansion") as null|anything in areas
	area_choice = areas[area_choice]

	if(!area_choice)
		to_chat(creator, span_warning("No choice selected. The area remains undefined."))
		return
	var/area/newA
	var/area/oldA = get_area(get_turf(creator))
	if(!isarea(area_choice))
		var/str = stripped_input(creator,"New area name:", "Blueprint Editing", "", MAX_NAME_LEN)
		if(!str || !length(str)) //cancel
			return
		if(length(str) > 50)
			to_chat(creator, span_warning("The given name is too long. The area remains undefined."))
			return
		newA = new area_choice
		newA.setup(str)
		newA.set_dynamic_lighting()
		newA.has_gravity = oldA.has_gravity
	else
		newA = area_choice

	for(var/i in 1 to turfs.len)
		var/turf/thing = turfs[i]
		var/area/old_area = thing.loc
		old_area.turfs_to_uncontain += thing
		newA.contents += thing
		newA.contained_turfs += thing
		thing.change_area(old_area, newA)

	newA.reg_in_areas_in_z()

	var/list/firedoors = oldA.firedoors
	for(var/door in firedoors)
		var/obj/machinery/door/firedoor/FD = door
		FD.CalculateAffectingAreas()

	to_chat(creator, span_notice("You have created a new area, named [newA.name]. It is now weather proof, and constructing an APC will allow it to be powered."))
	return TRUE

/proc/require_area_resort()
	GLOB.sortedAreas = null

/// Returns a sorted version of GLOB.areas, by name
/proc/get_sorted_areas()
	if(!GLOB.sortedAreas)
		GLOB.sortedAreas = sortTim(GLOB.areas.Copy(), /proc/cmp_name_asc)
	return GLOB.sortedAreas

//Takes: Area type as a text string from a variable.
//Returns: Instance for the area in the world.
/proc/get_area_instance_from_text(areatext)
	if(istext(areatext))
		areatext = text2path(areatext)
	return GLOB.areas_by_type[areatext]

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype, subtypes=TRUE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/areas = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/area/area_to_check as anything in GLOB.areas)
			if(cache[area_to_check.type])
				areas += area_to_check
	else
		for(var/area/area_to_check as anything in GLOB.areas)
			if(area_to_check.type == areatype)
				areas += area_to_check
	return areas

/// Iterates over all turfs in the target area and returns the first non-dense one
/proc/get_first_open_turf_in_area(area/target)
	if(!target)
		return
	for(var/turf/turf in target)
		if(!turf.density)
			return turf

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype, target_z = 0, subtypes=FALSE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null
	// Pull out the areas
	var/list/areas_to_pull = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/area/area_to_check as anything in GLOB.areas)
			if(!cache[area_to_check.type])
				continue
			areas_to_pull += area_to_check
	else
		for(var/area/area_to_check as anything in GLOB.areas)
			if(area_to_check.type != areatype)
				continue
			areas_to_pull += area_to_check

	// Now their turfs
	var/list/turfs = list()
	for(var/area/pull_from as anything in areas_to_pull)
		var/list/our_turfs = pull_from.get_contained_turfs()
		if(target_z == 0)
			turfs += our_turfs
		else
			for(var/turf/turf_in_area as anything in our_turfs)
				if(target_z == turf_in_area.z)
					turfs += turf_in_area
	return turfs


///Takes: list of area types
///Returns: all mobs that are in an area type
/proc/mobs_in_area_type(list/area/checked_areas)
	var/list/mobs_in_area = list()
	for(var/mob/living/mob as anything in GLOB.mob_living_list)
		if(QDELETED(mob))
			continue
		for(var/area in checked_areas)
			if(istype(get_area(mob), area))
				mobs_in_area += mob
				break
	return mobs_in_area

#undef BP_MAX_ROOM_SIZE
