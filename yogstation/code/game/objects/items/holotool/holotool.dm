/obj/item/holotool
	name = "basic holotool"
	desc = "A device capable of holographically projecting various tools. Fit with upgrade cards to access more tools."
	icon = 'yogstation/icons/obj/holotool.dmi'
	icon_state = "holotool"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/pshoom.ogg'
	lefthand_file = 'yogstation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/righthand.dmi'
	var/maximum_toolage = 5
	var/current_toolage = 0
	actions_types = list(/datum/action/item_action/change_tool, /datum/action/item_action/change_ht_color)
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/datum/holotool_mode/current_tool
	var/obj/item/multitool/internal_multitool // A kludge caused by the statefulness of multitools,
	// to be retained until we have the hubris to abstract all multitool functionality into some /datum/component, and break modularity in a hundred ways
	var/list/available_modes
	var/list/mode_names
	var/list/radial_modes
	var/current_color = "#a2adb9" //greyish

/obj/item/holotool/advanced
	name = "advanced holotool"
	desc = "An upgraded holotool with an increased capacity for modules."
	maximum_toolage = 10

/obj/item/holotool/elite
	name = "elite holotool"
	desc = "An upgraded holotool that uses bluespace technology to hold more modules."
	maximum_toolage = 15
	
/obj/item/holotool/rd
	name = "experimental holotool"
	desc = "A highly experimental holographic tool projector."
	maximum_toolage = 20
	current_color = "#48D1CC" //real deal gets a cooler color

/obj/item/holotool/Initialize()
	. = ..()
	internal_multitool = new /obj/item/multitool(src)
	new /obj/item/holotool_module/off(src)

/obj/item/holotool/rd/Initialize()
	. = ..()
	new /obj/item/holotool_module/screwdriver/rd(src)
	new /obj/item/holotool_module/crowbar/rd(src)
	new /obj/item/holotool_module/multitool/rd(src)
	new /obj/item/holotool_module/wrench/rd(src)
	new /obj/item/holotool_module/snips/rd(src)
	new /obj/item/holotool_module/welder/rd(src)
	current_toolage = 12 //I can count :D

/obj/item/holotool/attackby(obj/item/I, mob/U)
	if(istype(I, /obj/item/holotool_module))
		var/obj/item/holotool_module/card = I
		if(current_toolage + card.toolage_use > maximum_toolage)
			to_chat(U, span_warning("The " + src.name + " can't hold any more module cards!"))
			return
		card.forceMove(src)
		current_toolage += card.toolage_use
	..()

/obj/item/holotool/screwdriver_act(mob/user, obj/item/tool)
	if(!istype(current_tool, /datum/holotool_mode/off))
		to_chat(user, span_notice("The holotool must be off to remove modules!"))
		return
	for(var/obj/item/holotool_module/module in contents)
		if(istype(module, /obj/item/holotool_module/off))
			continue
		module.forceMove(get_turf(src))
		current_toolage -= module.toolage_use
	..()


/obj/item/holotool/Destroy()
	. = ..()
	qdel(internal_multitool)

/obj/item/holotool/examine(mob/user)
	. = ..()
	. += span_notice("It is currently set to [current_tool ? current_tool.name : "'off'"] mode.")
	. += span_notice("It is currently at [current_toolage] out of [maximum_toolage] capacity for tool cards.")

/obj/item/holotool/attack(mob/living/M, mob/living/user)
	if((tool_behaviour == TOOL_SCREWDRIVER) && !(user.a_intent == INTENT_HARM) && attempt_initiate_surgery(src, M, user))
		return

	if(tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
		if(affecting?.status == BODYPART_ROBOTIC)
			if(affecting.brute_dam <= 0)
				to_chat(user, span_warning("[affecting] is already in good condition!"))
				return FALSE
			if(INTERACTING_WITH(user, H))
				return FALSE
			user.changeNext_move(CLICK_CD_MELEE)
			user.visible_message(span_notice("[user] starts to fix some of the dents on [M]'s [affecting.name]."), span_notice("You start fixing some of the dents on [M == user ? "your" : "[M]'s"] [affecting.name]."))
			heal_robo_limb(src, H, user, 15, 0, 0, 50)
			user.visible_message(span_notice("[user] fixes some of the dents on [M]'s [affecting.name]."), span_notice("You fix some of the dents on [M == user ? "your" : "[M]'s"] [affecting.name]."))
			return TRUE
	. = ..()

/obj/item/holotool/use(used)
	return TRUE //it just always works, capiche!?

/obj/item/holotool/tool_use_check(mob/living/user, amount)
	return TRUE	//always has enough "fuel"

/obj/item/holotool/ui_action_click(mob/user, datum/action/action)
	if(istype(action, /datum/action/item_action/change_tool))
		update_listing()
		var/datum/holotool_mode/chosen = input("Choose tool settings", "Tool", null, null) as null|anything in available_modes
		switch_tool(user, chosen)
	else
		var/C = input(user, "Select Color", "Select color", "#48D1CC") as null|color
		if(!C || QDELETED(src))
			return
		current_color = C
	update_icon()
	action.build_all_button_icons()
	user.regenerate_icons()

/obj/item/holotool/proc/switch_tool(mob/user, datum/holotool_mode/mode)
	if(!mode || !istype(mode))
		return
	if(current_tool)
		current_tool.on_unset(src)
	current_tool = mode
	current_tool.on_set(src)
	playsound(loc, 'yogstation/sound/items/holotool.ogg', get_clamped_volume(), 1, -1)
	update_icon()
	user.regenerate_icons()


/obj/item/holotool/proc/update_listing()
	LAZYCLEARLIST(available_modes)
	LAZYCLEARLIST(radial_modes)
	LAZYCLEARLIST(mode_names)
	for(var/obj/item/holotool_module/A in contents)
		var/datum/holotool_mode/M = A.mode
		if(M.can_be_used(src))
			LAZYADD(available_modes, M)
			LAZYSET(mode_names, M.name, M)
			var/image/holotool_img = image(icon = icon, icon_state = icon_state)
			var/image/tool_img = image(icon = icon, icon_state = M.name)
			tool_img.color = current_color
			holotool_img.overlays += tool_img
			LAZYSET(radial_modes, M.name, holotool_img)
		else
			qdel(M)

/obj/item/holotool/update_icon()
	cut_overlays()
	if(current_tool)
		var/mutable_appearance/holo_item = mutable_appearance(icon, current_tool.name)
		holo_item.color = current_color
		item_state = current_tool.name
		add_overlay(holo_item)
		if(current_tool.name == "off")
			set_light(0)
		else
			set_light(3, null, current_color)
	else
		item_state = "holotool"
		icon_state = "holotool"
		set_light(0)

	for(var/datum/action/A in actions)
		A.build_all_button_icons()

/obj/item/holotool/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/holotool/attack_self(mob/user)
	update_listing()
	var/chosen = show_radial_menu(user, src, radial_modes, custom_check = CALLBACK(src, PROC_REF(check_menu),user))
	if(!check_menu(user))
		return
	if(chosen)
		var/new_tool = LAZYACCESS(mode_names, chosen)
		if(new_tool)
			switch_tool(user, new_tool)

/obj/item/holotool/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, span_danger("ZZT- ILLEGAL BLUEPRINT UNLOCKED- CONTACT !#$@^%$# NANOTRASEN SUPPORT-@*%$^%!"))
	do_sparks(5, 0, src)
	obj_flags |= EMAGGED


// Spawn in RD closet
/obj/structure/closet/secure_closet/RD/PopulateContents()
	. = ..()
	new /obj/item/holotool/rd(src)
