/datum/computer_file/program/ai_network_interface
	filename = "aiinterface"
	filedesc = "AI Network Interface"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "power_monitor"
	extended_desc = "This program connects to a local AI network to allow for administrative access"
	ui_header = "power_norm.gif"
	transfer_access = ACCESS_NETWORK
	usage_flags = PROGRAM_CONSOLE 
	requires_ntnet = FALSE
	size = 8
	tgui_id = "NtosAIMonitor"
	program_icon = "network-wired"

	var/obj/structure/ethernet_cable/attached_cable


/datum/computer_file/program/ai_network_interface/run_program(mob/living/user)
	. = ..(user)
	search()


/datum/computer_file/program/ai_network_interface/process_tick()
	if(!get_ainet())
		search()
	else
		record()

/datum/computer_file/program/ai_network_interface/proc/search()
	var/turf/T = get_turf(computer)
	attached_cable = locate(/obj/structure/ethernet_cable) in T
	if(attached_cable)
		return

/datum/computer_file/program/ai_network_interface/proc/get_ainet()
	if(attached_cable)
		return attached_cable.ai_network
	return FALSE

/datum/computer_file/program/ai_network_interface/ui_data()
	var/list/data = get_header_data()

	return data
