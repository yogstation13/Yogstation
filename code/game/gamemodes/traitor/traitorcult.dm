/datum/game_mode
	var/list/datum/mind/clockagents = list()	//list of clock agents for objective scaling
	var/datum/team/clock_agents/clock_agent_team//clock team for tracking objectives
	var/list/datum/mind/bloodagents = list()	//ditto for blood
	var/datum/team/blood_agent_team				//same

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

/datum/game_mode/traitor/traitorcult/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

		var/list/datum/mind/possible_clocks = get_players_for_role(ROLE_CLOCK_AGENT)
		//var/list/datum/mind/possible_bloods = get_players_for_role(ROLE_BLOOD_AGENT)

		var/asc = CONFIG_GET(number/agent_scaling_coeff)
		var/team_size = min_team_size
		if(asc)
			team_size = min(round(GLOB.joined_player_list.len / (asc * 2)) + 2, round(GLOB.joined_player_list.len / asc))
		clock_agent_team = new
		GLOB.servants_active = TRUE //needed for scripture alerts, doesn't do much else aside from reebe stuff so :shrug:
		for(var/k = 1 to team_size)
			var/datum/mind/clock = antag_pick(possible_clocks)
			possible_clocks -= clock
			antag_candidates -= clock
			clock_agent_team.add_member(clock)
			clock.special_role = ROLE_CLOCK_AGENT
			clock.restricted_roles = restricted_jobs
			equip_clock_agent(clock)
		clock_agent_team.forge_clock_objectives()
		/*blood_agent_team = new //to be added in the "bloodcult" DLC expansion pack
		for(var/k = 1 to team_size)
			var/datum/mind/blood = antag_pick(possible_bloods)
			possible_bloods -= blood
			antag_candidates -= blood
			blood_agent_team.add_member(blood)
			blood.special_role = ROLE_BLOOD_AGENT
			blood.restricted_roles = restricted_jobs*/
	return ..()

/datum/game_mode/proc/equip_clock_agent(mob/living/M)
	if(!M || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/L = M
	var/obj/item/clockwork/slab/agent/S = new
	var/slot = "At your feet"
	var/list/slots = list("In your left pocket" = SLOT_L_STORE, "In your right pocket" = SLOT_R_STORE, "In your backpack" = SLOT_IN_BACKPACK, "On your belt" = SLOT_BELT)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		slot = H.equip_in_one_of_slots(S, slots)
		if(slot == "In your backpack")
			slot = "In your [H.back.name]"
	if(slot == "At your feet")
		if(!S.forceMove(get_turf(L)))
			qdel(S)
	if(S && !QDELETED(S))
		to_chat(L, "<span class='alloy'>[slot] is a <b>clockwork slab</b>, a multipurpose tool used to construct machines and invoke ancient words of power. If this is your first time \
		as a servant, you can find a concise tutorial in the Recollection category of its interface.</span>")
	return S

/datum/game_mode/traitor/traitorcult/post_setup()
	clock_agent_team.forge_clock_objectives()
	//blood_agent_team.forge_blood_objectives()
	for(var/datum/mind/M in clock_agent_team.members)
		add_servant_of_ratvar(M, TRUE, FALSE, TRUE)
	//for(var/datum/mind/M in blood_agent_team.members)
		//M.add_antag_datum(/datum/antagonist/cult/agent)
	return ..()