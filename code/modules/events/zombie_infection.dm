/datum/round_event_control/zombie
	name = "Spawn Zombie"
	typepath = /datum/round_event/ghost_role/zombie
	max_occurrences = 1
	min_players = 20
	weight = 4
	dynamic_should_hijack = TRUE
/datum/round_event/ghost_role/zombie
	minimum_required = 1
	role_name = "zombie"
	fakeable = TRUE

/datum/round_event/ghost_role/zombie/announce(fake)
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS, 'sound/hallucinations/growl1.ogg')

/datum/round_event/ghost_role/zombie/spawn_role()
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
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			spawn_locs += T

	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/mob/living/carbon/human/S = new ((pick(spawn_locs)))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Zombie"
	player_mind.special_role = "Zombie"
	S.set_species(/datum/species/zombie/infectious)
	playsound(S, 'sound/hallucinations/growl1.ogg', 50, 1, -1)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Zombie by an event.")
	log_game("[key_name(S)] was spawned as a Zombie by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
