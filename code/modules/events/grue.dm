/datum/round_event_control/grue
	name = "Grue"
	typepath = /datum/round_event/ghost_role/grue
	weight = 10
	min_players = 20

/datum/round_event_control/grue/canSpawnEvent()
	. = ..()
	if(!.)
		return .

	for(var/mob/living/simple_animal/hostile/grue/A in GLOB.player_list)
		if(A.stat != DEAD)
			return FALSE

/datum/round_event/ghost_role/grue
	announceWhen	= 400
	minimum_required = 1
	role_name = "Grue"

	var/spawncount = 3
	fakeable = TRUE


/datum/round_event/ghost_role/grue/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/round_event/ghost_role/grue/announce(fake)
	priority_announce("Grue", "Grue", ANNOUNCER_ALIENS)


/datum/round_event/ghost_role/grue/spawn_role()
	var/list/turf/targets = list()
	for(var/obj/machinery/door/airlock/maintenance_hatch/M in GLOB.airlocks)
		if(QDELETED(M))
			continue
		var/turf/my_turf = get_turf(M)
		if (!is_station_level(my_turf.z))
			continue
		var/turf/target = null
		for (var/C in GLOB.cardinals)
			var/turf/T = get_step(M, C)
			if (T.get_lumcount() < 0.3)
				target = T
				break
		targets += target

	if(!targets.len)
		message_admins("An event attempted to spawn a grue but no suitable targets were found. Shutting down.")
		return MAP_ERROR

	var/list/candidates = get_candidates(ROLE_GRUE, null, ROLE_GRUE)

	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	while(spawncount > 0 && targets.len && candidates.len)
		var/turf/target = pick_n_take(targets)
		var/client/C = pick_n_take(candidates)

		var/mob/living/simple_animal/hostile/grue/gruespawn/new_grue = new(target)
		new_grue.key = C.key

		spawncount--
		message_admins("[ADMIN_LOOKUPFLW(new_grue)] has been made into a grue by an event.")
		log_game("[key_name(new_grue)] was spawned as a grue by an event.")
		spawned_mobs += new_grue
		announce_to_ghosts(new_grue)

	return SUCCESSFUL_SPAWN
