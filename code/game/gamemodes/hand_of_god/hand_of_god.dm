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

	var/list/datum/mind/culties = list()
	var/list/datum/team/hog_cult/cults = list()

/datum/game_mode/hand_of_god/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	//1 cult per 7 players
	var/cults_to_create = max(3, round(num_players()/7, 1))
	cults_to_create = min(cults_to_create, GLOB.possible_hog_cults.len)
	for(var/i in 3 to cults_to_create*2)
		if(!antag_candidates.len)
			break

		//Now assign a god for a cult
		var/datum/mind/cultie = antag_pick(antag_candidates)
		antag_candidates -= cultie
		culties += cultie
		cultie.special_role = ROLE_HOG_CULTIST
		cultie.restricted_roles = restricted_jobs

	if(culties.len < cults_to_create) //Need 3 cultist in a cult
		return

	return TRUE

/datum/game_mode/hand_of_god/post_setup()
	..()

	for(var/i in god_candidates)
		var/datum/mind/M = i
		var/datum/antagonist/hog/god/G = new()
		var/datum/team/hog_cult/godcult = new
		cults += godcult
		M.add_antag_datum(G, godcult)
	
	while(culties.len)

		if(!cults.len)
			break
		for(var/datum/team/hog_cult/C in cults)
			var/datum/mind/cultist = pick(culties)
			culties -= cultist
			var/datum/antagonist/hog/H = new()
			cultist.add_antag_datum(H, C)
			H.equip_cultist(TRUE)      

/datum/game_mode/hand_of_god/generate_credit_text()
	var/list/round_credits = list()

	for(var/datum/team/hog_cult/C in GLOB.hog_cults)
		round_credits += C.roundend_report()

	round_credits += ..()
	return round_credits

/datum/game_mode/hand_of_god/set_round_result()
	..()
	var/didcultswin = FALSE
	for(var/datum/team/hog_cult/C in GLOB.hog_cults)
		if(C.state == HOG_TEAM_SUMMONED)
			didcultswin = TRUE
			break

	if(didcultswin)
		SSticker.mode_result = "win - cults summoned their god"
	else
		SSticker.mode_result = "loss - the crew stopped the cults from summonning their gods!"















