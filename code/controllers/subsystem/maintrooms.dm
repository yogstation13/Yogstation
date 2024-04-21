SUBSYSTEM_DEF(maintrooms)
	name = "Procedural Generation"
	init_order = INIT_ORDER_MAINTROOMS
	flags = SS_NO_FIRE

/datum/controller/subsystem/maintrooms/Initialize(timeofday)
#ifdef LOWMEMORYMODE
	return SS_INIT_NO_NEED
#endif
#ifdef UNIT_TESTS // This whole subsystem just introduces a lot of odd confounding variables into unit test situations, so let's just not bother with doing an initialize here.
	return SS_INIT_NO_NEED
#endif

	generate_maintrooms()
	return SS_INIT_SUCCESS


/datum/controller/subsystem/maintrooms/proc/generate_maintrooms()
	var/list/errorList = list()
	SSmapping.LoadGroup(errorList, "Maintrooms", "map_files/generic", "MaintStation.dmm", default_traits = ZTRAITS_BACKROOM_MAINTS, silent = TRUE)
	if(errorList.len)	// maintrooms failed to load
		message_admins("Maintrooms failed to load!")
		log_game("Maintrooms failed to load!")

	for(var/area/A as anything in GLOB.areas)
		if(istype(A, /area/procedurally_generated/maintenance/the_backrooms))
			A.RunGeneration()

	addtimer(CALLBACK(src, PROC_REF(generate_exit)), 1 MINUTES)

/datum/controller/subsystem/maintrooms/proc/generate_exit()
	var/backrooms_level = SSmapping.levels_by_trait(ZTRAIT_PROCEDURAL_MAINTS)
	if(LAZYLEN(backrooms_level))
		var/turf/way_out = find_safe_turf(zlevels = backrooms_level, dense_atoms = FALSE)
		new /obj/effect/portal/permanent/one_way/backrooms(way_out)

/obj/effect/portal/permanent/one_way/backrooms/get_link_target_turf()
	var/list/valid_lockers = typecacheof(typesof(/obj/structure/closet) - typesof(/obj/structure/closet/body_bag)\
	- typesof(/obj/structure/closet/secure_closet) - typesof(/obj/structure/closet/cabinet)\
	- typesof(/obj/structure/closet/cardboard) \
	- typesof(/obj/structure/closet/supplypod) - typesof(/obj/structure/closet/stasis)\
	- typesof(/obj/structure/closet/abductor) - typesof(/obj/structure/closet/bluespace), only_root_path = TRUE) //stolen from bluespace lockers

	var/list/lockers_list = list()
	for(var/obj/structure/closet/L in GLOB.lockers)
		if(!is_station_level(L.z))
			continue
		if(!is_type_in_typecache(L, valid_lockers))
			continue
		if(L.opened)
			continue
		lockers_list += L
	var/obj/structure/closet/exit = pick(lockers_list)
	if(!exit)
		exit = new(get_safe_random_station_turf())
	return get_turf(exit)

/obj/effect/portal/permanent/one_way/backrooms/teleport(atom/movable/M, force)
	. = ..()
	if(.)
		var/obj/structure/closet/end = locate() in get_turf(M)
		if(end)
			M.forceMove(end) //get in the locker, nerd

/obj/effect/portal/permanent/backrooms
	icon_state = "wooden_tv"
	
/obj/effect/spawner/backrooms_portal
	name = "backrooms two way portal spawner"

/obj/effect/spawner/backrooms_portal/Initialize(mapload)
	var/backrooms_level = SSmapping.levels_by_trait(ZTRAIT_PROCEDURAL_MAINTS)
	if(LAZYLEN(backrooms_level))
		var/turf/way_out = find_safe_turf(zlevels = backrooms_level, dense_atoms = FALSE)
		create_portal_pair(get_turf(src), way_out, _lifespan = null, newtype = /obj/effect/portal/permanent/backrooms)
