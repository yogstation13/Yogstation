/datum/round_event_control/antagonist/solo/from_ghosts/nightmare
	name = "Nightmare"
	description = "Spawns a nightmare, aiming to darken the station."
	typepath = /datum/round_event/antagonist/solo/ghost/nightmare
	antag_flag = ROLE_NIGHTMARE
	antag_datum = /datum/antagonist/nightmare

	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL, TAG_ALIEN)

	max_occurrences = 1
	min_players = 20
	earliest_start = 40 MINUTES

	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7


/datum/round_event/antagonist/solo/ghost/nightmare/add_datum_to_mind(datum/mind/antag_mind)
	var/list/spawn_locs = list()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			spawn_locs += T

	if(!spawn_locs.len)
		spawn_locs += pick(GLOB.xeno_spawn) //oh no, good luck buddy

	antag_mind.current?.forceMove(pick(spawn_locs))

	return ..()
