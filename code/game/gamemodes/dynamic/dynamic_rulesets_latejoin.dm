//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	for(var/mob/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role) // Are they connected?
			candidates.Remove(P)
			continue
		if(!mode.check_age(P.client, minimum_required_age))
			candidates.Remove(P)
			continue
		if(antag_flag_override)
			if(!(antag_flag_override in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_flag_override, ROLE_SYNDICATE)))
				candidates.Remove(P)
				continue
		else
			if(!(antag_flag in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_flag, ROLE_SYNDICATE)))
				candidates.Remove(P)
				continue
		if (P.mind.assigned_role in restricted_roles) // Does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_roles.len > 0) && !(P.mind.assigned_role in exclusive_roles)) // Is the rule exclusive to their job?
			candidates.Remove(P)
			continue
		if(P.mind.quiet_round) //Does the candidate have quiet mode enabled?
			candidates.Remove(P)
			continue
		if(P.mind && !(P.mind.assigned_role in GLOB.crew_positions)) //don't antag non crewmembers
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/latejoin/ready(forced = 0)
	if (!forced)
		var/job_check = 0
		if (enemy_roles.len > 0)
			for (var/mob/M in mode.current_players[CURRENT_LIVING_PLAYERS])
				if (M.stat == DEAD)
					continue // Dead players cannot count as opponents
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
					job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = round(mode.threat_level/10)
		if (job_check < required_enemies[threat])
			return FALSE
	return ..()

/datum/dynamic_ruleset/latejoin/execute()
	var/mob/M = pick(candidates)
	assigned += M.mind
	M.mind.special_role = antag_flag
	M.mind.add_antag_datum(antag_datum)
	return TRUE

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/infiltrator
	name = "Syndicate Infiltrator"
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_TRAITOR
	protected_roles = list("Civil Protection Officer", "Warden", "Detective", "Divisional Lead", "District Administrator", "Labor Lead", "Chief Engineer", "Chief Medical Officer", "Research Director", "Brig Physician")
	restricted_roles = list("AI","Cyborg", "Synthetic")
	required_candidates = 1
	weight = 7
	cost = 10
	requirements = list(40,30,20,10,10,10,10,10,10,10)
	repeatable = TRUE
