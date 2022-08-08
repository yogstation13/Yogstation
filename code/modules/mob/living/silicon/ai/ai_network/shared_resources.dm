/datum/ai_shared_resources
	var/ram_sources = list()
	var/cpu_sources = list()
	

	var/list/cpu_assigned = list()
	var/list/ram_assigned = list()

	var/networks = list()

	var/previous_ram = 0

	

/datum/ai_shared_resources/New(network_cpu, network_ram, network_assigned_cpu, network_assigned_ram)
	if(network_cpu || network_ram || network_assigned_ram || network_assigned_cpu)
		ram_sources[src] = network_ram
		cpu_sources[src] = network_cpu
		ram_assigned = network_assigned_ram
		cpu_assigned = network_assigned_cpu

/datum/ai_shared_resources/proc/total_cpu_assigned()
	var/total = 0
	for(var/mob/living/silicon/ai/AI in cpu_assigned)
		total += cpu_assigned[AI]
	return total

/datum/ai_shared_resources/proc/total_ram_assigned()
	var/total = 0
	for(var/mob/living/silicon/ai/AI in ram_assigned)
		total += (ram_assigned[AI] - AI.dashboard.free_ram)
	return total

/datum/ai_shared_resources/proc/total_cpu()
	var/total = 0
	for(var/C in cpu_sources)
		total += cpu_sources[C]
	return total

/datum/ai_shared_resources/proc/total_ram()
	var/total = 0
	for(var/C in ram_sources)
		total += ram_sources[C]
	return total

/datum/ai_shared_resources/proc/update_resources()
	previous_ram = total_ram()
	ram_sources = list()
	cpu_sources = list()
	for(var/datum/ai_network/N in networks)
		ram_sources[N] += N.total_ram()
		cpu_sources[N] += N.total_cpu()
	update_allocations()

/datum/ai_shared_resources/proc/join_resources(datum/ai_shared_resources/new_resources)

	for(var/RU in new_resources.ram_assigned)
		ram_assigned[RU] = new_resources.ram_assigned[RU]

	for(var/CU in new_resources.cpu_assigned)
		cpu_assigned[CU] = (1 - total_cpu_assigned())

	for(var/datum/ai_network/N in new_resources.networks)
		networks |= N
		N.resources = src

	update_resources()
	update_allocations()
	qdel(new_resources)

/datum/ai_shared_resources/proc/split_resources(datum/ai_network/split_network)
	var/network_ram = split_network.total_ram()
	var/network_cpu = split_network.total_cpu()

	var/network_ram_assign = list()
	var/network_cpu_assign = list()

	var/network_ais = split_network.ai_list
	for(var/A in cpu_assigned)
		if(A in network_ais)
			network_cpu_assign[A] = cpu_assigned[A]
			cpu_assigned[A] = 0

	for(var/A in ram_assigned)
		if(A in network_ais)
			network_ram_assign[A] = ram_assigned[A]
			ram_assigned[A] = 0

	networks -= split_network
	update_resources()

	var/datum/ai_shared_resources/NR = new(network_cpu, network_ram, network_cpu_assign, network_ram_assign)
	split_network.resources = NR
	split_network.resources.networks += split_network


/datum/ai_shared_resources/proc/update_allocations()
	//Do we have the same amount or more RAM than before? Do nothing
	var/total_ram = total_ram()
	if(total_ram >= previous_ram)
		return
	//Find out how much is actually assigned. We can have more total_cpu than the sum of cpu_assigned. Same with RAM
	var/total_assigned_ram = total_ram_assigned()
	//If we have less assigned  ram than we have cpu and ram, just return, everything is fine.
	if(total_assigned_ram < total_ram)
		return

	//Copy the lists of assigned resources so we don't manipulate the list prematurely.
	var/list/ram_assigned_copy = ram_assigned.Copy()
	//List of touched AIs so we can notify them at the end.
	var/list/affected_AIs = list()

	
	if(total_assigned_ram > total_ram)
		var/needed_amount = total_assigned_ram - total_ram
		for(var/A in ram_assigned_copy)
			var/mob/living/silicon/ai/AI = A
			if((ram_assigned_copy[AI] - AI.dashboard.free_ram) >= needed_amount)
				ram_assigned_copy[AI] -= needed_amount
				total_assigned_ram -= needed_amount
				affected_AIs |= AI
				break
			else if(ram_assigned_copy[AI])
				var/amount = ram_assigned_copy[AI] - AI.dashboard.free_ram
				ram_assigned_copy[AI] -= amount
				affected_AIs |= AI
				needed_amount -= amount
				total_assigned_ram -= amount
				if(total_ram >= total_assigned_ram)
					break
	//Set the actual values of the assigned to our manipulated copies. Bypass helper procs as we assume we're correct.
	ram_assigned = ram_assigned_copy
	
	to_chat(affected_AIs, span_warning("You have been deducted memory capacity. Please contact your network administrator if you believe this to be an error."))



/datum/ai_shared_resources/proc/set_cpu(mob/living/silicon/ai/AI, amount)

	if(!AI)
		return
	if(amount > 1 || amount < 0)
		return
	if(!istype(AI))
		return
	cpu_assigned[AI] = amount

	update_allocations()


/datum/ai_shared_resources/proc/add_ram(mob/living/silicon/ai/AI, amount)

	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	ram_assigned[AI] += amount

	update_allocations()


/datum/ai_shared_resources/proc/remove_ram(mob/living/silicon/ai/AI, amount)

	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	if(ram_assigned[AI] - amount < 0)
		ram_assigned[AI] = 0
	else
		ram_assigned[AI] -= amount

	update_allocations()


/datum/ai_shared_resources/proc/clear_ai_resources(mob/living/silicon/ai/AI)
	if(!AI || !istype(AI))
		return

	remove_ram(AI, ram_assigned[AI])
	cpu_assigned[AI] = 0

	update_allocations()

