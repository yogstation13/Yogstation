/datum/round_event_control/flock
	name = "Spawn Flockmind"
	typepath = /datum/round_event/ghost_role/flock
	weight = 8
	max_occurrences = 1
	min_players = 25
	dynamic_should_hijack = TRUE
	gamemode_blacklist = list("blob")
	
/datum/round_event/ghost_role/flock
	announceWhen = -1
	role_name = "flockmind"
	fakeable = FALSE //Nothing to fake
	
/datum/round_event/ghost_role/flock/announce(fake)
	return

/datum/round_event/ghost_role/flock/spawn_role()
	if(!GLOB.blobstart.len)
		return MAP_ERROR
	var/list/candidates = get_candidates(ROLE_FLOCKMIND, null, ROLE_FLOCKMIND)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/player = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(player.key)
	player_mind.active = TRUE

	var/mob/camera/flocktrace/flockmind/FM = new (pick(GLOB.blobstart))
	player_mind.transfer_to(FC)
	player_mind.assigned_role = "Flockmind"
	player_mind.special_role = "Flockmind"
	spawned_mobs += FC
	message_admins("[ADMIN_LOOKUPFLW(FC)] has been made into a flockmind by an event.")
	log_game("[key_name(FC)] was spawned as a flockmind by an event.")
	return SUCCESSFUL_SPAWN
