// This is literally the worst possible cheap phone
/obj/item/modular_computer/tablet/phone/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer/micro,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/phone/preset/advanced
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot)

/obj/item/modular_computer/tablet/phone/preset/cargo
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/phone/preset/advanced/atmos
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/sensorpackage)

/obj/item/modular_computer/tablet/phone/preset/advanced/command
	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/budgetorders,
							new /datum/computer_file/program/card_mod)
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/card_slot/secondary)

/obj/item/modular_computer/tablet/phone/preset/advanced/command/cap
	finish_color = "yellow"
	pen_type = /obj/item/pen/fountain/captain

/obj/item/modular_computer/tablet/phone/preset/advanced/command/cap/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_PDA_CHECK_DETONATE, .proc/pda_no_detonate)

/obj/item/modular_computer/tablet/phone/preset/advanced/command/hop
	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/budgetorders,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/cargobounty)
	finish_color = "brown"

/obj/item/modular_computer/tablet/phone/preset/advanced/command/hos
	finish_color = "red"

/obj/item/modular_computer/tablet/phone/preset/advanced/command/ce
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/card_slot/secondary,
								/obj/item/computer_hardware/sensorpackage)

	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/budgetorders,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/alarm_monitor)
	finish_color = "orange"

/obj/item/modular_computer/tablet/phone/preset/advanced/command/rd
	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/budgetorders,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/robocontrol)
	finish_color = "purple"
	pen_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/phone/preset/advanced/command/cmo
	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/budgetorders,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/crew_monitor)
	finish_color = "white"
