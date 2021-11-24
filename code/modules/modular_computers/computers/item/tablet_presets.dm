
// This is literally the worst possible cheap tablet
/obj/item/modular_computer/tablet/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."

/obj/item/modular_computer/tablet/preset/cheap/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer/micro))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/preset/advanced/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/preset/cargo/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/preset/advanced/atmos/Initialize() //This will be defunct and will be replaced when NtOS PDAs are done
	. = ..()
	install_component(new /obj/item/computer_hardware/sensorpackage)

/obj/item/modular_computer/tablet/preset/advanced/command/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/sensorpackage)
	install_component(new /obj/item/computer_hardware/card_slot/secondary)

/// A simple syndicate tablet, used for comms agents
/obj/item/modular_computer/tablet/preset/syndicate/Initialize()
	. = ..()
	finish_color = "red"
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small/syndicate)
	install_component(new /obj/item/computer_hardware/network_card/advanced)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/printer/mini)
	update_icon()

/// Given by the syndicate as part of the contract uplink bundle - loads in the Contractor Uplink.
/obj/item/modular_computer/tablet/syndicate_contract_uplink/preset/uplink/Initialize()
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = new
	var/datum/computer_file/program/contract_uplink/uplink = new

	active_program = uplink
	uplink.program_state = PROGRAM_STATE_ACTIVE
	uplink.computer = src

	hard_drive.store_file(uplink)

	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(hard_drive)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/printer/mini)

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small/nukeops)
	install_component(new /obj/item/computer_hardware/network_card)

//Phone Presets//

// This is literally the worst possible cheap phone
/obj/item/modular_computer/tablet/phone/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."

/obj/item/modular_computer/tablet/phone/preset/cheap/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer/micro))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/phone/preset/advanced/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/phone/preset/cargo/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/phone/preset/advanced/atmos/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/sensorpackage)

/obj/item/modular_computer/tablet/phone/preset/advanced/command/Initialize()
	. = ..()
	install_component(new /obj/item/computer_hardware/card_slot/secondary)
