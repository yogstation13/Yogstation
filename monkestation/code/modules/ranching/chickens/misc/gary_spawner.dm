GLOBAL_LIST(possible_gary_hideouts)

/obj/effect/landmark/start/gary
	name = "Potential Gary Spawnpoint (Common)"
	icon = 'monkestation/icons/mob/landmarks.dmi'
	icon_state = "Gary (Common)"
	var/weight = 15

/obj/effect/landmark/start/gary/Initialize(mapload)
	..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	var/turf/open/our_turf = get_turf(loc)
	if(isopenturf(our_turf) && !isgroundlessturf(our_turf))
		if(!LAZYLEN(GLOB.possible_gary_hideouts))
			SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_gary)))
		LAZYSET(GLOB.possible_gary_hideouts, our_turf, weight)
	else
		log_mapping("Gary spawnpoint placed at an invalid location ([AREACOORD(our_turf)])")
	return INITIALIZE_HINT_QDEL

/proc/spawn_gary()
	if(!LAZYLEN(GLOB.possible_gary_hideouts))
		log_game("No valid Gary hideout spawners available, not spawning Gary.")
		return
	var/turf/open/base_spawn_loc = pick_weight(GLOB.possible_gary_hideouts)
	var/mob/living/basic/chicken/gary/gary = new(base_spawn_loc)
	// 5% chance they'll make a random hideout anyways
	if(prob(95))
		var/area/base_spawn_area = get_area(base_spawn_loc)
		// for variety's sake, we're gonna slightly randomize the spawn point to be within a screen or so of the landmark
		var/list/possible_spawn_locs = list(base_spawn_loc)
		for(var/turf/open/possible_loc in oview(7, base_spawn_loc))
			if(isgroundlessturf(possible_loc) || get_area(possible_loc) != base_spawn_area)
				continue
			if(!is_safe_turf(possible_loc))
				continue
			possible_spawn_locs += possible_loc
		gary.set_home(pick(possible_spawn_locs))
	log_game("Spawned Gary at [AREACOORD(base_spawn_loc)]")
	LAZYNULL(GLOB.possible_gary_hideouts)

/obj/effect/landmark/start/gary/uncommon
	name = "Potential Gary Spawnpoint (Uncommon)"
	icon_state = "Gary (Uncommon)"
	weight = 5

/obj/effect/landmark/start/gary/rare
	name = "Potential Gary Spawnpoint (Rare)"
	icon_state = "Gary (Rare)"
	weight = 1
