GLOBAL_LIST_EMPTY(security_nodes)
GLOBAL_LIST_EMPTY(medical_nodes)
GLOBAL_LIST_EMPTY(cargo_nodes)
GLOBAL_LIST_EMPTY(service_nodes)
GLOBAL_LIST_EMPTY(science_nodes)
GLOBAL_LIST_EMPTY(engineering_nodes)
//Techweb nodes are GLOBAL, there should only be one instance of them in the game. Persistant changes should never be made to them in-game.
//USE SSRESEARCH PROCS TO OBTAIN REFERENCES. DO NOT REFERENCE OUTSIDE OF SSRESEARCH OR YOU WILL FUCK UP GC.

/datum/techweb_node
	var/id
	var/display_name = "Errored Node"
	var/description = "Why are you seeing this?"
	var/hidden = FALSE			//Whether it starts off hidden.
	var/starting_node = FALSE	//Whether it's available without any research.
	var/list/prereq_ids = list()
	var/list/design_ids = list()
	var/list/unlock_ids = list()			//CALCULATED FROM OTHER NODE'S PREREQUISITES. Assoc list id = TRUE.
	var/list/boost_item_paths = list()		//Associative list, path = list(point type = point_value).
	var/autounlock_by_boost = TRUE			//boosting this will autounlock this node.
	var/list/research_costs = list()					//Point cost to research. type = amount
	var/category = "Misc"				//Category
	var/ui_x = 805 // It's location - override this in techweb_layout.dm
	var/ui_y = 805

/datum/techweb_node/error_node
	id = "ERROR"
	display_name = "ERROR"
	description = "This usually means something in the database has corrupted. If it doesn't go away automatically, inform Central Command for their techs to fix it ASAP(tm)"

/datum/techweb_node/proc/Initialize()
	//Make lists associative for lookup
	for(var/pre_id in prereq_ids)
		prereq_ids[pre_id] = TRUE
	for(var/des_id in design_ids)
		design_ids[des_id] = TRUE
		var/datum/design/design = SSresearch.techweb_designs[des_id]
		if(design.departmental_flags & (DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_ARMORY))
			GLOB.security_nodes |= id
		if(design.departmental_flags & DEPARTMENTAL_FLAG_MEDICAL)
			GLOB.medical_nodes |= id
		if(design.departmental_flags & DEPARTMENTAL_FLAG_CARGO)
			GLOB.cargo_nodes |= id
		if(design.departmental_flags & DEPARTMENTAL_FLAG_SERVICE)
			GLOB.service_nodes |= id
		if(design.departmental_flags & DEPARTMENTAL_FLAG_SCIENCE)
			GLOB.science_nodes |= id
		if(design.departmental_flags & DEPARTMENTAL_FLAG_ENGINEERING)
			GLOB.engineering_nodes |= id
	for(var/unl_id in unlock_ids)
		unlock_ids[unl_id] = TRUE

/datum/techweb_node/Destroy()
	SSresearch.techweb_nodes -= id
	return ..()

/datum/techweb_node/serialize_list(list/options)
	. = list()
	VARSET_TO_LIST(., id)
	VARSET_TO_LIST(., display_name)
	VARSET_TO_LIST(., hidden)
	VARSET_TO_LIST(., starting_node)
	VARSET_TO_LIST(., assoc_to_keys(prereq_ids))
	VARSET_TO_LIST(., assoc_to_keys(design_ids))
	VARSET_TO_LIST(., assoc_to_keys(unlock_ids))
	VARSET_TO_LIST(., boost_item_paths)
	VARSET_TO_LIST(., autounlock_by_boost)
	VARSET_TO_LIST(., research_costs)
	VARSET_TO_LIST(., category)

/datum/techweb_node/deserialize_list(list/input, list/options)
	if(!input["id"])
		return
	VARSET_FROM_LIST(input, id)
	VARSET_FROM_LIST(input, display_name)
	VARSET_FROM_LIST(input, hidden)
	VARSET_FROM_LIST(input, starting_node)
	VARSET_FROM_LIST(input, prereq_ids)
	VARSET_FROM_LIST(input, design_ids)
	VARSET_FROM_LIST(input, unlock_ids)
	VARSET_FROM_LIST(input, boost_item_paths)
	VARSET_FROM_LIST(input, autounlock_by_boost)
	VARSET_FROM_LIST(input, research_costs)
	VARSET_FROM_LIST(input, category)
	Initialize()
	return src

/datum/techweb_node/proc/on_design_deletion(datum/design/D)
	prune_design_id(D.id)

/datum/techweb_node/proc/on_node_deletion(datum/techweb_node/TN)
	prune_node_id(TN.id)

/datum/techweb_node/proc/prune_design_id(design_id)
	design_ids -= design_id

/datum/techweb_node/proc/prune_node_id(node_id)
	prereq_ids -= node_id
	unlock_ids -= node_id

/datum/techweb_node/proc/get_price(datum/techweb/host)
	if(host)
		var/list/actual_costs = research_costs
		if(host.boosted_nodes[id])
			var/list/L = host.boosted_nodes[id]
			for(var/i in L)
				if(actual_costs[i])
					actual_costs[i] -= L[i]
		return actual_costs
	else
		return research_costs

/datum/techweb_node/proc/price_display(datum/techweb/TN)
	return techweb_point_display_generic(get_price(TN))
