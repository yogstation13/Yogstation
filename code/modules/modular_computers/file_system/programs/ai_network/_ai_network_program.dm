/datum/computer_file/program/ai
	filename = "DEBUG"
	filedesc = "DEBUG"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "power_monitor"
	extended_desc = "This program connects to a local AI network to allow for administrative access"
	ui_header = "power_norm.gif"
	transfer_access = ACCESS_NETWORK
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET
	requires_ntnet = FALSE
	size = 8
	tgui_id = null
	program_icon = "network-wired"
	available_on_ntnet = FALSE

	var/obj/structure/ethernet_cable/attached_cable


/datum/computer_file/program/ai/run_program(mob/living/user)
	. = ..(user)
	if(ismachinery(computer.physical))
		search()


/datum/computer_file/program/ai/process_tick()
	if(ismachinery(computer.physical) && !get_ainet())
		search()


/datum/computer_file/program/ai/proc/search()
	var/turf/T = get_turf(computer)
	attached_cable = locate(/obj/structure/ethernet_cable) in T
	if(attached_cable)
		return

/datum/computer_file/program/ai/proc/get_ainet()
	if(ismachinery(computer.physical))
		if(attached_cable)
			return attached_cable.network
	if(computer.all_components[MC_AI_NETWORK])
		var/obj/item/computer_hardware/ai_interface/ai_interface = computer.all_components[MC_AI_NETWORK]
		if(ai_interface)
			return ai_interface.get_network()
	return FALSE

/datum/computer_file/program/ai/ui_data(mob/user)
	var/list/data = get_header_data()

	var/datum/ai_network/net = get_ainet()
	data["has_ai_net"] = net

	return data

/datum/computer_file/program/ai/proc/get_ai(get_card = FALSE)
	var/obj/item/computer_hardware/ai_slot/ai_slot

	if(computer)
		ai_slot = computer.all_components[MC_AI]

	if(computer && ai_slot && ai_slot.check_functionality())
		if(ai_slot.enabled && ai_slot.stored_card)
			if(get_card)
				return ai_slot.stored_card
			if(ai_slot.stored_card.AI)
				return ai_slot.stored_card.AI


