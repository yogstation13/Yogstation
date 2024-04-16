/obj/item/modular_computer/tablet/pda
	name = "\improper PDA"
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda"
	icon_state_base = "tablet"
	icon_state_unpowered = "pda"
	icon_state_powered = "pda"
	icon_state_menu = "menu"
	greyscale_config = /datum/greyscale_config/tablet
	greyscale_colors = "#999875#a92323"

	variants = null

	hardware_flag = PROGRAM_PDA
	max_hardware_size = WEIGHT_CLASS_SMALL
	w_class = WEIGHT_CLASS_SMALL
	max_bays = 1
	steel_sheet_cost = 1
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT

/obj/item/modular_computer/tablet/pda/update_overlays()
	. = ..()
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/computer_id_slot = card_slot2?.stored_card || card_slot?.stored_card
	if(computer_id_slot)
		. += mutable_appearance(initial(icon), "id_overlay")
	if(light_on)
		. += mutable_appearance(initial(icon), "light_overlay")
	if(inserted_pai)
		. += mutable_appearance(initial(icon), "pai_inserted")

/obj/item/modular_computer/tablet/pda/verb/verb_toggle_light()
	set category = "Object"
	set name = "Toggle Flashlight"

	toggle_flashlight()
