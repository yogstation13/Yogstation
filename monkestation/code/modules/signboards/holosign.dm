/obj/structure/signboard/holosign
	name = "holographic sign"
	desc = "A holographic signboard, projecting text above it."
	icon_state = "holographic_sign"
	base_icon_state = "holographic_sign"
	edit_by_hand = TRUE
	show_while_unanchored = TRUE
	light_system = OVERLAY_LIGHT
	light_outer_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_power = 0.3
	light_color = COLOR_CARP_TEAL
	light_on = FALSE
	/// If set, only IDs with this name can (un)lock the sign.
	var/registered_owner
	/// The current color of the sign.
	/// The sign will be greyscale if this is set.
	var/current_color

/obj/structure/signboard/holosign/Initialize(mapload)
	. = ..()
	text_holder.appearance_flags &= ~RESET_COLOR // allow the text holoder to inherit our color
	if(current_color)
		INVOKE_ASYNC(src, PROC_REF(set_color), current_color)

/obj/structure/signboard/holosign/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	var/locked = is_locked(user)
	if(istype(held_item, /obj/item/card/emag))
		context[SCREENTIP_CONTEXT_LMB] = "Short Out Locking Mechanisms"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(!locked && istype(held_item?.GetID(), /obj/item/card/id))
		context[SCREENTIP_CONTEXT_LMB] = registered_owner ? "Remove ID Lock" : "Lock To ID"
		. = CONTEXTUAL_SCREENTIP_SET
	if(!locked)
		context[SCREENTIP_CONTEXT_RMB] = "Set Sign Color"
		. = CONTEXTUAL_SCREENTIP_SET

/obj/structure/signboard/holosign/update_icon_state()
	base_icon_state = current_color ? "[initial(base_icon_state)]_greyscale" : initial(base_icon_state)
	. = ..()
	if(obj_flags & EMAGGED)
		icon_state += "_emag"

/obj/structure/signboard/holosign/update_desc(updates)
	. = ..()
	desc = initial(desc)
	if(obj_flags & EMAGGED)
		desc += span_warning("<br>Its locking mechanisms appear to be shorted out!")
	else if(registered_owner)
		desc += span_info("<br>It is locked to the ID of [span_name(registered_owner)].")

/obj/structure/signboard/holosign/update_overlays()
	. = ..()
	if(sign_text)
		. += emissive_appearance(icon, "holographic_sign_e", src)

/obj/structure/signboard/holosign/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, color) || var_name == NAMEOF(src, current_color))
		INVOKE_ASYNC(src, PROC_REF(set_color), var_value)
		datum_flags |= DF_VAR_EDITED
		return TRUE
	return ..()

/obj/structure/signboard/holosign/attackby(obj/item/item, mob/user, params)
	var/obj/item/card/id/id = item?.GetID()
	if(!istype(id) || !can_interact(user) || !user.can_perform_action(src, NEED_DEXTERITY))
		return ..()
	var/trimmed_id_name = trimtext(id.registered_name)
	if(!trimmed_id_name)
		balloon_alert(user, "no name on id!")
		return
	if(obj_flags & EMAGGED)
		balloon_alert(user, "lock shorted out!")
		return
	if(registered_owner)
		if(!check_locked(user))
			registered_owner = null
			balloon_alert(user, "id lock removed")
			investigate_log("([key_name(user)]) removed id lock", INVESTIGATE_SIGNBOARD)
	else
		registered_owner = trimmed_id_name
		balloon_alert(user, "locked to id")
		investigate_log("([key_name(user)]) added id lock for \"[registered_owner]\"", INVESTIGATE_SIGNBOARD)
	update_appearance()

/obj/structure/signboard/holosign/is_locked(mob/living/user)
	. = ..()
	if(.)
		return
	if(registered_owner && isliving(user))
		var/obj/item/card/id/id = user.get_idcard()
		if(!istype(id) || QDELING(id))
			return TRUE
		return !cmptext(trimtext(id.registered_name), registered_owner)

/obj/structure/signboard/holosign/set_text(new_text, force)
	. = ..()
	set_light_on(!!sign_text)

/obj/structure/signboard/holosign/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(try_set_color(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/signboard/holosign/proc/try_set_color(mob/user)
	. = TRUE
	if(!can_interact(user) || !user.can_perform_action(src, NEED_DEXTERITY))
		return FALSE
	if(check_locked(user))
		return
	var/new_color = sanitize_color(tgui_color_picker(user, "Set Sign Color", full_capitalize(name), current_color))
	if(new_color && is_color_dark_with_saturation(new_color, 25))
		balloon_alert(user, "color too dark!")
		return
	if(check_locked(user))
		return
	INVOKE_ASYNC(src, PROC_REF(set_color), new_color)
	if(new_color)
		balloon_alert(user, "set color to [new_color]")
		investigate_log("([key_name(user)]) set the color to [new_color || "(none)"]", INVESTIGATE_SIGNBOARD)
	else
		balloon_alert(user, "unset color")
		investigate_log("([key_name(user)]) cleared the color", INVESTIGATE_SIGNBOARD)

/obj/structure/signboard/holosign/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	playsound(src, SFX_SPARKS, vol = 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	balloon_alert(user, "lock broken")
	investigate_log("was emagged by [key_name(user)] (previous owner: [registered_owner || "(none)"])", INVESTIGATE_SIGNBOARD)
	registered_owner = null
	obj_flags |= EMAGGED
	update_appearance()

/obj/structure/signboard/holosign/proc/sanitize_color(color)
	. = sanitize_hexcolor(color)
	if(!. || . == "#000000")
		return null

/obj/structure/signboard/holosign/proc/set_color(new_color)
	new_color = sanitize_color(new_color)
	if(!new_color)
		current_color = null
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	else
		current_color = new_color
		add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	set_light_color(current_color || src::light_color)
	update_appearance()
