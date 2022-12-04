/datum/game_mode/traitor/devil
	name = "traitor+devil"
	config_tag = "traitordevil"
	report_type = "traitordevil"
	false_report_weight = 10
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 40
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	reroll_friendly = 1
	announce_span = "Traitors and Devils"
	announce_text = "There are infernal soul merchants along with some syndicate operatives out for their own gain! Do not let the devils or the traitors succeed!"
	title_icon = "devil"

	var/list/possible_devils = list()
	var/list/devils = list()
	var/const/devil_amount = 1 //hard limit on devils if scaling is turned off

/datum/game_mode/traitor/devil/can_start()
	if(!..())
		return FALSE
	possible_devils = get_players_for_role(ROLE_DEVIL)
	if(possible_devils.len < required_enemies)
		return FALSE
	return TRUE

/datum/game_mode/traitor/devil/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_devils = get_players_for_role(ROLE_DEVIL)

	var/num_devils = 1

	var/csc = CONFIG_GET(number/devil_scaling_coeff)
	if(csc)
		num_devils = max(1, min(round(num_players() / (csc * 4)) + 2, round(num_players() / (csc * 2))))
	else
		num_devils = max(1, min(num_players(), devil_amount/2))

	if(possible_devils.len>0)
		for(var/j = 0, j < num_devils, j++)
			if(!possible_devils.len)
				break
			var/datum/mind/devil = antag_pick(possible_devils)
			antag_candidates -= devil
			possible_devils -= devil
			devil.special_role = ROLE_DEVIL
			devils += devil
			devil.restricted_roles = restricted_jobs
		return ..()
	else
		return TRUE

/datum/game_mode/traitor/devil/post_setup()
	for(var/datum/mind/devil in devils)
		devil.add_antag_datum(/datum/antagonist/devil)
	return ..()
	
/datum/game_mode/traitor/devil/generate_credit_text()
	var/list/round_credits = list()
	var/datum/antagonist/devil/devil_info
	round_credits += "<center><h1>The [syndicate_name()] Spies:</h1>"
	for(var/datum/mind/M in devils)
		var/datum/antagonist/devil/devil = M.has_antag_datum(/datum/antagonist/devil)
		if(devil)
			round_credits += "<center><h2>[devil_info.truename] in the form of [devil.name]</h2>"
			devil_info = null
	for(var/datum/mind/traitor in traitors)
		round_credits += "<center><h2>[traitor.name] as a [syndicate_name()] traitor</h2>"
	round_credits += ..()
	return round_credits 