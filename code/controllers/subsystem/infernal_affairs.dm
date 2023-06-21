/**
 * ##infernal_affairs subsystem
 * 
 * Supposed to handle the objectives of all Agents, ensuring they all have to kill eachother.
 * Also keeps track of their Antag gear, to remove it when their soul is collected.
 */
SUBSYSTEM_DEF(infernal_affairs)
	name = "Devil Affairs"
	flags = SS_NO_FIRE

	///List of all devils in-game. There is supposed to have only one, so this is in-case admins do some wacky shit.
	var/list/datum/antagonist/devil/devils = list()
	///List of all Agents in the loop and the gear they have.
	var/list/agent_datums_and_items = list()

/datum/controller/subsystem/infernal_affairs/Initialize()
	return SS_INIT_SUCCESS

/**
 * Enters a for() loop for all agents while assigning their target to be the first available agent.
 * 
 * We assign all IAAs their position in the list to later assign them as objectives of one another.
 * Lists starts at 1, so we will immediately imcrement to get their target.
 * When the list goes over, we go back to the start AFTER incrementing the list, so they will have the first player as a target.
 * We skip over Hellbound people, and when there's only one left alive, we'll end the loop.
 */
/datum/controller/subsystem/infernal_affairs/proc/update_objective_datums()
	if(!agent_datums_and_items.len)
		return
	var/list_position = 1
	for(var/datum/antagonist/infernal_affairs/agents as anything in agent_datums_and_items)
		if(!agents.active_objective)
			RegisterSignal(src, COMSIG_ON_UPLINK_PURCHASE, PROC_REF(on_uplink_purchase))
			agents.active_objective = new(src)
		var/objective_set = FALSE
		while(!objective_set)
			list_position++
			if(list_position > agent_datums_and_items.len)
				list_position = initial(list_position)
			var/datum/antagonist/infernal_affairs/next_agent = agent_datums_and_items[list_position]
			if(HAS_TRAIT(next_agent.owner, TRAIT_HELLBOUND))
				continue
			if(next_agent == agents)
				end_loop(agents)
				objective_set = TRUE
				break
			if(agents.active_objective.target != agent_datums_and_items[list_position])
				agents.active_objective.target = agent_datums_and_items[list_position]
				agents.active_objective.update_explanation_text()
				agents.update_static_data(agents.owner.current)
			objective_set = TRUE
			break
	return TRUE

/**
 * ## on_uplink_purchase
 * 
 * Called when an uplink item is purchased.
 * We will keep track of their items to destroy them when the Agent dies.
 */
/datum/controller/subsystem/infernal_affairs/proc/on_uplink_purchase(datum/component/uplink/source, atom/purchased_item, mob/living/purchaser)
	SIGNAL_HANDLER
	for(var/datum/antagonist/infernal_affairs/agents as anything in agent_datums_and_items)
		if(agents.owner.current != purchaser)
			continue
		if(!agent_datums_and_items[agents][purchased_item])
			agent_datums_and_items[agents][purchased_item] = 1
		else
			agent_datums_and_items[agents][purchased_item]++

/**
 * ## end_loop
 * 
 * We unregister signal to stop listening for people in the loop, as it's over.
 * We will then give the last man standing their hijack objective, to end the subsystem off
 * Args:
 * - last_man_standing: The antag datum of the last remaining player left alive.
 */
/datum/controller/subsystem/infernal_affairs/proc/end_loop(datum/antagonist/infernal_affairs/last_one_standing)
	var/datum/objective/hijack/hijack_objective = new()
	hijack_objective.owner = last_one_standing.owner
	hijack_objective.explanation_text = hijack_objective
	last_one_standing.objectives += hijack_objective
	last_one_standing.update_static_data(last_one_standing.owner.current)
