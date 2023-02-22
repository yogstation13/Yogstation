/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox0"
	desc = "A display case for prized possessions."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 30, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 70, ACID = 100)
	max_integrity = 200
	integrity_failure = 0.25
	var/obj/item/showpiece = null
	var/obj/item/showpiece_type = null //This allows for showpieces that can only hold items if they're the same istype as this.
	var/alert = TRUE
	var/open = FALSE
	var/openable = TRUE
	var/obj/item/electronics/airlock/electronics
	var/start_showpiece_type = null //add type for items on display
	var/list/start_showpieces = list() //Takes sublists in the form of list("type" = /obj/item/bikehorn, "trophy_message" = "henk")
	var/trophy_message = ""
	var/glass_fix = TRUE

/obj/structure/displaycase/Initialize()
	. = ..()
	if(start_showpieces.len && !start_showpiece_type)
		var/list/showpiece_entry = pick(start_showpieces)
		if (showpiece_entry && showpiece_entry["type"])
			start_showpiece_type = showpiece_entry["type"]
			if (showpiece_entry["trophy_message"])
				trophy_message = showpiece_entry["trophy_message"]
	if(start_showpiece_type)
		showpiece = new start_showpiece_type (src)
	update_icon()

/obj/structure/displaycase/Destroy()
	if(electronics)
		QDEL_NULL(electronics)
	if(showpiece)
		QDEL_NULL(showpiece)
	return ..()

/obj/structure/displaycase/examine(mob/user)
	. = ..()
	if(alert)
		. += span_notice("Hooked up with an anti-theft system.")
	if(showpiece)
		. += span_notice("There's [showpiece] inside.")
	if(trophy_message)
		. += "The plaque reads:\n [trophy_message]"


/obj/structure/displaycase/proc/dump()
	if (showpiece)
		showpiece.forceMove(loc)
		showpiece = null

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/displaycase/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		dump()
		if(!disassembled)
			new /obj/item/shard( src.loc )
			trigger_alarm()
	qdel(src)

/obj/structure/displaycase/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		density = FALSE
		broken = 1
		new /obj/item/shard( src.loc )
		playsound(src, "shatter", 70, TRUE)
		update_icon()
		trigger_alarm()

/obj/structure/displaycase/proc/trigger_alarm()
	//Activate Anti-theft
	if(alert)
		var/area/alarmed = get_area(src)
		alarmed.burglaralert(src)
		playsound(src, 'sound/effects/alert.ogg', 50, TRUE)

/obj/structure/displaycase/update_icon()
	var/icon/I
	if(open)
		I = icon('icons/obj/stationobjs.dmi',"glassbox_open")
	else
		I = icon('icons/obj/stationobjs.dmi',"glassbox0")
	if(broken)
		I = icon('icons/obj/stationobjs.dmi',"glassboxb0")
	if(showpiece)
		var/icon/S = getFlatIcon(showpiece)
		S.Scale(17,17)
		I.Blend(S,ICON_UNDERLAY,8,8)
	src.icon = I
	return

/obj/structure/displaycase/attackby(obj/item/W, mob/user, params)
	if(W.GetID() && !broken && openable)
		if(allowed(user))
			to_chat(user,  span_notice("You [open ? "close":"open"] [src]."))
			toggle_lock(user)
		else
			to_chat(user,  span_alert("Access denied."))
	else if(W.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP && !broken)
		if(obj_integrity < max_integrity)
			if(!W.tool_start_check(user, amount=5))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(W.use_tool(src, user, 40, amount=5, volume=50))
				obj_integrity = max_integrity
				update_icon()
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return
	else if(!alert && W.tool_behaviour == TOOL_CROWBAR && openable) //Only applies to the lab cage and player made display cases
		if(broken)
			if(showpiece)
				to_chat(user, span_warning("Remove the displayed object first!"))
			else
				to_chat(user, span_notice("You remove the destroyed case."))
				qdel(src)
		else
			to_chat(user, span_notice("You start to [open ? "close":"open"] [src]..."))
			if(W.use_tool(src, user, 20))
				to_chat(user,  span_notice("You [open ? "close":"open"] [src]."))
				toggle_lock(user)
	else if(open && !showpiece)
		if(showpiece_type && !istype(W, showpiece_type))
			to_chat(user, span_notice("This doesn't belong in this kind of display."))
			return TRUE
		if(user.transferItemToLoc(W, src))
			showpiece = W
			to_chat(user, span_notice("You put [W] on display."))
			update_icon()
	else if(glass_fix && broken && istype(W, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = W
		if(G.get_amount() < 2)
			to_chat(user, span_warning("You need two glass sheets to fix the case!"))
			return
		to_chat(user, span_notice("You start fixing [src]..."))
		if(do_after(user, 2 SECONDS, src))
			G.use(2)
			broken = 0
			obj_integrity = max_integrity
			update_icon()
	else
		return ..()

/obj/structure/displaycase/proc/toggle_lock(mob/user)
	open = !open
	update_icon()

/obj/structure/displaycase/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if (showpiece && (broken || open))
		to_chat(user, span_notice("You deactivate the hover field built into the case."))
		log_combat(user, src, "deactivates the hover field of")
		dump()
		src.add_fingerprint(user)
		update_icon()
		return
	else
	    //prevents remote "kicks" with TK
		if (!Adjacent(user))
			return
		if (user.a_intent == INTENT_HELP)
			user.examinate(src)
			return
		user.visible_message(span_danger("[user] kicks the display case."), null, null, COMBAT_MESSAGE_RANGE)
		log_combat(user, src, "kicks")
		user.do_attack_animation(src, ATTACK_EFFECT_KICK)
		take_damage(2)

/obj/structure/displaycase_chassis
	anchored = TRUE
	density = FALSE
	name = "display case chassis"
	desc = "The wooden base of a display case."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/electronics/airlock/electronics


/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH) //The player can only deconstruct the wooden frame
		to_chat(user, span_notice("You start disassembling [src]..."))
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 30))
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			new /obj/item/stack/sheet/mineral/wood(get_turf(src), 5)
			qdel(src)

	else if(istype(I, /obj/item/electronics/airlock))
		to_chat(user, span_notice("You start installing the electronics into [src]..."))
		I.play_tool_sound(src)
		if(do_after(user, 3 SECONDS, src) && user.transferItemToLoc(I,src))
			electronics = I
			to_chat(user, span_notice("You install the airlock electronics."))
	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 10)
			to_chat(user, span_warning("You need ten glass sheets to do this!"))
			return
		to_chat(user, span_notice("You start adding [G] to [src]..."))
		if(do_after(user, 2 SECONDS, src))
			G.use(10)
			var/obj/structure/displaycase/noalert/display = new(src.loc)
			if(electronics)
				electronics.forceMove(display)
				display.electronics = electronics
				if(electronics.one_access)
					display.req_one_access = electronics.accesses
				else
					display.req_access = electronics.accesses
			qdel(src)
	else
		return ..()

//The lab cage and captain's display case do not spawn with electronics, which is why req_access is needed.
/obj/structure/displaycase/captain
	start_showpiece_type = /obj/item/gun/energy/laser/captain
	req_access = list(ACCESS_CENT_SPECOPS) //this was intentional, presumably to make it slightly harder for caps to grab their gun roundstart

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(ACCESS_RD)

/obj/structure/displaycase/cmo
	start_showpiece_type = /obj/item/toy/rod_of_asclepius
	req_access = list(ACCESS_CMO)

/obj/structure/displaycase/noalert
	alert = FALSE

/obj/structure/displaycase/trophy
	name = "trophy display case"
	desc = "Store your trophies of accomplishment in here, and they will stay forever."
	var/placer_key = ""
	var/added_roundstart = TRUE
	var/is_locked = TRUE
	integrity_failure = 0
	openable = FALSE

/obj/structure/displaycase/trophy/Initialize()
	. = ..()
	GLOB.trophy_cases += src

/obj/structure/displaycase/trophy/Destroy()
	GLOB.trophy_cases -= src
	return ..()

/obj/structure/displaycase/trophy/attackby(obj/item/W, mob/user, params)

	if(!user.Adjacent(src)) //no TK museology
		return
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(user.is_holding_item_of_type(/obj/item/key/displaycase))
		if(added_roundstart)
			is_locked = !is_locked
			to_chat(user, span_notice("You [!is_locked ? "un" : ""]lock the case."))
		else
			to_chat(user, span_warning("The lock is stuck shut!"))
		return

	if(is_locked)
		to_chat(user, span_warning("The case is shut tight with an old-fashioned physical lock. Maybe you should ask the curator for the key?"))
		return

	if(!added_roundstart)
		to_chat(user, span_warning("You've already put something new in this case!"))
		return

	if(is_type_in_typecache(W, GLOB.blacklisted_cargo_types))
		to_chat(user, span_warning("The case rejects the [W]!"))
		return

	for(var/a in W.GetAllContents())
		if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types))
			to_chat(user, span_warning("The case rejects the [W]!"))
			return

	if(user.transferItemToLoc(W, src))

		if(showpiece)
			to_chat(user, span_notice("You press a button, and [showpiece] descends into the floor of the case."))
			QDEL_NULL(showpiece)

		to_chat(user, span_notice("You insert [W] into the case."))
		showpiece = W
		added_roundstart = FALSE
		update_icon()

		placer_key = user.ckey

		trophy_message = W.desc //default value

		var/chosen_plaque = stripped_input(user, "What would you like the plaque to say? Default value is item's description.", "Trophy Plaque")
		if(chosen_plaque)
			if(user.Adjacent(src))
				trophy_message = chosen_plaque
				to_chat(user, span_notice("You set the plaque's text."))
			else
				to_chat(user, span_warning("You are too far to set the plaque's text!"))

		SSpersistence.SaveTrophy(src)
		return TRUE

	else
		to_chat(user, span_warning("\The [W] is stuck to your hand, you can't put it in the [src.name]!"))

	return

/obj/structure/displaycase/trophy/dump()
	if (showpiece)
		if(added_roundstart)
			visible_message(span_danger("The [showpiece] crumbles to dust!"))
			new /obj/effect/decal/cleanable/ash(loc)
			QDEL_NULL(showpiece)
		else
			..()

/obj/item/key/displaycase
	name = "display case key"
	desc = "The key to the curator's display cases."

/obj/item/showpiece_dummy
	name = "Cheap replica"

/obj/item/showpiece_dummy/Initialize(mapload, path)
	. = ..()
	var/obj/item/I = path
	name = initial(I.name)
	icon = initial(I.icon)
	icon_state = initial(I.icon_state)
