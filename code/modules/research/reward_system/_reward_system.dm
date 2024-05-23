// Filled out in code/modules/research/techweb/_techweb_node.dm Initialize()
// Lists of IDs (strings) which can be accessed via SSresearch.techweb_node_by_id(id)
// Assoc list, id = TRUE
GLOBAL_LIST_EMPTY(security_nodes)
GLOBAL_LIST_EMPTY(medical_nodes)
GLOBAL_LIST_EMPTY(cargo_nodes)
GLOBAL_LIST_EMPTY(service_nodes)
GLOBAL_LIST_EMPTY(science_nodes)
GLOBAL_LIST_EMPTY(engineering_nodes)
// A reward system framework for crew: By doing their jobs, they get to progress towards research nodes for their department
// Must be implemented very carefully to avoid exploitation, it should be very boring or annoying to try and exploit it at least
/obj/machinery/computer/department_reward
	name = "departmental research console (ERROR)"
	desc = "A primitive version of the famous R&D console used to unlock department-relevant research."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/department_reward
	light_color = LIGHT_COLOR_BLUE
	var/datum/techweb/linked_techweb
	var/list/nodes_available = null // pass by reference, not .Copy()
	var/points = 0
	var/department_display = "ERROR"

/obj/machinery/computer/department_reward/Initialize(mapload)
	. = ..()
	linked_techweb = SSresearch.science_tech

/obj/machinery/computer/department_reward/proc/check_reward(delta_time)
	return 0

/obj/machinery/computer/department_reward/process(delta_time)
	if(!is_operational())
		return
	points += check_reward(delta_time)

/obj/machinery/computer/department_reward/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational())
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DepartmentReward", name)
		ui.open()

/obj/machinery/computer/department_reward/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/computer/department_reward/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["department"] = department_display
	data["nodes"] = list()
	if(nodes_available)
		for(var/node_id in nodes_available)
			if(!nodes_available[node_id])
				continue
			if(linked_techweb.researched_nodes[node_id])
				continue
			if(!linked_techweb.available_nodes[node_id])
				continue
			var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)
			var/node_price = node.get_price(linked_techweb)[TECHWEB_POINT_TYPE_GENERIC]
			if(!node_price)
				continue
			var/node_entry = list()
			node_entry["name"] = node.display_name
			node_entry["id"] = node_id
			node_entry["purchasable"] = node_price < points
			node_entry["price"] = node_price
			node_entry["designs"] = list()
			var/design_count = 0
			for(var/design_id in node.design_ids)
				design_count++
				if(design_count <= 14)
					node_entry["designs"] |= design_id
			data["nodes"] += list(node_entry)
	return data

/obj/machinery/computer/department_reward/ui_act(action, params)
	if(..())
		return

	if(!is_operational())
		return

	switch(action)
		if("purchase")
			var/node_id = params["node_id"]
			if(!(nodes_available[node_id]))
				return
			if(linked_techweb.researched_nodes[node_id])
				return
			if(!linked_techweb.available_nodes[node_id])
				return
			var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)
			var/node_price = node.get_price(linked_techweb)[TECHWEB_POINT_TYPE_GENERIC]
			if(!node_price)
				return
			if(node_price > points)
				return
			if(!linked_techweb.research_node_id(node_id, TRUE, FALSE))
				return
			points -= node_price
			say("Researched [node.display_name]!")
			return TRUE
