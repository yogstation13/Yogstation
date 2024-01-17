// This is literally the worst possible cheap phone
/obj/item/modular_computer/tablet/phone/preset
	starting_files = list(	new /datum/computer_file/program/budgetorders,
							new /datum/computer_file/program/bounty_board)

/obj/item/modular_computer/tablet/phone/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer/micro,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/phone/preset/advanced
	starting_components = list(	/obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot)

/obj/item/modular_computer/tablet/phone/preset/cargo
	starting_components = list(	/obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/phone/preset/advanced/atmos
	starting_components = list(	/obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/sensorpackage)

/obj/item/modular_computer/tablet/phone/preset/advanced/command
	starting_components = list(	/obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/card_slot/secondary,
								/obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/phone/preset/advanced/command/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/card_mod,
		new /datum/computer_file/program/synth_requester
	)	
	. = ..()

/obj/item/modular_computer/tablet/phone/preset/advanced/command/cap
	finish_color = "yellow"
	pen_type = /obj/item/pen/fountain/captain

/obj/item/modular_computer/tablet/phone/preset/advanced/command/cap/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(pda_no_detonate))

/obj/item/modular_computer/tablet/phone/preset/advanced/command/hop
	finish_color = "brown"

/obj/item/modular_computer/tablet/phone/preset/advanced/command/hop/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/cargobounty
	)	
	. = ..()

/obj/item/modular_computer/tablet/phone/preset/advanced/command/hos
	finish_color = "red"

/obj/item/modular_computer/tablet/phone/preset/advanced/command/ce
	starting_components = list(	/obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/pda,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/card_slot/secondary,
								/obj/item/computer_hardware/sensorpackage)
	finish_color = "orange"

/obj/item/modular_computer/tablet/phone/preset/advanced/command/ce/Initialize(mapload)
	starting_files |= list(	new /datum/computer_file/program/alarm_monitor,
							new /datum/computer_file/program/supermatter_monitor,
							new /datum/computer_file/program/nuclear_monitor,
							new /datum/computer_file/program/energy_harvester_control)
	. = ..()

/obj/item/modular_computer/tablet/phone/preset/advanced/command/rd
	finish_color = "purple"
	pen_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/phone/preset/advanced/command/rd/Initialize(mapload)
	starting_files |= list(	new /datum/computer_file/program/robocontrol)
	. = ..()

/obj/item/modular_computer/tablet/phone/preset/advanced/command/cmo
	finish_color = "white"

/obj/item/modular_computer/tablet/phone/preset/advanced/command/cmo/Initialize(mapload)
	starting_files |= list(	new /datum/computer_file/program/crew_monitor)
	. = ..()
