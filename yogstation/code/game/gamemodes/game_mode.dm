/datum/game_mode/get_players_for_role(role)
	var/list/players = list() // All players who are ready and able
	var/list/candidates = list() // All players who could POSSIBLY be an antag (acting as a fallback if filtered_candidates isn't enough)
	var/list/filtered_candidates = list() // All players who want to be antag, and meet the weaker requirements (such as client age)

	//PLAYER GENERATION
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.client && player.ready == PLAYER_READY_TO_PLAY)
			players += player
			if(player.client.prefs.yogtoggles & QUIET_ROUND)
				player.mind.quiet_round = TRUE

	//CANDIDATE GENERATION -- Get a list of all the people who could be an antagonist this round
	for(var/mob/dead/new_player/player in players)
		if(player.client && player.ready == PLAYER_READY_TO_PLAY)
			if(!is_banned_from(player.ckey, list(role, ROLE_SYNDICATE)) && !QDELETED(player))
				candidates += player.mind
	if(restricted_jobs)
		for(var/datum/mind/player in candidates)
			for(var/job in restricted_jobs)	// Remove people who want to be antagonist but have a job already that precludes it
				if(player.assigned_role == job)
					candidates -= player

	//CANDIDATE FILTRATION -- Young Accounts and Quiet Rounders removed
	for(var/datum/mind/player in candidates)
		if(role in player.current.client.prefs.be_special) // They want to be antag
			if(age_check(player.current.client)) //Must be older than the minimum age
				if(!player.quiet_round) //and must not want a quiet round
					filtered_candidates |= player

	return shuffle(filtered_candidates)

