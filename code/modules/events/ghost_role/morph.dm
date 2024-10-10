/datum/round_event_control/morph
	name = "Spawn Morph"
	typepath = /datum/round_event/ghost_role/morph
	weight = 5
	max_occurrences = 1
	min_players = 25
	earliest_start = 30 MINUTES
	description = "Spawns a hungry shapeshifting blobby creature."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_ALIEN)
	checks_antag_cap = TRUE

/datum/round_event/ghost_role/morph
	minimum_required = 1
	role_name = "morphling"

/datum/round_event/ghost_role/morph/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1
	if(!GLOB.xeno_spawn)
		return MAP_ERROR
	var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(pick(GLOB.xeno_spawn))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Morph"
	player_mind.special_role = "Morph"
	player_mind.add_antag_datum(/datum/antagonist/morph)
	to_chat(S, S.playstyle_string)
	SEND_SOUND(S, sound('sound/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a morph by an event.")
	log_game("[key_name(S)] was spawned as a morph by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
