#define PDA_EJECT "Eject"
#define PDA_GREYSCALE_CONFIG 1
#define PDA_GREYSCALE_COLORS 2
#define PDA_ICON 3
#define PDA_ICON_STATE 4
#define PDA_ICON_STATE_UNPOWERED 5
#define PDA_ICON_STATE_POWERED 6
#define PHONE_FINISH_COLOR 1

/obj/machinery/pdapainter
	name = "\improper PDA painter"
	desc = "A PDA painting machine. To use, simply insert your PDA or phone and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = TRUE
	max_integrity = 200
	var/obj/item/modular_computer/tablet/inserted_pda
	var/static/list/pda_skins
	var/static/list/phone_skins

/obj/machinery/pdapainter/Initialize(mapload)
	. = ..()
	if(!pda_skins)
		pda_skins = list()
	if(!phone_skins)
		phone_skins = list()
	load_pda_skins()

/obj/machinery/pdapainter/update_icon_state()
	. = ..()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/pdapainter/update_overlays()
	. = ..()
	if(stat & BROKEN)
		return
	if(inserted_pda)
		. += "[initial(icon_state)]-closed"

/obj/machinery/pdapainter/proc/load_pda_skins()
	if(length(pda_skins)) // We only want to load once
		return

	// PDAs
	for(var/obj/item/modular_computer/tablet/pda/preset/pda_type as anything in subtypesof(/obj/item/modular_computer/tablet/pda/preset))
		if(!initial(pda_type.reskin_name))
			continue
		if(pda_skins[initial(pda_type.reskin_name)])
			continue
		var/list/combination = list(
			initial(pda_type.greyscale_config),
			initial(pda_type.greyscale_colors),
			initial(pda_type.icon),
			initial(pda_type.icon_state),
			initial(pda_type.icon_state_unpowered),
			initial(pda_type.icon_state_powered),
		)
		pda_skins[initial(pda_type.reskin_name)] = combination

	// Phones
	for(var/obj/item/modular_computer/tablet/phone/preset/phone_type as anything in subtypesof(/obj/item/modular_computer/tablet/phone/preset))
		if(!initial(phone_type.reskin_name))
			continue
		if(phone_skins[initial(phone_type.reskin_name)])
			continue
		var/list/combination = list(
			initial(phone_type.finish_color),
		)
		phone_skins[initial(phone_type.reskin_name)] = combination
	return TRUE

/obj/machinery/pdapainter/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/modular_computer/tablet/pda) || istype(attacking_item, /obj/item/modular_computer/tablet/phone))
		inserted_pda = attacking_item
		inserted_pda.forceMove(src)
		update_icon(UPDATE_OVERLAYS)
		return TRUE
	return ..()

/obj/machinery/pdapainter/interact(mob/user, special_state)
	. = ..()
	if(!inserted_pda)
		balloon_alert(user, "no pda found!")
		return

	var/list/choices = list(PDA_EJECT)
	if(istype(inserted_pda, /obj/item/modular_computer/tablet/pda))
		for(var/skin_name in pda_skins)
			choices += skin_name
		var/choice = tgui_input_list(user, "Choose what skin to apply", "PDA Skin", choices, PDA_EJECT)
		if(!in_range(src, user))
			to_chat(src, span_warning("You are too far away!"))
			return
		if(choice == PDA_EJECT)
			balloon_alert(user, "ejected pda")
			ejectpda(user)
			return
		if(!pda_skins[choice])
			return

		var/list/skin_choice = pda_skins[choice]
		inserted_pda.icon = skin_choice[PDA_ICON]
		inserted_pda.icon_state = skin_choice[PDA_ICON_STATE]
		inserted_pda.icon_state_powered = skin_choice[PDA_ICON_STATE_POWERED]
		inserted_pda.icon_state_unpowered = skin_choice[PDA_ICON_STATE_UNPOWERED]
		if(skin_choice[PDA_GREYSCALE_COLORS] && skin_choice[PDA_GREYSCALE_CONFIG])
			inserted_pda.set_greyscale(
				skin_choice[PDA_GREYSCALE_COLORS],
				skin_choice[PDA_GREYSCALE_CONFIG]
			)
		balloon_alert(user, "skin applied")
		ejectpda(user)

	else if(istype(inserted_pda, /obj/item/modular_computer/tablet/phone))
		for(var/skin_name in phone_skins)
			choices += skin_name
		var/choice = tgui_input_list(user, "Choose what skin to apply", "Phone Skin", choices, PDA_EJECT)
		if(!in_range(src, user))
			to_chat(src, span_warning("You are too far away!"))
			return
		if(choice == PDA_EJECT)
			balloon_alert(user, "ejected phone")
			ejectpda(user)
			return
		if(!phone_skins[choice])
			return

		var/list/skin_choice = phone_skins[choice]
		inserted_pda.finish_color = skin_choice[PHONE_FINISH_COLOR]
		inserted_pda.update_appearance(UPDATE_ICON)
		balloon_alert(user, "skin applied")
		ejectpda(user)
	else
		balloon_alert(user, "invalid pda")
		ejectpda(user)

/obj/machinery/pdapainter/proc/ejectpda(mob/user)
	if(!inserted_pda)
		return
	if(!user || !user.put_in_hands(inserted_pda))
		inserted_pda.forceMove(drop_location())
	inserted_pda = null
	update_icon(UPDATE_OVERLAYS)

#undef PDA_EJECT
#undef PDA_GREYSCALE_CONFIG
#undef PDA_GREYSCALE_COLORS
#undef PDA_ICON
#undef PDA_ICON_STATE
#undef PDA_ICON_STATE_UNPOWERED
#undef PDA_ICON_STATE_POWERED
#undef PHONE_FINISH_COLOR
