/datum/game_mode
	var/list/datum/mind/clockagents = list()	//list of clock agents for objective scaling
	var/datum/team/clock_agents/clock_agent_team//clock team for tracking objectives
	var/list/datum/mind/bloodagents = list()	//ditto for blood
	var/datum/team/blood_agents/blood_agent_team //same
	var/agent_scaling = 1

/datum/game_mode/traitor/traitorcult
	name = "traitor+cultagents"
	config_tag = "traitorcult"
	restricted_jobs = list("Chaplain", "Captain", "AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security")
	required_players = 20

	announce_span = "danger"
	announce_text = "There are Syndicate and Cult Agents aboard the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='danger'>Cult Agents</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors or cult agents succeed!"

	var/list/datum/mind/coggers_to_cog = list()
	var/list/datum/mind/bloods_to_blood = list()

/datum/game_mode/traitor/traitorcult/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_clocks = get_players_for_role(ROLE_CLOCK_AGENT)
	var/list/datum/mind/possible_bloods = get_players_for_role(ROLE_BLOOD_AGENT)

	var/asc = CONFIG_GET(number/agent_scaling_coeff)
	if(asc)
		agent_scaling = max(round(num_players() / asc), 1)
	clock_agent_team = new
	GLOB.servants_active = TRUE //needed for scripture alerts, doesn't do much else aside from reebe stuff so :shrug:
	if(possible_clocks.len)
		for(var/j = 1 to agent_scaling)
			if(!possible_clocks.len)
				break
			var/datum/mind/clock = antag_pick(possible_clocks)
			possible_clocks -= clock
			possible_bloods -= clock
			antag_candidates -= clock
			clock_agent_team.add_member(clock)
			clock.special_role = ROLE_CLOCK_AGENT
			clock.restricted_roles = restricted_jobs
			coggers_to_cog += clock
	if(possible_bloods.len)
		blood_agent_team = new
		for(var/k = 1 to agent_scaling)
			if(!possible_bloods.len)
				break
			var/datum/mind/blood = antag_pick(possible_bloods)
			possible_bloods -= blood
			antag_candidates -= blood
			blood_agent_team.add_member(blood)
			blood.special_role = ROLE_BLOOD_AGENT
			blood.restricted_roles = restricted_jobs
			bloods_to_blood += blood
	return ..()

/datum/game_mode/traitor/traitorcult/post_setup()
	if(clock_agent_team)
		clock_agent_team.forge_clock_objectives()
	if(blood_agent_team)
		blood_agent_team.forge_blood_objectives()
	for(var/datum/mind/M in bloods_to_blood)
		M.add_antag_datum(/datum/antagonist/cult/agent)
	for(var/datum/mind/M in coggers_to_cog)
		var/mob/living/L = M.current
		add_servant_of_ratvar(L, TRUE, FALSE, TRUE)
	return ..()
