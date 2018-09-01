/datum/game_mode
	var/list/datum/mind/spythieves = list()
	var/list/spythief_turn_in_locs = list()
	var/list/spythief_bounties = list()
	var/list/bounty_stationitems = list()
	var/list/bounty_personalitems = list()
	var/list/bounty_organs = list()
	var/list/bounty_machines = list()
	//and the last bounty is a photograph


/datum/game_mode/spythief
	name = "spy thief"
	config_tag = "spythief"
	antag_flag = ROLE_SPY_THIEF
	false_report_weight = 10
	restricted_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	protected_jobs = list()
	required_players = 24
	required_enemies = 3
	recommended_enemies = 6
	enemy_minimum_age = 14

	var/list/datum/mind/pre_spies = list()




/datum/game_mode/spythief/pre_setup() //shamelessly stolen from the tatortottle gamemode

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/num_spies = 1

	var/tsc = CONFIG_GET(number/spy_scaling_coeff)
	if(tsc)
		num_spies = max(1, min(round(num_players() / (tsc * 2)) + 2, round(num_players() / tsc)))
	else
		num_spies = max(1, min(num_players(), required_enemies))

	for(var/j = 0, j < num_spies, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/spy = antag_pick(antag_candidates)
		pre_spies += spy
		spy.special_role = "Spy Thief"
		spy.restricted_roles = restricted_jobs
		antag_candidates.Remove(spy)

	if(!pre_spies.len)
		setup_error = "Not enough spy candidates"
		return FALSE
	else
		return TRUE

/datum/game_mode/spythief/post_setup()
	for(var/datum/mind/spy in pre_spies)
		var/datum/antagonist/spythief/new_antag = new /datum/antagonist/spythief()
		addtimer(CALLBACK(spy, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
	..()

	//We're not actually ready until all traitors are assigned.
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	generate_bounties(TRUE)
	return TRUE

/datum/game_mode/spythief/proc/generate_bounties(roundstart = FALSE)

	if(!roundstart)
		spythief_bounties.Cut()

	else //generate all the bounties
		for(var/datum/spythief_bounty/bounty in subtypesof(/datum/spythief_bounty/station_item))
			new bounty()
		for(var/datum/spythief_bounty/bounty in subtypesof(/datum/spythief_bounty/personal_item))
			new bounty()
		for(var/datum/spythief_bounty/bounty in subtypesof(/datum/spythief_bounty/organ))
			new bounty()
		for(var/datum/spythief_bounty/bounty in subtypesof(/datum/spythief_bounty/machine))
			new bounty()


	//now let's find and add the bounties. 2 station item, 2 personal item, 2 organs, 2 machines and 1 photograph
	spythief_bounties += pick(bounty_stationitems)
	spythief_bounties += pick(bounty_personalitems)
	spythief_bounties += pick(bounty_organs)
	spythief_bounties += pick(bounty_machines)
	spythief_bounties += pick(bounty_stationitems - spythief_bounties)
	spythief_bounties += pick(bounty_personalitems - spythief_bounties)
	spythief_bounties += pick(bounty_organs - spythief_bounties)
	spythief_bounties += pick(bounty_machines - spythief_bounties)
	spythief_bounties += new /datum/spythief_bounty/photo()

	//pick a bounty and set it to hot
	var/datum/spythief_bounty/bounty = pick(spythief_bounties)
	bounty.makeHot()

	return