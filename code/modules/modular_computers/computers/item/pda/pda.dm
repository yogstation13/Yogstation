/obj/item/modular_computer/tablet/pda
	name = "\improper PDA"
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda-red"
	icon_state_base = "pda"
	icon_state_unpowered = "pda"
	icon_state_powered = "pda"
	hardware_flag = PROGRAM_PDA
	max_hardware_size = WEIGHT_CLASS_TINY
	w_class = WEIGHT_CLASS_SMALL
	max_bays = 1
	steel_sheet_cost = 1
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT

/obj/item/modular_computer/tablet/pda/update_icon()
	if(!isnull(variants) && !finish_color && prob(0.1)) // Very rare chance to get a rare skin for PDAs untill I can make them donor only
		finish_color = pick(list("pipboy", "glass", "rainbow"))
	..()
