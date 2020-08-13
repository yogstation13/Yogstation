/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	report_type = "traitorchan"
	false_report_weight = 10
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 25
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	reroll_friendly = 1
	announce_span = "Traitors and Changelings"
	announce_text = "There are alien creatures on the station along with some syndicate operatives out for their own gain! Do not let the changelings or the traitors succeed!"
	title_icon = "traitorchan"

	var/list/possible_changelings = list()
	var/list/changelings = list()
	var/const/changeling_amount = 1 //hard limit on changelings if scaling is turned off

/datum/game_mode/traitor/changeling/can_start()
	if(!..())
		return 0
	possible_changelings = get_players_for_role(ROLE_CHANGELING)
	if(possible_changelings.len < required_enemies)
		return 0
	return 1

/datum/game_mode/traitor/changeling/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	var/num_changelings = 1

	var/csc = CONFIG_GET(number/changeling_scaling_coeff)
	if(csc)
		num_changelings = max(1, min(round(num_players() / (csc * 4)) + 2, round(num_players() / (csc * 2))))
	else
		num_changelings = max(1, min(num_players(), changeling_amount/2))

	if(possible_changelings.len>0)
		for(var/j = 0, j < num_changelings, j++)
			if(!possible_changelings.len)
				break
			var/datum/mind/changeling = antag_pick(possible_changelings)
			antag_candidates -= changeling
			possible_changelings -= changeling
			changeling.special_role = ROLE_CHANGELING
			changelings += changeling
			changeling.restricted_roles = restricted_jobs
		return ..()
	else
		return 0

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	return ..()

/datum/game_mode/traitor/changeling/make_antag_chance(mob/living/carbon/human/character) //Assigns changeling to latejoiners
	var/csc = CONFIG_GET(number/changeling_scaling_coeff)
	var/changelingcap = min( round(GLOB.joined_player_list.len / (csc * 4)) + 2, round(GLOB.joined_player_list.len / (csc * 2)))
	if(changelings.len >= changelingcap) //Caps number of latejoin antagonists
		..()
		return
	if(changelings.len <= (changelingcap - 2) || prob(100 / (csc * 4)))
		if(ROLE_CHANGELING in character.client.prefs.be_special)
			if(!is_banned_from(character.ckey, list(ROLE_CHANGELING, ROLE_SYNDICATE)) && !QDELETED(character))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						character.mind.make_Changeling()
						changelings += character.mind
	if(QDELETED(character))
		return
	..()

/datum/game_mode/traitor/changeling/generate_report()
	return "The Syndicate has started some experimental research regarding humanoid shapeshifting.  There are rumors that this technology will be field tested on a Nanotrasen station \
			for infiltration purposes.  Be advised that support personel may also be deployed to defend these shapeshifters. Trust nobody - suspect everybody. Do not announce this to the crew, \
			as paranoia may spread and inhibit workplace efficiency."

/datum/game_mode/traitor/changeling/trustnoone
	name = "traitor + lings + anybody can be an antag"
	config_tag = "trustnoone"
	protected_jobs = list()
	
/datum/game_mode/traitor/changeling/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The [syndicate_name()] Spies:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/M in changelings)
		var/datum/antagonist/changeling/cling = M.has_antag_datum(/datum/antagonist/changeling)
		if(cling)
			round_credits += "<center><h2>[cling.changelingID] in the body of [M.name]</h2>"
	for(var/datum/mind/traitor in traitors)
		round_credits += "<center><h2>[traitor.name] as a [syndicate_name()] traitor</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>Uh oh, we lost track of the shape shifters!</h2>", "<center><h2>Nobody move!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits 
