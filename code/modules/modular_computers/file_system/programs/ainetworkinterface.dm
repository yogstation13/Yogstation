/datum/computer_file/program/ai_network_interface
	filename = "aiinterface"
	filedesc = "AI Network Interface"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "power_monitor"
	extended_desc = "This program connects to a local AI network to allow for administrative access"
	ui_header = "power_norm.gif"
	transfer_access = ACCESS_NETWORK
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET
	requires_ntnet = FALSE
	size = 8
	tgui_id = "NtosAIMonitor"
	program_icon = "network-wired"

	var/obj/structure/ethernet_cable/attached_cable


/datum/computer_file/program/ai_network_interface/run_program(mob/living/user)
	. = ..(user)
	if(ismachinery(computer.physical))
		search()


/datum/computer_file/program/ai_network_interface/process_tick()
	if(ismachinery(computer.physical) && !get_ainet())
		search()

/datum/computer_file/program/ai_network_interface/proc/search()
	var/turf/T = get_turf(computer)
	attached_cable = locate(/obj/structure/ethernet_cable) in T
	if(attached_cable)
		return

/datum/computer_file/program/ai_network_interface/proc/get_ainet()
	if(ismachinery(computer.physical))
		if(attached_cable)
			return attached_cable.network
	if(computer.all_components[MC_AI_NETWORK])
		var/obj/item/computer_hardware/ai_interface/ai_interface = computer.all_components[MC_AI_NETWORK]
		if(ai_interface)
			return ai_interface.get_network()
	return FALSE

/datum/computer_file/program/ai_network_interface/ui_data()
	var/list/data = get_header_data()
	var/datum/ai_network/net = get_ainet()
	data["has_ai_net"] = net
	data["physical_pc"] = ismachinery(computer)

	return data
