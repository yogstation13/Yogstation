/datum/round_event_control/darkspawn
	name = "Spawn Darkspawn(s)"
	typepath = /datum/round_event/ghost_role/darkspawn
	max_occurrences = 1
	min_players = 30
	dynamic_should_hijack = TRUE
	gamemode_blacklist = list("darkspawn", "shadowling")

/datum/round_event/ghost_role/darkspawn
	minimum_required = 1
	role_name = "darkspawn"
	fakeable = FALSE

/datum/round_event/ghost_role/darkspawn/spawn_role()
	var/list/candidates = get_candidates(ROLE_DARKSPAWN, null, ROLE_DARKSPAWN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	
	var/list/spawn_locs = list()
	for(var/turf/T in GLOB.xeno_spawn)
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T

	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	
	var/darkspawn_to_spawn = 1
	var/datum/job/hos = SSjob.GetJob("Head of Security")
	var/datum/job/warden = SSjob.GetJob("Warden")
	var/datum/job/officers = SSjob.GetJob("Security Officer")
	var/sec_amount = hos.current_positions + warden.current_positions + officers.current_positions
	if(sec_amount >= 5 && candidates.len >= 2 && spawn_locs.len >= 2)
		darkspawn_to_spawn = 2

	for(var/i=0,i<darkspawn_to_spawn,i++)
		var/mob/dead/selected = pick(candidates)

		var/datum/mind/player_mind = new /datum/mind(selected.key)
		player_mind.active = TRUE

		var/turf/chosen_spawn = pick(spawn_locs)
		spawn_locs -= chosen_spawn // No spawning in the same place
		var/mob/living/carbon/human/H = new (chosen_spawn)
		player_mind.transfer_to(H)
		player_mind.assigned_role = "Darkspawn"
		player_mind.special_role = "Darkspawn"
		var/datum/antagonist/darkspawn/D = player_mind.add_antag_datum(/datum/antagonist/darkspawn)
		D.force_divulge()
		playsound(H, 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
		message_admins("[ADMIN_LOOKUPFLW(H)] has been made into a Darkspawn by an event.")
		log_game("[key_name(H)] was spawned as a Darkspawn by an event.")
		spawned_mobs += H
	return SUCCESSFUL_SPAWN
