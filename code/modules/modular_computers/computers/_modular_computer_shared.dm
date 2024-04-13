
/obj/proc/is_modular_computer()
	return

/obj/proc/get_modular_computer_part(part_type)
	return null

/obj/item/modular_computer/is_modular_computer()
	return TRUE

/obj/item/modular_computer/get_modular_computer_part(part_type)
	if(!part_type)
		stack_trace("get_modular_computer_part() called without a valid part_type")
		return null
	return all_components[part_type]


/obj/machinery/modular_computer/is_modular_computer()
	return TRUE

/obj/machinery/modular_computer/get_modular_computer_part(part_type)
	if(!part_type)
		stack_trace("get_modular_computer_part() called without a valid part_type")
		return null
	return cpu?.all_components[part_type]


/obj/proc/get_modular_computer_parts_examine(mob/user)
	. = list()
	if(!is_modular_computer())
		return

	var/user_is_adjacent = Adjacent(user) //don't reveal full details unless they're close enough to see it on the screen anyway.

	var/obj/item/computer_hardware/ai_slot/ai_slot = get_modular_computer_part(MC_AI)
	if(ai_slot)
		if(ai_slot.stored_card)
			if(user_is_adjacent)
				. += "It has a slot installed for an intelliCard which contains: [ai_slot.stored_card.name]"
			else
				. += "It has a slot installed for an intelliCard, which appears to be occupied."
			. += span_info("Alt-click to eject the intelliCard.")
		else
			. += "It has a slot installed for an intelliCard."

	var/obj/item/computer_hardware/printer/printer_slot = get_modular_computer_part(MC_PRINT)
	if(printer_slot)
		. += "It has a printer installed."
		if(user_is_adjacent)
			. += "The printer's paper levels are at: [printer_slot.stored_paper]/[printer_slot.max_paper].</span>"

	var/obj/item/computer_hardware/ai_interface/ai_interface = get_modular_computer_part(MC_AI_NETWORK)
	if(ai_interface)
		if(ai_interface.connected_cable)
			. += "It has an AI network interface. It is currently connected to an ethernet cable."
		else
			. += "It has an AI network interface."

