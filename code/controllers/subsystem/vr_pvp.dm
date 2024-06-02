#define NO_TEAM 0
#define RED_TEAM 1
#define BLUE_TEAM 2
#define MODE_UNSELECTED 0
#define MODE_FFA 1
#define MODE_TDM 2
#define ARENA_TEMPLATE_FILE "vr_pvp_arena.dmm"

SUBSYSTEM_DEF(vr_pvp)
	name = "VR PVP"
	wait = 3 SECONDS
	flags = SS_NO_INIT

	var/datum/vr_pvp_match/match

/datum/controller/subsystem/vr_pvp/fire(resumed = FALSE)
	if(!match)
		return
	/// check if match should start
	if(match.start_match_soon() == TRUE)
		COOLDOWN_START(match, match_timer, match.length)
		return

	if(!match.ongoing)
		return

	for(var/mob/living/carbon/human/virtual_reality/player as anything in match.virtual_players)
		if(!player.ckey)
			player.dust()

	if(COOLDOWN_TIMELEFT(match, match_timer) <= 30 SECONDS && !match.announced_thirty)
		for(var/mob/living/carbon/human/virtual_reality/player as anything in match.virtual_players)
			SEND_SOUND(src, sound('sound/voice/vr_pvp/mission_end_30.ogg'))

	if(COOLDOWN_TIMELEFT(match, match_timer) <= 10 SECONDS && !match.announced_ten)
		for(var/mob/living/carbon/human/virtual_reality/player as anything in match.virtual_players)
			SEND_SOUND(src, sound('sound/voice/vr_pvp/mission_end_10.ogg'))

	/// check if match should end
	var/list/mob/living/carbon/human/virtual_reality/winners = list()
	var/living_players = 0 // for FFA
	var/living_blues = 0
	var/living_reds = 0
	if(match.mode == MODE_FFA)
		for(var/mob/living/carbon/human/virtual_reality/player as anything in match.fielded_players)
			if(player.stat != DEAD)
				living_players += 1
				winners |= player
	else if(match.mode == MODE_TDM)
		for(var/mob/living/carbon/human/virtual_reality/player as anything in match.red_team)
			if(player.stat != DEAD)
				living_blues += 1
				winners |= player
		for(var/mob/living/carbon/human/virtual_reality/player as anything in match.blue_team)
			if(player.stat != DEAD)
				living_reds += 1
				winners |= player

	var/should_end = (match.mode == MODE_FFA && living_players <= 1) || (match.mode == MODE_TDM && (living_blues == 0 || living_reds == 0))
	if(should_end || COOLDOWN_FINISHED(match, match_timer))
		cleanup_match(winners, !should_end)

/datum/controller/subsystem/vr_pvp/proc/create_new_match()
	if(match)
		cleanup_match()
	var/datum/vr_pvp_match/created_match = new()
	match = created_match
	return created_match

/datum/controller/subsystem/vr_pvp/proc/cleanup_match(list/winners = null, draw = FALSE)
	if(QDELETED(match))
		return
	for(var/mob/living/carbon/human/virtual_reality/player as anything in match.virtual_players)
		player.revert_to_reality(FALSE)
		qdel(player)
	if(winners)
		for(var/mob/living/carbon/human/virtual_reality/player as anything in winners)
			player.vr_sleeper?.say(draw ? "Time ran out before anyone won!" : "Congratulations! You won!")

	message_admins(span_adminnotice("Erasing & placing VR match"))

	var/area/arena = GLOB.areas_by_type[/area/vr_pvp]
	for(var/mob/living/mob in arena)
		qdel(mob) //Clear mobs
	for(var/obj/obj in arena)
		qdel(obj) //Clear objects

	var/datum/map_template/arena_template = SSmapping.map_templates[ARENA_TEMPLATE_FILE]
	arena_template.should_place_on_top = FALSE
	var/turf/arena_corner = locate(arena.x, arena.y, arena.z) // have to do a little bit of coord manipulation to get it in the right spot
	arena_template.load(arena_corner)

	QDEL_NULL(match)

/// Join a virtual human to the match
/datum/controller/subsystem/vr_pvp/proc/join(mob/living/carbon/human/virtual_reality/joiner)
	if(!istype(joiner))
		CRASH("VR match joiner is not a virtual reality human!")
	var/match_to_join = match
	if(QDELETED(match))
		match_to_join = create_new_match()
	match.virtual_players |= joiner

	if(!match.ongoing)
		ENABLE_BITFIELD(joiner.status_flags, GODMODE)

/datum/vr_pvp_match
	var/list/mob/living/carbon/human/virtual_reality/virtual_players // All players including spectators
	var/list/mob/living/carbon/human/virtual_reality/fielded_players // All players on the field
	var/list/mob/living/carbon/human/virtual_reality/red_team
	var/list/mob/living/carbon/human/virtual_reality/blue_team
	var/mode = MODE_UNSELECTED
	var/starting = FALSE
	var/ongoing = FALSE
	var/alternate_outfits = FALSE
	var/length = 3 MINUTES
	var/announced_thirty = FALSE
	var/announced_ten = FALSE
	COOLDOWN_DECLARE(match_timer)

/datum/vr_pvp_match/New(_mode = MODE_UNSELECTED)
	alternate_outfits = prob(20)
	virtual_players = list()
	fielded_players = list()
	red_team = list()
	blue_team = list()
	if(_mode == MODE_UNSELECTED)
		mode = pick(MODE_FFA, MODE_TDM)
	else
		mode = _mode

/datum/vr_pvp_match/proc/start_match_soon()
	if(virtual_players.len <= 0)
		return "Not enough players"
	if(starting || ongoing)
		return "Match already started"
	starting = TRUE
	for(var/mob/living/carbon/human/virtual_reality/player as anything in virtual_players)
		SEND_SOUND(src, sound('sound/voice/vr_pvp/mission_begin_10.ogg'))
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/vr_pvp_match, start_match_now)), 10 SECONDS)
	return TRUE

/datum/vr_pvp_match/proc/start_match_now()
	if(ongoing)
		return
	ongoing = TRUE
	scramble_teams()
	if(mode == MODE_FFA)
		for(var/mob/living/carbon/human/virtual_reality/player as anything in virtual_players)
			move_and_equip_player(player)
	else if(mode == MODE_TDM)
		for(var/mob/living/carbon/human/virtual_reality/player as anything in red_team)
			move_and_equip_player(player, RED_TEAM)
		for(var/mob/living/carbon/human/virtual_reality/player as anything in blue_team)
			move_and_equip_player(player, BLUE_TEAM)

/datum/vr_pvp_match/proc/scramble_teams()
	if(mode != MODE_TDM)
		return
	var/blue = rand(FALSE, TRUE)
	shuffle_inplace(virtual_players)
	for(var/mob/living/carbon/human/virtual_reality/player as anything in virtual_players)
		if(blue)
			blue_team |= player
		else
			red_team |= player
		blue = !blue

/datum/vr_pvp_match/proc/move_and_equip_player(mob/living/carbon/human/virtual_reality/player, team = NO_TEAM)
	if(mode == MODE_TDM && team == NO_TEAM)
		if(red_team.len == blue_team.len)
			team = pick(RED_TEAM, BLUE_TEAM)
		else
			team = red_team.len > blue_team.len ? BLUE_TEAM : RED_TEAM

	var/list/ffa_spawns
	var/list/red_spawns
	var/list/blu_spawns
	if(mode == MODE_TDM)
		red_spawns = get_all_by_type(GLOB.landmarks_list, /obj/effect/landmark/vr_start_tdm_red)
		blu_spawns = get_all_by_type(GLOB.landmarks_list, /obj/effect/landmark/vr_start_tdm_blue)
	else if(mode == MODE_FFA)
		ffa_spawns = get_all_by_type(GLOB.landmarks_list, /obj/effect/landmark/vr_start_ffa)

	switch(team)
		if(NO_TEAM)
			var/obj/effect/landmark/spawn_effect = pick_n_take(ffa_spawns)
			var/turf/spawnpoint = get_turf(spawn_effect)
			player.equipOutfit(/datum/outfit/vr_lone_wolf)
			player.forceMove(spawnpoint)
		if(RED_TEAM)
			var/obj/effect/landmark/spawn_effect = pick_n_take(red_spawns)
			var/turf/spawnpoint = get_turf(spawn_effect)
			player.equipOutfit(alternate_outfits ? /datum/outfit/vr_redteam_alt : /datum/outfit/vr_redteam)
			player.forceMove(spawnpoint)
			player.name = "RED [player.name]"
			player.real_name = "RED [player.real_name]"
		if(BLUE_TEAM)
			var/obj/effect/landmark/spawn_effect = pick_n_take(blu_spawns)
			var/turf/spawnpoint = get_turf(spawn_effect)
			player.equipOutfit(alternate_outfits ? /datum/outfit/vr_blueteam_alt : /datum/outfit/vr_blueteam)
			player.forceMove(spawnpoint)
			player.name = "BLUE [player.name]"
			player.real_name = "BLUE [player.real_name]"
	DISABLE_BITFIELD(player.status_flags, GODMODE)
	fielded_players |= player

#undef NO_TEAM
#undef RED_TEAM
#undef BLUE_TEAM
#undef MODE_UNSELECTED
#undef MODE_FFA
#undef MODE_TDM
#undef ARENA_TEMPLATE_FILE
