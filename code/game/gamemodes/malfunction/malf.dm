/datum/game_mode/malf
	name = "malfunction"
	config_tag = "malf"
	report_type = "malf"
	antag_flag = ROLE_MALF
	false_report_weight = 5
	required_players = 30
	required_enemies = 1
	recommended_enemies = 1
	reroll_friendly = FALSE
	title_icon = "ss13"

	announce_span = "danger"
	announce_text = "The station's Artificial Intelligence is rogue!\n\
	<span class='danger'>AI</span>: Destroy the station.\n\
	<span class='notice'>Crew</span>: Do not let the AI succeed!"

/datum/game_mode/malf/get_players_for_role(role)
	.=..()
	var/datum/job/ai/job = SSjob.GetJob("AI")
	for(var/datum/mind/candidate in .)
		if(job.required_playtime_remaining(candidate.current.client))
			. -= candidate
	return .

/datum/game_mode/malf/pre_setup()
	var/datum/mind/AI = antag_pick(antag_candidates)
	SSjob.AssignRole(AI.current, "AI")
	return TRUE

/datum/game_mode/malf/post_setup()
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list) //triumvirate AIs ride for free. Oh well, it's basically an event in that case
		AI.mind.add_antag_datum(/datum/antagonist/traitor/malf)

	gamemode_ready = TRUE
	. = ..()

/datum/game_mode/malf/make_antag_chance()
	return FALSE //no latejoins for you

/datum/game_mode/malf/are_special_antags_dead()
	for(var/datum/mind/ai in traitors)
		if(ai.current && isAI(ai.current) && ai.current.stat != DEAD)
			return FALSE
	return TRUE

/datum/game_mode/malf/set_round_result()
	..()

	if(station_was_nuked)
		SSticker.mode_result = "win - AI doomsday"
	else if(didAntagsWin(traitors, /datum/antagonist/traitor/malf))
		SSticker.mode_result = "win - AI achieved their objectives"
	else if(!are_special_antags_dead())
		SSticker.mode_result = "halfwin - evacuation - AI survived"

	else
		SSticker.mode_result = "loss - evacuation - AI killed"

/datum/game_mode/malf/generate_report()
	return "a [pick(list("Huge electrical storm","Photon emitter","Meson generator","Blue swirly thing"))] was recently picked up by a nearby station's sensors in your sector. \
	If it came into contact with your station or electrical equipment, it may have had hazardarous and unpredictable effect. \
	Closely observe any non carbon based life forms for signs of unusual behaviour, but keep this information discreet at all times due to this possibly dangerous scenario."
