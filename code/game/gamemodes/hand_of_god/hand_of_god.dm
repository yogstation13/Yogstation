/*Hand of God
its the silly little gamemode where two cults are vying to summon their respective gods ratvar or nar'sie
pulls stuff from clock_cult and eldritch_cult mostly items*/

/datum/game_mode/hand_of_god
	name = "Hand Of God"
	config_tag = "hand_of_god"
	antag_flag = ROLE_HOG_CULTIST
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Brig Physician", "Chaplain") 
	required_players = 43
	required_enemies = 1
	recommended_enemies = 2
	enemy_minimum_age = 14
	title_icon = "hand_of_god"

	announce_span = "danger"
	announce_text = "A violent war between cults has errupted on the station!\n\
	<span class='danger'>Cults</span>: Free your god into the mortal realm.\n\
	<span class='notice'>Crew</span>: Prevent the cults from summonning their god."


//Blood cult

var/finished = 0

	var/acolytes_needed = 10 //for the survive objective
	var/acolytes_survived = 0

	var/list/cultists_to_cult = list() //the cultists we'll convert

	var/datum/team/cult/main_cult


//Presetup - copies the basics from respective gamemodes, modified to balance the cults

/datum/game_mode/hand_of_god/pre_setup()

//bloodcult
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	//cult scaling goes here
	recommended_enemies = 1 + round(num_players()/CULT_SCALING_COEFFICIENT)
	var/remaining = (num_players() % CULT_SCALING_COEFFICIENT) * 10 //Basically the % of how close the population is toward adding another cultis
	if(prob(remaining))
		recommended_enemies++
	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = antag_pick(antag_candidates)
		antag_candidates -= cultist
		cultists_to_cult += cultist
		cultist.special_role = ROLE_CULTIST
		cultist.restricted_roles = restricted_jobs
		//log_game("[key_name(cultist)] has been selected as a cultist") | yogs - redundant

//clockcult
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	var/starter_servants = 3 //Guaranteed three servants
	var/number_players = num_players()
	roundstart_player_count = number_players
	starter_servants = min(starter_servants, 3) //max 3 servants
	while(starter_servants)
		var/datum/mind/servant = antag_pick(antag_candidates)
		servants_to_serve += servant
		antag_candidates -= servant
		servant.assigned_role = ROLE_SERVANT_OF_RATVAR
		servant.special_role = ROLE_SERVANT_OF_RATVAR
		starter_servants--
	return 1

	if(cultists_to_cult.len>=required_enemies)
		return TRUE
	else
		setup_error = "Not enough cultist candidates"
		return FALSE














