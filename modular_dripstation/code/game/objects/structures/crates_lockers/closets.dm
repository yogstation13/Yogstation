GLOBAL_LIST_INIT(closet_cutting_types, typecacheof(list(
	/obj/item/gun/energy/plasmacutter)))

/obj/structure/closet/secure_closet/tool_interact(obj/item/W, mob/user, proximity)//returns TRUE if attackBy call shouldnt be continued (because tool was used/closet was of wrong type), FALSE if otherwise
	. = TRUE
	if(opened)
		if(user.a_intent == INTENT_HARM)
			return FALSE
		if(istype(W, cutting_tool))
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return

				to_chat(user, span_notice("You begin cutting \the [src] apart..."))
				if(W.use_tool(src, user, 40, volume=50))
					if(!opened)
						return
					user.visible_message(span_notice("[user] slices apart \the [src]."),
									span_notice("You cut \the [src] apart with \the [W]."),
									span_italics("You hear welding."))
					deconstruct(TRUE)
				return
			else // for example cardboard box is cut with wirecutters
				user.visible_message(span_notice("[user] cut apart \the [src]."), \
									span_notice("You cut \the [src] apart with \the [W]."))
				deconstruct(TRUE)
				return
		if(user.transferItemToLoc(W, drop_location())) // so we put in unlit welder too
			return
	else if(is_type_in_typecache(W, GLOB.closet_cutting_types) && user.a_intent == INTENT_HARM)
		to_chat(user, span_notice("You begin cutting off electronic lock \the [src]..."))
		if(W.tool_behaviour == TOOL_WELDER)
			if(!W.tool_start_check(user, amount=0))
				return
			to_chat(user, span_notice("You begin cutting \the [src] lock..."))
			while(obj_integrity > integrity_failure)
				if(W.use_tool(src, user, 40, volume=50))
					if(opened)
						return
					user.visible_message(span_notice("[user] melts the lock of \the [src]."),
							span_notice("You melting the lock of \the [src] with \the [W]."),
							span_italics("You hear welding."))
					obj_integrity -= 40
		if(obj_integrity <= integrity_failure)
			bust_open()
	else if(W.tool_behaviour == TOOL_WELDER && can_weld_shut)
		if(!W.tool_start_check(user, amount=0))
			return

		to_chat(user, span_notice("You begin [welded ? "unwelding":"welding"] \the [src]..."))
		if(W.use_tool(src, user, 40, volume=50))
			if(opened)
				return
			welded = !welded
			after_weld(welded)
			update_airtightness()
			user.visible_message(span_notice("[user] [welded ? "welds shut" : "unwelded"] \the [src]."),
							span_notice("You [welded ? "weld" : "unwelded"] \the [src] with \the [W]."),
							span_italics("You hear welding."))
			update_appearance(UPDATE_ICON)
	else if(W.tool_behaviour == TOOL_WRENCH && anchorable)
		if(isinspace() && !anchored)
			return
		setAnchored(!anchored)
		W.play_tool_sound(src, 75)
		user.visible_message(span_notice("[user] [anchored ? "anchored" : "unanchored"] \the [src] [anchored ? "to" : "from"] the ground."), \
						span_notice("You [anchored ? "anchored" : "unanchored"] \the [src] [anchored ? "to" : "from"] the ground."), \
						span_italics("You hear a ratchet."))
	else if(user.a_intent != INTENT_HARM)
		var/item_is_id = W.GetID()
		if(!item_is_id && !(W.item_flags & NOBLUDGEON))
			return FALSE
		if(item_is_id || !toggle(user))
			togglelock(user)
	else
		return FALSE