/datum/round_event_control/corruption
	name = "Spawn Corruption"
	typepath = /datum/round_event/ghost_role/corruption
	max_occurrences = 1
	min_players = 25
	earliest_start = 30 MINUTES

/datum/round_event/ghost_role/corruption
	minimum_required = 1
	role_name = "nightmare"
	fakeable = FALSE

/datum/round_event/ghost_role/corruption/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/list/spawn_locs = list()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T

	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/mob/living/simple_animal/hostile/corruption/C = new(pick(spawn_locs))
	player_mind.transfer_to(C)
	player_mind.assigned_role = "Corruption Avatar"
	player_mind.special_role = "Corruption Avatar"
	player_mind.add_antag_datum(/datum/antagonist/corruption)
	playsound(S, 'yogstation/sound/creatures/progenitor_attack.ogg', 50, 1, -1)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into Corruption Avatar by an event.")
	log_game("[key_name(S)] was spawned as Corruption Avatar by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN