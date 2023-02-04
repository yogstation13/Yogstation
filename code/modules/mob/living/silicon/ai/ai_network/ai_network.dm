////////////////////////////////////////////
// AI NETWORK DATUM
// each contiguous network of ethernet cables & AI machinery
/////////////////////////////////////
/datum/ai_network
	var/number					// unique id
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all connected machines

	var/list/ai_list = list() 	//List of all AIs in this network
	var/list/reviving_ais = list()
	var/list/decryption_drives = list()

	var/list/remote_networks = list()
	
	var/previous_ram = 0

	var/datum/ai_shared_resources/resources
	//Cash from crypto, can be withdrawn at network console
	var/bitcoin_payout = 0

	var/temp_limit = AI_TEMP_LIMIT

	var/local_cpu_usage = list() //How we use CPU locally

	var/label

	///Allows AI to instantly open doors, access APCs and use air alarms
	var/obj/machinery/ai/master_subcontroller/cached_subcontroller 


	

/datum/ai_network/New()
	SSmachines.ainets += src
	label = num2hex(rand(1,65535), -1)
	resources = new(starting_network = src)

/datum/ai_network/Destroy()
	//Go away references, you suck!
	for(var/obj/structure/ethernet_cable/C in cables)
		cables -= C
		C.network = null
	for(var/obj/machinery/ai/M in nodes)
		nodes -= M
		M.network = null

	resources.networks -= src
	
	if(!length(resources.networks))
		qdel(resources)

	resources = null

	SSmachines.ainets -= src
	return ..()

/datum/ai_network/process()
	var/total_cpu = resources.total_cpu()
	var/resources_assigned = resources.cpu_assigned[src] ? resources.cpu_assigned[src] : 0

	if(local_cpu_usage[AI_CRYPTO])
		var/points = max(round(AI_RESEARCH_PER_CPU * (local_cpu_usage[AI_CRYPTO] * total_cpu * resources_assigned)), 0)
		points = clamp(points, 0, MAX_AI_BITCOIN_MINED_PER_TICK)
		bitcoin_payout += points * AI_BITCOIN_PRICE

	if(local_cpu_usage[AI_RESEARCH])
		var/points = max(round(AI_RESEARCH_PER_CPU * (local_cpu_usage[AI_RESEARCH] * total_cpu * resources_assigned)), 0)
		points = clamp(points * AI_REGULAR_RESEARCH_POINT_MULTIPLIER, 0, MAX_AI_REGULAR_RESEARCH_PER_TICK)
		SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_DEFAULT = points))

	if(local_cpu_usage[AI_REVIVAL])
		var/points = max(round(AI_RESEARCH_PER_CPU * (local_cpu_usage[AI_REVIVAL] * total_cpu * resources_assigned)), 0)
		points = max(0, points)
		var/total_reviving_ais = reviving_ais.len
		if(total_reviving_ais)
			var/distributed_points = points / total_reviving_ais
			for(var/obj/machinery/ai/data_core/DC in reviving_ais)
				if(!DC.dead_ai_blackbox)
					reviving_ais -= DC
				DC.dead_ai_blackbox.processing_progress += distributed_points
				DC.dead_ai_blackbox.living_ticks = AI_BLACKBOX_LIFETIME
				if(DC.dead_ai_blackbox.processing_progress >= AI_BLACKBOX_PROCESSING_REQUIREMENT)
					DC.dead_ai_blackbox.stored_ai.revive(TRUE)
					DC.transfer_ai(DC.dead_ai_blackbox.stored_ai)
					DC.dead_ai_blackbox.stored_ai = null
					QDEL_NULL(DC.dead_ai_blackbox)
					reviving_ais -= DC

	if(local_cpu_usage[AI_PUZZLE])
		var/points = max(round(AI_RESEARCH_PER_CPU * (local_cpu_usage[AI_PUZZLE] * total_cpu * resources_assigned)), 0)
		points = max(0, points)
		var/total_decrypting_drives = decryption_drives.len
		if(total_decrypting_drives)
			var/distributed_points = points / total_decrypting_drives
			for(var/obj/machinery/ai/server_cabinet/SC in decryption_drives)
				if(!SC.puzzle_disk)
					decryption_drives -= SC
					continue
				SC.puzzle_disk.decryption_progress += distributed_points
				if(SC.puzzle_disk.decryption_progress >= (AI_FLOPPY_DECRYPTION_COST * (GLOB.decrypted_puzzle_disks + 1) ** AI_FLOPPY_EXPONENT))
					SC.puzzle_disk.decrypted = TRUE
					SC.puzzle_disk.forceMove(SC.drop_location())
					SC.puzzle_disk.name = "decrypted floppy drive"
					decryption_drives -= SC

	var/locally_used = 0
	for(var/A in local_cpu_usage)
		locally_used += local_cpu_usage[A]
	
	var/research_points = max(round(AI_RESEARCH_PER_CPU * ((1 - locally_used) * total_cpu * resources_assigned)), 0)
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_AI = research_points))
	


/datum/ai_network/proc/is_empty()
	return !cables.len && !nodes.len

//remove a cable from the current network
//if the network is then empty, delete it
//Warning : this proc DON'T check if the cable exists
/datum/ai_network/proc/remove_cable(obj/structure/ethernet_cable/C)
	cables -= C
	C.network = null
	if(is_empty())//the network is now empty...
		qdel(src)///... delete it

//add a cable to the current network
//Warning : this proc DON'T check if the cable exists
/datum/ai_network/proc/add_cable(obj/structure/ethernet_cable/C)
	if(C.network)// if C already has a network...
		if(C.network == src)
			return
		else
			C.network.remove_cable(C) //..remove it
	C.network = src
	cables +=C

//remove a power machine from the current network
//if the network is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/ai_network/proc/remove_machine(obj/machinery/ai/M)
	nodes -=M
	M.network = null
	if(is_empty())//the network is now empty...
		qdel(src)///... delete it

//add a power machine to the current network
//Warning : this proc DOESN'T check if the machine exists
/datum/ai_network/proc/add_machine(obj/machinery/ai/M)
	if(M.network)// if M already has a network...
		if(M.network == src)
			return
		else
			M.disconnect_from_network()//..remove it
	M.network = src
	nodes[M] = M

/datum/ai_network/proc/find_data_core()
	for(var/obj/machinery/ai/data_core/core in get_all_nodes())
		if(!QDELETED(core) && core.can_transfer_ai())
			return core

/datum/ai_network/proc/find_subcontroller()
	for(var/obj/machinery/ai/master_subcontroller/controller in get_all_nodes())
		if(!QDELETED(controller) && controller.on)
			return controller

/datum/ai_network/proc/get_all_nodes(checked_nets = list())
	. = nodes.Copy()
	for(var/datum/ai_network/net in resources.networks)
		if(net == src)
			continue
		. += net.nodes
		
/datum/ai_network/proc/get_local_nodes_oftype(type_to_check)
	. = list()
	for(var/A in nodes)
		if(istype(A, type_to_check))
			. += A


/datum/ai_network/proc/get_all_ais(checked_nets = list())
	. = ai_list.Copy()
	for(var/datum/ai_network/net in resources.networks)
		if(net == src)
			continue
		. += net.ai_list

/datum/ai_network/proc/remove_ai(mob/living/silicon/ai/AI)
	resources.cpu_assigned[AI] = 0
	resources.ram_assigned[AI] = 0
	ai_list -= AI


/datum/ai_network/proc/update_resources()
	resources?.update_resources()


/datum/ai_network/proc/total_cpu()
	. = 0
	for(var/obj/machinery/ai/server_cabinet/C in nodes)
		. += C.total_cpu

/datum/ai_network/proc/total_ram()
	. = 0
	for(var/obj/machinery/ai/server_cabinet/C in nodes)
		. += C.total_ram


/datum/ai_network/proc/get_temp_limit()
	return temp_limit

/datum/ai_network/proc/total_cpu_assigned()
	return resources.total_cpu_assigned()

/datum/ai_network/proc/total_ram_assigned()
	return resources.total_ram_assigned()

/*
/datum/ai_network/proc/rebuild_remote(externally_linked = FALSE, touched_networks = list())
	if(!resources)
		return
	if(src in touched_networks)
		return
	touched_networks += src
	var/list/networks_to_rebuild = list()
	for(var/obj/machinery/ai/networking/N in nodes)
		if(N.partner && N.partner.network && N.partner.network.resources)
			if(N.partner.network in touched_networks)
				message_admins("[REF(src)] found touched_network!")
				continue
			message_admins("[REF(src)] found no mismatched resources!")
			if(N.partner.network.resources != resources)
				if(length(N.partner.network.resources.networks) > length(resources.networks)) //We merge into the biggest network
					N.partner.network.resources.add_resource(resources)
				else
					resources.add_resource(N.partner.network.resources)
				message_admins("[REF(src)] actually rebuilt!")
				externally_linked = TRUE

			networks_to_rebuild += N.partner.network
			

	if(!externally_linked)
		resources.split_resources(src)

	for(var/datum/ai_network/AN in networks_to_rebuild)
		message_admins("Telling network [REF(AN)] to rebuild!")
		AN.rebuild_remote(TRUE, touched_networks)

*/

/datum/ai_network/proc/rebuild_remote(externally_linked = FALSE, touched_networks = list(), datum/ai_network/originator)
	if(src in touched_networks)
		return
	
	if(!originator)
		originator = src

	var/list/found_networks = list()
	for(var/obj/machinery/ai/networking/N in nodes)
		if(N.partner && N.partner.network && N.partner.network.resources)
			if(N.partner.network == src)
				continue
			externally_linked = TRUE
			found_networks += N.partner.network

	if(!externally_linked)
		if(resources && length(resources.networks) > 1) //We only split if we are actually connected to an external resource network
			resources.split_resources(src)

	found_networks -= touched_networks

	uniqueList_inplace(found_networks)

	for(var/datum/ai_network/AN in found_networks)
		if(originator.resources != AN.resources)
			if(length(originator.resources.networks) > length(AN.resources.networks))
				originator.resources.add_resource(AN.resources)
			else
				AN.resources.add_resource(originator.resources)
		AN.rebuild_remote(TRUE, found_networks + src, originator)


/datum/ai_network/proc/network_machine_disconnected(datum/ai_network/new_network)
	var/obj/machinery/ai/data_core/core = new_network.find_data_core()
	if(!core) //No core in disconnected network? no need to ask them to switch
		return

	for(var/mob/living/silicon/ai/AI in get_all_ais())
		addtimer(CALLBACK(src, .proc/disconnection_switch, AI, new_network), 0)
		
			

/datum/ai_network/proc/disconnection_switch(mob/living/silicon/ai/AI, datum/ai_network/new_network)
	var/obj/machinery/ai/data_core/core = new_network.find_data_core()
	if(!core)
		return
	var/area/core_area = get_area(core)
		
	var/choice = tgui_input_list(AI, "Two networks you're connected to have been disconnected, where do you want to transfer your main consciousness?", "Network Disconnection", list("Current network", "New network in [core_area]"))
	if(choice == "Current network")
		return

	if(!core || QDELETED(core) || !core.can_transfer_ai())
		to_chat(AI, span_warning("Something went wrong while transferring you! You're still bound to your original network."))
		return
	core.transfer_AI(AI)


/proc/merge_ainets(datum/ai_network/net1, datum/ai_network/net2)
	if(!net1 || !net2) //if one of the network doesn't exist, return
		return

	if(net1 == net2) //don't merge same networks
		return

	//We assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.cables.len < net2.cables.len)	//net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp


	//merge net2 into net1
	for(var/obj/structure/ethernet_cable/Cable in net2.cables) //merge cables
		net1.add_cable(Cable)
	
	for(var/obj/machinery/ai/Node in net2.nodes) //merge power machines 
		if(!Node.connect_to_network())
			Node.disconnect_from_network() //if somehow we can't connect the machine to the new network, disconnect it from the old nonetheless


	net1.ai_list += net2.ai_list //AIs can only be in 1 network at a time
	/*
	net1.rebuild_remote()
	net2.rebuild_remote() */
	
	net1.update_resources()


	return net1


//remove the old network and replace it with a new one throughout the network.
/proc/propagate_ai_network(obj/O, datum/ai_network/AN)
	var/list/worklist = list()
	var/list/found_machines = list()
	var/index = 1
	var/obj/P = null

	worklist+=O //start propagating from the passed object

	while(index<=worklist.len) //until we've exhausted all power objects
		P = worklist[index] //get the next power object found
		index++

		if( istype(P, /obj/structure/ethernet_cable))
			var/obj/structure/ethernet_cable/C = P
			if(C.network != AN) //add it to the network, if it isn't already there
				AN.add_cable(C)
			worklist |= C.get_connections() //get adjacents power objects, with or without a network
		else if(P.anchored && istype(P, /obj/machinery/ai))
			var/obj/machinery/ai/M = P
			found_machines |= M //we wait until the network is fully propagates to connect the machines
		else
			continue

	//now that the network is set, connect found machines to it
	for(var/obj/machinery/ai/PM in found_machines)
		if(!PM.connect_to_network()) //couldn't find a node on its turf...
			PM.disconnect_from_network() //... so disconnect if already on a network

	//AN.rebuild_remote()




/proc/ai_list(turf/T, source, d, unmarked = FALSE, cable_only = FALSE)
	. = list()

	for(var/AM in T)
		if(AM == source)
			continue			//we don't want to return source

		if(!cable_only && istype(AM, /obj/machinery/ai))
			var/obj/machinery/ai/P = AM
			if(P.network == 0)
				continue

			if(!unmarked || !P.network)		//if unmarked we only return things with no network
				if(d == 0)
					. += P

		else if(istype(AM, /obj/structure/ethernet_cable))
			var/obj/structure/ethernet_cable/C = AM

			if(!unmarked || !C.network)
				if(C.d1 == d || C.d2 == d)
					. += C
	return .

/proc/_debug_ai_networks()
	var/i = 1
	var/list/resource_list = list()
	for(var/datum/ai_network/AN in SSmachines.ainets)
		var/list/interconnections = list()
		for(var/obj/machinery/ai/networking/N in AN.nodes)
			if(N.partner && N.partner.network)
				interconnections += "#[i] Networking[ADMIN_JMP(N)] connected to [ADMIN_JMP(N.partner)]/[REF(N.partner.network)] | Same resources: [N.partner.network.resources == AN.resources ? "<font color='green'>YES</font>" : "<font color='red'>NO</font>"]"
				i++
		message_admins("Network: [REF(AN)] | Resources: [REF(AN.resources)]")
		for(var/A in interconnections)
			message_admins(A)
		resource_list |= AN.resources
	message_admins("----------------------------")
	for(var/datum/ai_shared_resources/ASR in resource_list)
		message_admins("Resource count [REF(ASR)], CPU: [ASR.total_cpu()] | RAM: [ASR.total_ram()]")

