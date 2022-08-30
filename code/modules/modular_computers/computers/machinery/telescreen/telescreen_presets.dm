/obj/machinery/modular_computer/telescreen/preset
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer/micro,
								/obj/item/computer_hardware/recharger/APC,
								/obj/item/computer_hardware/hard_drive/small,
								/obj/item/computer_hardware/network_card)

/obj/machinery/modular_computer/telescreen/preset/Initialize()
	..()
	cpu.enabled = TRUE

// ===== ENGINEERING TELESCREEN =====
/obj/machinery/modular_computer/telescreen/preset/engineering
	
	starting_files = list(	new /datum/computer_file/program/alarm_monitor,
							new /datum/computer_file/program/supermatter_monitor)
	initial_program = /datum/computer_file/program/alarm_monitor

// ===== MEDICAL TELESCREEN =====
/obj/machinery/modular_computer/telescreen/preset/medical
	
	starting_files = list(	new /datum/computer_file/program/crew_monitor)
	initial_program = /datum/computer_file/program/crew_monitor

// ===== CARGO TELESCREEN =====
/obj/machinery/modular_computer/telescreen/preset/medical
	
	starting_files = list(	new /datum/computer_file/program/crew_monitor)
	initial_program = /datum/computer_file/program/crew_monitor


////////////////
// Wallframes //
////////////////

/obj/item/wallframe/telescreen/preset
	result_path = /obj/machinery/modular_computer/telescreen/preset
