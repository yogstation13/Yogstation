/datum/round_event_control/horror
	name = "Spawn Eldritch Horror"
	typepath = /datum/round_event/ghost_role/horror
	max_occurrences = 2
	min_players = 15
	earliest_start = 20 MINUTES

/datum/round_event/ghost_role/horror
	minimum_required = 1
	role_name = "horror"
	fakeable = FALSE

/datum/round_event/ghost_role/horror/spawn_role()
	var/list/candidates = get_candidates(ROLE_HORROR, null, ROLE_HORROR)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1
	if(!GLOB.generic_event_spawns)
		return MAP_ERROR
	var/mob/living/simple_animal/horror/S = new /mob/living/simple_animal/horror(get_turf(pick(GLOB.generic_event_spawns)))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Eldritch Horror"
	player_mind.special_role = "Eldritch Horror"
	player_mind.add_antag_datum(/datum/antagonist/horror)
	to_chat(S, S.playstyle_string)
	SEND_SOUND(S, sound('sound/hallucinations/growl2.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into an eldritch horror by an event.")
	log_game("[key_name(S)] was spawned as an eldritch horror by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN