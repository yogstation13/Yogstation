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

	var/list/contained_item = list(/obj/item/pen, /obj/item/toy/crayon, /obj/item/lipstick, /obj/item/flashlight/pen, /obj/item/clothing/mask/cigarette)
	var/obj/item/pen_type = /obj/item/pen
	var/obj/item/inserted_item

/obj/item/modular_computer/tablet/Initialize()
	. = ..()
	inserted_item = new pen_type(src)

/obj/item/modular_computer/tablet/AltClick(mob/user)
	if(issilicon(user))
		return ..()

	if(user.canUseTopic(src, BE_CLOSE))
		var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
		var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
		if(card_slot2?.stored_card || card_slot?.stored_card)
			return ..()
		else
			remove_pen()
	else
		return ..()

/obj/item/modular_computer/tablet/examine(mob/user)
	. = ..()
	if(inserted_item && (!isturf(loc)))
		. += span_notice("Alt-click to remove [inserted_item].")

/obj/item/modular_computer/tablet/attackby(obj/item/C, mob/user, params)
	if(is_type_in_list(C, contained_item)) //Checks if there is a pen
		if(inserted_item)
			to_chat(user, span_warning("There is already \a [inserted_item] in \the [src]!"))
		else
			if(!user.transferItemToLoc(C, src))
				return
			to_chat(user, span_notice("You slide \the [C] into \the [src]."))
			inserted_item = C
			update_icon()
	else
		return ..()

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

/obj/item/modular_computer/tablet/Destroy()
	if(inserted_item)
		QDEL_NULL(inserted_item)
	return ..()

/obj/item/modular_computer/tablet/proc/pda_no_detonate()
	return COMPONENT_PDA_NO_DETONATE

/obj/item/modular_computer/tablet/proc/remove_pen()
	if(inserted_item)
		if(usr)
			usr.put_in_hands(inserted_item)
		else
			inserted_item.forceMove(drop_location())
		visible_message(span_notice("Pen ejected!"), null, null, 1)
		inserted_item = null
	else
		visible_message(span_warning("No pen detected in slot!"), null, null, 1)
