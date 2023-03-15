/obj/item/modular_computer/laptop/preset
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot)

/obj/item/modular_computer/laptop/preset/civillian
	desc = "A low-end laptop often used for personal recreation."

/obj/item/modular_computer/laptop/preset/paramedic//not actually given to a paramedic, just a base-line for the brig phys and mining medic laptops
/obj/item/modular_computer/laptop/preset/paramedic/Initialize()
	starting_files |= list(
		new /datum/computer_file/program/crew_monitor,
		new /datum/computer_file/program/radar/lifeline
	)	
	. = ..()

/obj/item/modular_computer/laptop/preset/paramedic/brig_physician
	desc = "A low-end laptop often used by brig physicians."
/obj/item/modular_computer/laptop/preset/paramedic/brig_physician/Initialize()
	starting_files |= list(
		new /datum/computer_file/program/secureye
	)
	. = ..()

/obj/item/modular_computer/laptop/preset/paramedic/mining_medic
	desc = "A low-end laptop often used by mining medics. Comes with an upgraded network card to allow for use while off Station."
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive,
								/obj/item/computer_hardware/network_card/advanced,
								/obj/item/computer_hardware/card_slot)

/obj/item/modular_computer/laptop/preset/paramedic/mining_medic/Initialize()
	starting_files |= list(
		new /datum/computer_file/program/secureye/mining
	)
	. = ..()

/obj/item/modular_computer/laptop/preset/network_admin
	desc = "A multi-purpose laptop often used by network admins."
	starting_files = list(new /datum/computer_file/program/ai/ai_network_interface)
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/ai_interface,
								/obj/item/computer_hardware/ai_slot,
								/obj/item/computer_hardware/card_slot)
