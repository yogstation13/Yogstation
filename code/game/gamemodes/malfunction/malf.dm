/datum/game_mode
	var/list/datum/mind/malf_ais = list()

/datum/game_mode/malf
	name = "malfunction"
	config_tag = "malf" // "MALF"
	report_type = "malf"
	antag_flag = ROLE_MALF
	false_report_weight = 5
	required_players = 30
	required_enemies = 1
	recommended_enemies = 1
	reroll_friendly = FALSE
	title_icon = "ss13"
	time_required = 600 // In minutes

	announce_span = "danger"
	announce_text = "The station's Artificial Intelligence is rogue!\n\
	<span class='danger'>AI</span>: Destroy the station.\n\
	<span class='notice'>Crew</span>: Do not let the AI succeed!"

/datum/game_mode/malf/get_players_for_role(role)
	. = ..()
	var/datum/job/ai/job = SSjob.GetJob("AI")
	for(var/datum/mind/candidate in .)
		var/does_not_exist = QDELETED(candidate)
		var/banned = is_banned_from(candidate.current.ckey, "AI")
		var/passed_age_requirement = job.player_old_enough(candidate.current.client) // Must be old enough for AI.
		var/remaining_playtime_requirement = job.required_playtime_remaining(candidate.current.client) // Must have enough playtime on other jobs to unlock AI.
		var/not_enough_playtime = (candidate.current.client.prefs.exp["AI"] < time_required) // Must have enough playtime on AI.
		if(does_not_exist || banned || !passed_age_requirement || remaining_playtime_requirement > 0 || not_enough_playtime)
			. -= candidate

/datum/game_mode/malf/pre_setup()
	var/datum/mind/future_malf_ai
	var/did_assign = FALSE
	while(!did_assign && antag_candidates.len > 0) {
		future_malf_ai = antag_pick(antag_candidates)
		did_assign = SSjob.AssignRole(future_malf_ai.current, "AI")
	}
	return did_assign

/datum/game_mode/malf/post_setup()
	// If there are additional AIs (e.g. triumvirate AIs), give them it too. 
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		AI.mind.add_antag_datum(/datum/antagonist/malf_ai)
	return ..()

/datum/game_mode/malf/make_antag_chance()
	return FALSE

/datum/game_mode/malf/are_special_antags_dead()
	for(var/datum/mind/ai in malf_ais)
		if(ai.current && isAI(ai.current) && ai.current.stat != DEAD)
			return FALSE
	return TRUE

/datum/game_mode/malf/set_round_result()
	..()

	if(station_was_nuked)
		SSticker.mode_result = "win - AI doomsday"
		return
	if(didAntagsWin(malf_ais, /datum/antagonist/malf_ai))
		SSticker.mode_result = "win - AI achieved their objectives"
		return
	if(!are_special_antags_dead())
		SSticker.mode_result = "halfwin - evacuation - AI survived"
		return

	SSticker.mode_result = "loss - evacuation - AI killed"

/datum/game_mode/malf/generate_report()
	var/list/possible_flavor = list("huge electrical storm", "photon emitter", "meson generator", "blue swirly thing")
	var/selected_flavor = pick(possible_flavor)
	return "A [selected_flavor] was recently picked up by a nearby station's sensors in your sector. \
	If it came into contact with your station or electrical equipment, it may have had hazardous and unpredictable effect. \
	Closely observe any non carbon based life forms for signs of unusual behaviour, but keep this information discreet at all times due to this possibly dangerous scenario."
