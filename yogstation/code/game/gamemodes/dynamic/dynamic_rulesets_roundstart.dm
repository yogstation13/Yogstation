//////////////////////////////////////////////
//                                          //
//         Malfunctioning AI                //
//                              		    //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/malf
	name = "Malfunctioning AI"
	antag_datum = /datum/antagonist/traitor/malf
	antag_flag = ROLE_MALF
	enemy_roles = list("Security Officer", "Warden","Detective","Head of Security", "Captain", "Scientist", "Chemist", "Research Director", "Chief Engineer")
	exclusive_roles = list("AI")
	required_enemies = list(4,4,4,4,4,4,2,2,2,0)
	required_candidates = 1
	weight = 3
	cost = 20
	requirements = list(80,80,70,60,50,45,40,40,40,40)

/datum/dynamic_ruleset/roundstart/malf/trim_candidates()
	..()
	for(var/mob/living/player in candidates)
		if(!isAI(player))
			candidates -= player
			continue
		if(is_centcom_level(player.z))
			candidates -= player
			continue
		if(player.mind && (player.mind.special_role || player.mind.antag_datums?.len > 0))
			candidates -= player
			continue
		if(!(ROLE_MALF in player.client.prefs.be_special))
			candidates -= player
			continue

/datum/dynamic_ruleset/roundstart/malf/execute()
	if(!candidates || !candidates.len)
		return FALSE
	var/mob/living/silicon/ai/M = pick_n_take(candidates)
	assigned += M.mind
	var/datum/antagonist/traitor/malf/AI = new
	M.mind.special_role = antag_flag
	M.mind.add_antag_datum(AI)
	return TRUE
