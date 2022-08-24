/obj/item/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet-red"
	var/icon_state_base = "tablet"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "menu"
	id_rename = TRUE
	hardware_flag = PROGRAM_TABLET
	max_hardware_size = WEIGHT_CLASS_SMALL
	w_class = WEIGHT_CLASS_NORMAL
	max_bays = 3
	steel_sheet_cost = 1
	slot_flags = ITEM_SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3 //Same as the PDA
	interact_sounds = list('sound/machines/computers/pda_click.ogg')

	var/list/variants = list("red","green","yellow","blue","black","purple","white","brown","orange")
	var/finish_color = null

/obj/item/modular_computer/tablet/update_icon()
	..()
	if (!isnull(variants))
		if(!finish_color)
			finish_color = pick(variants)
		icon_state = "[icon_state_base]-[finish_color]"
		icon_state_unpowered = "[icon_state_base]-[finish_color]"
		icon_state_powered = "[icon_state_base]-[finish_color]"


/obj/item/modular_computer/tablet/syndicate_contract_uplink
	name = "contractor tablet"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "assign"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	comp_light_luminosity = 6.3
	variants = null

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	comp_light_luminosity = 6.3
	finish_color = "crimson"
	device_theme = "syndicate"
	light_color = COLOR_RED

/obj/item/modular_computer/tablet/nukeops/emag_act(mob/user)
	if(!enabled)
		to_chat(user, "<span class='warning'>You'd need to turn the [src] on first.</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You swipe \the [src]. It's screen briefly shows a message reading \"MEMORY CODE INJECTION DETECTED AND SUCCESSFULLY QUARANTINED\".</span>")
	return FALSE

/obj/item/modular_computer/tablet/proc/pda_no_detonate()
	return COMPONENT_PDA_NO_DETONATE
