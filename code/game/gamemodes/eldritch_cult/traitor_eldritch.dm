/datum/game_mode/traitor/heretic
	name = "traitor+heretic"
	config_tag = "traitorheretic"
	report_type = "traitorheretic"
	false_report_weight = 10
	traitors_possible = 3 // Hard limit on Traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg", "Synthetic")
	protected_jobs = list(
		"Captain", "Head of Personnel", "Head of Security", 
		"Research Director", "Chief Engineer", "Chief Medical Officer", "Curator", 
		"Warden", "Security Officer", "Detective", "Brig Physician"
	)
	required_players = 15
	required_enemies = 1 // How many of each type are required
	recommended_enemies = 4
	reroll_friendly = 1
	announce_text = "There are some eldritch madmen on the station along with some syndicate operatives out for their own gain! Do not let the heretics or the traitors succeed!"

	num_modifier = -2 //less traitors to account for heretics

	var/list/possible_heretics = list()
	var/list/heretics = list()
	var/const/heretic_amount = 3

/datum/game_mode/traitor/heretic/can_start()
	. = ..()
	if(!.)
		return
	possible_heretics = get_players_for_role(ROLE_HERETIC)
	if(possible_heretics.len < required_enemies)
		return FALSE
	return TRUE

/datum/game_mode/traitor/heretic/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_heretics = get_players_for_role(ROLE_HERETIC)

	var/num_heretics = 1
	num_heretics = clamp(round(num_players()/15), 1, heretic_amount)

	if(possible_heretics.len>0)
		for(var/j = 0, j < num_heretics, j++)
			if(!possible_heretics.len)
				break
			var/datum/mind/heretic = antag_pick(possible_heretics)
			antag_candidates -= heretic
			possible_heretics -= heretic
			heretic.special_role = ROLE_HERETIC
			heretics += heretic
			heretic.restricted_roles = restricted_jobs
		return ..()
	else
		return FALSE

/datum/game_mode/traitor/heretic/post_setup()
	for(var/datum/mind/heretic in heretics)
		heretic.add_antag_datum(/datum/antagonist/heretic)
	return ..()

/datum/game_mode/traitor/heretic/generate_report()
	return "There's been a report of madmen worshiping eldritch entities roaming around.\
			Nanotrasen believes it is entirely possible that said madmen have been sent by the Syndicate.\
			Please take care of the crew and their health, as it is impossible to tell if one is nearby."
