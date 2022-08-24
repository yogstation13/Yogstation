/obj/item/modular_computer/laptop/preset
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive,
								/obj/item/computer_hardware/network_card,
								/obj/item/computer_hardware/card_slot)

/obj/item/modular_computer/laptop/preset/civillian
	desc = "A low-end laptop often used for personal recreation."
	starting_files = list(new /datum/computer_file/program/chatclient)

/obj/item/modular_computer/laptop/preset/brig_physician
	desc = "A low-end laptop often used by brig physicians."
	starting_files = list(new /datum/computer_file/program/secureye)
