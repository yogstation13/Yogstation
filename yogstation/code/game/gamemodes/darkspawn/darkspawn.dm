GLOBAL_VAR_INIT(sacrament_done, FALSE)

/datum/game_mode/darkspawn
	name = "darkspawn"
	config_tag = "darkspawn"
	antag_flag = ROLE_DARKSPAWN
	required_players = 25
	required_enemies = 2
	recommended_enemies = 1
	enemy_minimum_age = 24 //reasonably complicated antag
	restricted_jobs = list("AI", "Cyborg", "Synthetic")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Research Director", "Chief Engineer", "Chief Medical Officer", "Brig Physician") //Added Brig Physician
	title_icon = "darkspawn"
	round_ends_with_antag_death = TRUE
	var/list/datum/mind/darkspawns = list()
	var/datum/team/darkspawn/team

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Gamemode Setup-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/darkspawn/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

 	//scaling number of darkspawns, at least 2, at most 4 (they get exponentially stronger per person)
	// 25 players = 2 darkspawns
	// 40 players = 3 darkspawns
	// 55 players = 4 darkspawns
	var/num_darkspawn = clamp(round((num_players()+5)/15), required_enemies, 4)
	for (var/i = 1 to num_darkspawn)
		if(LAZYLEN(antag_candidates) <= 0)
			break
		var/datum/mind/darkboi = antag_pick(antag_candidates)
		antag_candidates -= darkboi
		darkspawns += darkboi
		darkboi.special_role = ROLE_DARKSPAWN
		darkboi.restricted_roles = restricted_jobs
		log_game("[key_name(darkboi)] (ckey) has been selected as a darkspawn.")

	team = new
	team.update_objectives()
	GLOB.thrallnet.name = "Thrall net"

	if(!team || !LAZYLEN(darkspawns))
		setup_error = "Error setting up darkspawns"
		return FALSE
	return TRUE

/datum/game_mode/darkspawn/post_setup()
	for(var/datum/mind/darkboi as anything in darkspawns)
		darkboi.add_antag_datum(/datum/antagonist/darkspawn)
	. = ..()

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Non-Secret mode stuff-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/darkspawn/announce()
	to_chat(world, "<b>The current game mode is - Darkspawn!</b>")
	to_chat(world, "<b>There are [span_velvet("darkspawn")] on the station. Crew: Kill the darkspawn before they can complete the Sacrament. Darkspawn: Consume enough lucidity to complete the Sacrament and ascend once again.</b>")

/datum/game_mode/darkspawn/generate_report()
	return "Sightings of strange alien creatures have been observed in your area. These aliens appear to be searching for specific patterns of brain activity, with their method for doing so causing victims to lapse into a short coma. \
	Be wary of dark areas and ensure all lights are kept well-maintained. Investigate all reports of odd or suspicious sightings in maintenance, and be on the lookout for anyone sympathizing with these aliens, as they may be compromised"

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Game end checks---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/darkspawn/are_special_antags_dead()
	if(team)
		return team.check_darkspawn_death()
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//----------------------------After game end stuff--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/darkspawn/set_round_result()
	..()
	if(GLOB.sacrament_done)
		SSticker.mode_result = "win - the darkspawn have completed the sacrament"
	else
		SSticker.mode_result = "loss - staff stopped the darkspawn"

/datum/game_mode/darkspawn/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Darkspawn:</h1>"
	len_before_addition = round_credits.len
	if(team)
		for(var/datum/mind/current in team.members)
			round_credits += "<center><h2>[current.name] as the [current.assigned_role]</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The Darkspawn have moved to the shadows!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Mob assign procs---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/proc/add_darkspawn()
	if(!istype(mind))
		return FALSE		
	return mind.add_antag_datum(/datum/antagonist/darkspawn)

/mob/living/proc/remove_darkspawn()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/darkspawn)

/mob/living/proc/add_thrall()
	if(!istype(mind))
		return FALSE
	return mind.add_antag_datum(/datum/antagonist/thrall)

/mob/living/proc/remove_thrall()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/thrall)
