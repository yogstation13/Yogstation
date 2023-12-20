// This is a list of turf types we dont want to assign to baseturfs unless through initialization or explicitly
GLOBAL_LIST_INIT(blacklisted_automated_baseturfs, typecacheof(list(
	/turf/open/space,
	/turf/baseturf_bottom,
)))

/turf/proc/empty(turf_type=/turf/open/space, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port))
	var/list/allowed_contents = typecache_filter_list_reverse(get_all_contentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		ChangeTurf(turf_type, baseturf_type, flags)

/turf/proc/copyTurf(turf/T, copy_air, flags)
	if(T.type != type)
		T.ChangeTurf(type, null, flags)
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	return T

/turf/open/copyTurf(turf/T, copy_air = FALSE)
	. = ..()
	if (isopenturf(T))
		var/datum/component/wet_floor/slip = GetComponent(/datum/component/wet_floor)
		if(slip)
			var/datum/component/wet_floor/WF = T.AddComponent(/datum/component/wet_floor)
			WF.InheritComponent(slip)
		if (copy_air)
			var/turf/open/openTurf = T
			openTurf.air.copy_from(air)

//wrapper for ChangeTurf()s that you want to prevent/affect without overriding ChangeTurf() itself
/turf/proc/TerraformTurf(path, new_baseturf, flags)
	return ChangeTurf(path, new_baseturf, flags)

/turf/proc/get_z_base_turf()
	. = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/open/space
	if (!ispath(.))
		. = text2path(.)
		if (!ispath(.))
			warning("Z-level [z] has invalid baseturf '[SSmapping.level_trait(z, ZTRAIT_BASETURF)]'")
			. = /turf/open/space

// Creates a new turf
// new_baseturfs can be either a single type or list of types, formated the same as baseturfs. see turf.dm
/turf/proc/ChangeTurf(path, list/new_baseturfs, flags)
	switch(path)
		if(null)
			return
		if(/turf/baseturf_bottom)
			path = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/open/space
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					warning("Z-level [z] has invalid baseturf '[SSmapping.level_trait(z, ZTRAIT_BASETURF)]'")
					path = /turf/open/space
		if(/turf/open/space/basic)
			// basic doesn't initialize and this will cause issues
			// no warning though because this can happen naturaly as a result of it being built on top of
			path = /turf/open/space

	if(!GLOB.use_preloader && path == type && !(flags & CHANGETURF_FORCEOP) && (baseturfs == new_baseturfs)) // Don't no-op if the map loader requires it to be reconstructed, or if this is a new set of baseturfs
		return src
	if(flags & CHANGETURF_SKIP)
		return new path(src)

	var/old_dynamic_lighting = dynamic_lighting
	var/old_lighting_object = lighting_object
	var/old_lighting_corner_NE = lighting_corner_NE
	var/old_lighting_corner_SE = lighting_corner_SE
	var/old_lighting_corner_SW = lighting_corner_SW
	var/old_lighting_corner_NW = lighting_corner_NW
	var/old_directional_opacity = directional_opacity

	var/old_exl = explosion_level
	var/old_exi = explosion_id
	var/old_bp = blueprint_data
	blueprint_data = null

	var/list/old_baseturfs = baseturfs

	var/list/transferring_comps = list()
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, new_baseturfs, flags, transferring_comps)
	for(var/i in transferring_comps)
		var/datum/component/comp = i
		comp.ClearFromParent()

	changing_turf = TRUE
	qdel(src) //Just get the side effects and call Destroy

	var/carryover_turf_flags = (RESERVATION_TURF_1 | UNUSED_RESERVATION_TURF_1) & flags_1
	var/turf/W = new path(src)
	W.flags_1 = carryover_turf_flags
	
	for(var/i in transferring_comps)
		W.TakeComponent(i)

	if(new_baseturfs)
		W.baseturfs = new_baseturfs
	else
		W.baseturfs = old_baseturfs

	W.explosion_id = old_exi
	W.explosion_level = old_exl

	if(!(flags & CHANGETURF_DEFER_CHANGE))
		W.AfterChange(flags)

	W.blueprint_data = old_bp

	lighting_corner_NE = old_lighting_corner_NE
	lighting_corner_SE = old_lighting_corner_SE
	lighting_corner_SW = old_lighting_corner_SW
	lighting_corner_NW = old_lighting_corner_NW

	if(SSlighting.initialized)
		lighting_object = old_lighting_object
		directional_opacity = old_directional_opacity
		recalculate_directional_opacity()

		if (dynamic_lighting != old_dynamic_lighting)
			if (IS_DYNAMIC_LIGHTING(src))
				lighting_build_overlay()
			else
				lighting_clear_overlay()
		else if(lighting_object && !lighting_object.needs_update)
			lighting_object.update()

		for(var/turf/open/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			S.update_starlight()
	
	// only queue for smoothing if SSatom initialized us, and we'd be changing smoothing state
	if(flags_1 & INITIALIZED_1)
		QUEUE_SMOOTH_NEIGHBORS(src)
		QUEUE_SMOOTH(src)

	SSdemo.mark_turf(W)

	return W

/turf/open/ChangeTurf(path, list/new_baseturfs, flags)
	//don't
	if(!SSair.initialized)
		return ..()
	if ((flags & CHANGETURF_INHERIT_AIR) && ispath(path, /turf/open))
		var/datum/gas_mixture/stashed_air = new()
		stashed_air.copy_from(air)
		. = ..()
		if (!.) // changeturf failed or didn't do anything
			QDEL_NULL(stashed_air)
			return
		var/turf/open/newTurf = .
		if(turf_fire)
			if(isgroundlessturf(newTurf))
				qdel(turf_fire)
			else
				newTurf.turf_fire = turf_fire
		if (!istype(newTurf.air, /datum/gas_mixture/immutable/space))
			QDEL_NULL(newTurf.air)
			newTurf.air = stashed_air
			update_air_ref(planetary_atmos ? 1 : 2)
	else
		if(turf_fire)
			qdel(turf_fire)
		if(ispath(path,/turf/closed)|| ispath(path,/turf/cordon))
			flags |= CHANGETURF_RECALC_ADJACENT
			update_air_ref(-1)
			. = ..()
		else
			. = ..()
			if(!istype(air,/datum/gas_mixture))
				Initalize_Atmos(0)

//If you modify this function, ensure it works correctly with lateloaded map templates.
/turf/proc/AfterChange(flags) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	ImmediateCalculateAdjacentTurfs()

	//update firedoor adjacency
	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
	for(var/I in turfs_to_check)
		var/turf/T = I
		for(var/obj/machinery/door/firedoor/FD in T)
			FD.CalculateAffectingAreas()

	HandleTurfChange(src)

/turf/open/AfterChange(flags)
	..()
	RemoveLattice()
	if(!(flags & (CHANGETURF_IGNORE_AIR | CHANGETURF_INHERIT_AIR)))
		Assimilate_Air()

//////Assimilate Air//////
/turf/open/proc/Assimilate_Air()
	var/turf_count = LAZYLEN(atmos_adjacent_turfs)
	if(blocks_air || !turf_count) //if there weren't any open turfs, no need to update.
		return

	var/datum/gas_mixture/total = new//Holders to assimilate air from nearby turfs

	for(var/T in atmos_adjacent_turfs)
		var/turf/open/S = T
		if(!S.air)
			continue
		total.merge(S.air)

	air.copy_from(total.remove_ratio(1/turf_count))

/turf/proc/ReplaceWithLattice()
	ScrapeToBottom(flags = CHANGETURF_INHERIT_AIR) // Yogs -- fixes this not actually replacing the turf with a lattice, lmao (ScrapeToBottom defined in yogs file)
	new /obj/structure/lattice(locate(x, y, z))
