/datum/game_mode/devil_affairs
	name = "Devil Affairs"
	config_tag = "devil_affairs"
	report_type = "devil_affairs"
	false_report_weight = 10
	required_players = 25
	required_enemies = 5
	recommended_enemies = 8
	reroll_friendly = 0
	antag_flag = ROLE_INTERNAL_AFFAIRS
	enemy_minimum_age = 14
	title_icon = "traitor"

	announce_span = "danger"
	announce_text = "Devil Affairs are killing eachother for rewards and the Devil!\n\
		<span class='danger'>Agents</span>: Eliminate your targets, turn your kills in to the Devil, and avoid being killed yourself!\n\
		<span class='danger'>Devil</span>: Remain hidden in plain site, turn in kills, collect souls, and ascend!\n\
		<span class='notice'>Crew</span>: Find and capture all Agents and the troublesome Devil."

	///List of minds signed up to be a devil affair agent or devil.
	var/list/datum/mind/agent_minds = list()

/datum/game_mode/devil_affairs/pre_setup()
	var/n_agents = min(round(num_players() / 10), antag_candidates.len)
	if(n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/agents = antag_pick(antag_candidates)
			agent_minds += agents
			//log_game("[key_name(new_op)] has been selected as a nuclear operative") | yogs - redundant
		return TRUE
	setup_error = "Not enough devil affair agent candidates"
	return FALSE

/datum/game_mode/devil_affairs/post_setup()
	//Assign the devil
	var/datum/mind/devil_mind = agent_minds[1]
	devil_mind.add_antag_datum(/datum/antagonist/devil)
	//Assign the agents
	for(var/datum/mind/agent_mind as anything in agent_minds - devil_mind)
		agent_mind.add_antag_datum(/datum/antagonist/infernal_affairs)
	return ..()
