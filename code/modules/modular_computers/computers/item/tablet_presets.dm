
// This is literally the worst possible cheap tablet
/obj/item/modular_computer/tablet/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."

<<<<<<< HEAD
/obj/item/modular_computer/tablet/preset/cheap/Initialize()
=======
/obj/item/device/modular_computer/tablet/preset/cheap/Initialize()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer/micro))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)

// Alternative version, an average one, for higher ranked positions mostly
<<<<<<< HEAD
/obj/item/modular_computer/tablet/preset/advanced/Initialize()
=======
/obj/item/device/modular_computer/tablet/preset/advanced/Initialize()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/printer/mini)

<<<<<<< HEAD
/obj/item/modular_computer/tablet/preset/cargo/Initialize()
=======
/obj/item/device/modular_computer/tablet/preset/cargo/Initialize()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/printer/mini)
