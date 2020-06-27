/datum/game_mode
	var/list/datum/mind/clockagents = list()	//list of clock agents for objective scaling
	var/datum/team/clock_agents/clock_agent_team//clock team for tracking objectives
	var/list/datum/mind/bloodagents = list()	//ditto for blood
	var/datum/team/blood_agents/blood_agent_team //same
	var/agent_objective_scaling = 1

/datum/game_mode/traitor/traitorcult
	name = "traitor+cultagents"
	config_tag = "traitorcult"
	restricted_jobs = list("Chaplain", "Captain", "AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 20

	announce_span = "danger"
	announce_text = "There are Syndicate and Cultist agents aboard the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='danger'>Cult Agents</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors or cultist agents succeed!"

	var/const/min_team_size = 1

	var/list/bloods = list()
	var/list/clocks = list()

/datum/game_mode/traitor/traitorcult/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

		var/list/datum/mind/possible_clocks = get_players_for_role(ROLE_CLOCK_AGENT)
		var/list/datum/mind/possible_bloods = get_players_for_role(ROLE_BLOOD_AGENT)

		var/asc = CONFIG_GET(number/agent_scaling_coeff)
		var/team_size = min_team_size
		if(asc)
			team_size = min(round(GLOB.joined_player_list.len / (asc * 2)) + 2, round(GLOB.joined_player_list.len / asc))
		agent_objective_scaling = max(round(num_players() / 20), 1)
		clock_agent_team = new
		GLOB.servants_active = TRUE //needed for scripture alerts, doesn't do much else aside from reebe stuff so :shrug:
		for(var/k = 1 to team_size)
			var/datum/mind/clock = antag_pick(possible_clocks)
			possible_clocks -= clock
			antag_candidates -= clock
			clock.restricted_roles = restricted_jobs
			clocks += clock
		blood_agent_team = new
		for(var/k = 1 to team_size)
			var/datum/mind/blood = antag_pick(possible_bloods)
			possible_bloods -= blood
			antag_candidates -= blood
			blood.restricted_roles = restricted_jobs
			bloods += blood
	return ..()

/datum/game_mode/traitor/traitorcult/post_setup()
	adjust_clockwork_power(1000) //should be enough to start
	for(var/datum/mind/M in clocks)
		add_servant_of_ratvar(M, TRUE, FALSE, TRUE)
	for(var/datum/mind/M in bloods)
		M.add_antag_datum(/datum/antagonist/cult/agent)
	return ..()
