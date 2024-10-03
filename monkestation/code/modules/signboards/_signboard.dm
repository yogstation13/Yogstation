#define SIGNBOARD_WIDTH		(world.icon_size * 3.5)
#define SIGNBOARD_HEIGHT	(world.icon_size * 2.5)

/obj/structure/signboard
	name = "sign"
	desc = "A foldable sign."
	icon = 'monkestation/icons/obj/structures/signboards.dmi'
	icon_state = "sign"
	base_icon_state = "sign"
	density = TRUE
	anchored = TRUE
	interaction_flags_atom  = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_REQUIRES_DEXTERITY
	/// The current text written on the sign.
	var/sign_text
	/// The maximum length of text that can be input onto the sign.
	var/max_length = MAX_PLAQUE_LEN
	/// If true, the text cannot be changed by players.
	var/locked = FALSE
	/// If text should be shown while unanchored.
	var/show_while_unanchored = FALSE
	/// If TRUE, the sign can be edited without a pen.
	var/edit_by_hand = FALSE
	/// Holder for signboard maptext
	var/obj/effect/abstract/signboard_holder/text_holder
	/// Lazy assoc list of clients to images
	VAR_PROTECTED/list/client_maptext_images
	/// If a mass client add/removal is currently being done.
	VAR_PRIVATE/doing_update = FALSE

/obj/structure/signboard/Initialize(mapload)
	. = ..()
	text_holder = new(src)
	vis_contents += text_holder
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(on_mob_login))
	if(sign_text)
		set_text(sign_text, force = TRUE)
		investigate_log("had its text set on load to \"[sign_text]\"", INVESTIGATE_SIGNBOARD)
	update_appearance()
	register_context()

/obj/structure/signboard/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN)
	remove_from_all_clients_unsafe()
	vis_contents -= text_holder
	QDEL_NULL(text_holder)
	return ..()

/obj/structure/signboard/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!is_locked(user))
		if(held_item?.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unsecure" : "Secure"
			return CONTEXTUAL_SCREENTIP_SET
		if((edit_by_hand || istype(held_item, /obj/item/pen)) && (anchored || show_while_unanchored))
			context[SCREENTIP_CONTEXT_LMB] = "Set Displayed Text"
			if(sign_text)
				context[SCREENTIP_CONTEXT_ALT_RMB] = "Clear Sign"
			return CONTEXTUAL_SCREENTIP_SET

/obj/structure/signboard/examine(mob/user)
	. = ..()
	if(!edit_by_hand)
		. += span_info("You need a <b>pen</b> to write on the sign!")
	if(anchored)
		. += span_info("It is secured to the floor, you could use a <i>wrench</i> to unsecure and move it.")
	else
		. += span_info("It is unsecured, you could use a <i>wrench</i> to secure it in place.")
	if(sign_text)
		. += span_boldnotice("\nIt currently displays the following:")
		. += span_info(html_encode(sign_text))
	else
		. += span_info("\nIt is blank!")

/obj/structure/signboard/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][sign_text ? "" : "_blank"]"

/obj/structure/signboard/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, sign_text))
		if(!set_text(var_value, force = TRUE))
			return FALSE
		datum_flags |= DF_VAR_EDITED
		return TRUE
	return ..()

/obj/structure/signboard/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/pen))
		return ..()
	try_set_text(user)

/obj/structure/signboard/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!edit_by_hand && !user.is_holding_item_of_type(/obj/item/pen))
		balloon_alert(user, "need a pen!")
		return TRUE
	if(try_set_text(user))
		return TRUE

/obj/structure/signboard/proc/try_set_text(mob/living/user)
	. = FALSE
	if(!anchored && !show_while_unanchored)
		return FALSE
	if(check_locked(user))
		return FALSE
	var/new_text = tgui_input_text(
		user,
		message = "What would you like to set this sign's text to?",
		title = full_capitalize(name),
		default = sign_text,
		max_length = max_length,
		multiline = TRUE,
		encode = FALSE
	)
	if(QDELETED(src) || !new_text || check_locked(user))
		return FALSE
	var/list/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered(new_text)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		return FALSE
	var/list/soft_filter_result = CAN_BYPASS_FILTER(user) ? null : is_soft_ic_filtered(new_text)
	if(soft_filter_result)
		if(tgui_alert(user, "Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" when writing to the sign at [ADMIN_VERBOSEJMP(src)], they may be using a disallowed term. Sign text: \"[html_encode(new_text)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" when writing to the sign at [loc_name(src)], they may be using a disallowed term. Sign text: \"[new_text]\"")
	if(set_text(new_text))
		balloon_alert(user, "set text")
		investigate_log("([key_name(user)]) set text to \"[sign_text || "(none)"]\"", INVESTIGATE_SIGNBOARD)
		return TRUE

/obj/structure/signboard/alt_click_secondary(mob/user)
	. = ..()
	if(!sign_text || !can_interact(user) || !user.can_perform_action(src, NEED_DEXTERITY))
		return
	if(!edit_by_hand && !user.is_holding_item_of_type(/obj/item/pen))
		balloon_alert(user, "need a pen!")
		return
	if(check_locked(user))
		return
	if(set_text(null))
		balloon_alert(user, "cleared text")
		investigate_log("([key_name(user)]) cleared the text", INVESTIGATE_SIGNBOARD)

/obj/structure/signboard/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!anchored || !check_locked(user))
		default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/signboard/set_anchored(anchorvalue)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(add_to_all_clients))

/obj/structure/signboard/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!isturf(old_loc) || !isturf(loc))
		INVOKE_ASYNC(src, PROC_REF(add_to_all_clients))

/obj/structure/signboard/proc/is_locked(mob/user)
	. = locked
	if(isAdminGhostAI(user))
		return FALSE

/obj/structure/signboard/proc/check_locked(mob/user, silent = FALSE)
	. = is_locked(user)
	if(. && !silent)
		balloon_alert(user, "locked!")

/obj/structure/signboard/proc/should_display_text()
	if(QDELETED(src) || !isturf(loc) || !sign_text)
		return FALSE
	if(!anchored && !show_while_unanchored)
		return FALSE
	return TRUE

/obj/structure/signboard/proc/on_mob_login(datum/source, mob/user)
	SIGNAL_HANDLER
	var/client/client = user?.client
	ASYNC
		UNTIL_WHILE_EXISTS(src, !doing_update)
		doing_update = TRUE
		add_client(client)
		doing_update = FALSE

/obj/structure/signboard/proc/add_client(client/user)
	if(QDELETED(user) || !should_display_text())
		return
	if(LAZYACCESS(client_maptext_images, user))
		remove_client(user)
	var/image/client_image = create_image_for_client(user)
	if(!client_image || QDELETED(user))
		return
	LAZYSET(client_maptext_images, user, client_image)
	LAZYADD(update_on_z, client_image)
	user.images |= client_image
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(remove_client))

/obj/structure/signboard/proc/remove_client(client/user)
	SIGNAL_HANDLER
	if(isnull(user))
		return
	UnregisterSignal(user, COMSIG_QDELETING)
	var/image/client_image = LAZYACCESS(client_maptext_images, user)
	if(!client_image)
		return
	user.images -= client_image
	LAZYREMOVE(client_maptext_images, user)
	LAZYREMOVE(update_on_z, client_image)

/obj/structure/signboard/proc/add_to_all_clients()
	UNTIL_WHILE_EXISTS(src, !doing_update)
	doing_update = TRUE
	add_to_all_clients_unsafe()
	doing_update = FALSE

/obj/structure/signboard/proc/add_to_all_clients_unsafe()
	PRIVATE_PROC(TRUE)
	if(QDELETED(src))
		return
	remove_from_all_clients_unsafe()
	if(!should_display_text())
		return
	var/list/shown_first = list()
	var/client/usr_client = usr?.client
	add_client(usr_client)
	for(var/mob/mob in viewers(world.view, src))
		if(QDELING(mob) || QDELETED(mob.client) || mob == usr)
			continue
		add_client(mob.client)
		shown_first[mob.client] = TRUE
	for(var/client/client as anything in GLOB.clients)
		if(QDELETED(client) || shown_first[client] || client == usr_client)
			continue
		add_client(client)

/obj/structure/signboard/proc/remove_from_all_clients()
	UNTIL_WHILE_EXISTS(src, !doing_update)
	doing_update = TRUE
	remove_from_all_clients_unsafe()
	doing_update = FALSE

/obj/structure/signboard/proc/remove_from_all_clients_unsafe()
	PRIVATE_PROC(TRUE)
	for(var/client/client as anything in client_maptext_images)
		remove_client(client)
	LAZYNULL(client_maptext_images)

/obj/structure/signboard/proc/create_image_for_client(client/user) as /image
	RETURN_TYPE(/image)
	if(QDELETED(user) || !sign_text)
		return
	var/bwidth = src.bound_width || world.icon_size
	var/bheight = src.bound_height || world.icon_size
	var/text_html = MAPTEXT_GRAND9K("<span style='text-align: center'>[html_encode(sign_text)]</span>")
	var/mheight
	WXH_TO_HEIGHT(user.MeasureText(text_html, null, SIGNBOARD_WIDTH), mheight)
	var/image/maptext_holder = image(loc = text_holder)
	SET_PLANE_EXPLICIT(maptext_holder, GAME_PLANE_UPPER_FOV_HIDDEN, src)
	maptext_holder.layer = ABOVE_ALL_MOB_LAYER
	maptext_holder.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	maptext_holder.alpha = 192
	maptext_holder.maptext = text_html
	maptext_holder.maptext_x = (SIGNBOARD_WIDTH - bwidth) * -0.5
	maptext_holder.maptext_y = bheight
	maptext_holder.maptext_width = SIGNBOARD_WIDTH
	maptext_holder.maptext_height = mheight
	return maptext_holder

/obj/structure/signboard/proc/set_text(new_text, force = FALSE)
	. = FALSE
	if(QDELETED(src) || (locked && !force))
		return
	if(!istext(new_text) && !isnull(new_text))
		CRASH("Attempted to set invalid signtext: [new_text]")
	. = TRUE
	new_text = trimtext(copytext_char(new_text, 1, max_length))
	if(length(new_text))
		sign_text = new_text
		INVOKE_ASYNC(src, PROC_REF(add_to_all_clients))
	else
		sign_text = null
		INVOKE_ASYNC(src, PROC_REF(remove_from_all_clients))
	update_appearance()

/obj/effect/abstract/signboard_holder
	name = ""
	icon = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE

/obj/effect/abstract/signboard_holder/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/structure/signboard) || QDELING(loc))
		return INITIALIZE_HINT_QDEL

/obj/effect/abstract/signboard_holder/Destroy(force)
	if(!force && istype(loc, /obj/structure/signboard) && !QDELING(loc))
		stack_trace("Tried to delete a signboard holder that's inside of a non-deleted signboard!")
		return QDEL_HINT_LETMELIVE
	return ..()

/obj/effect/abstract/signboard_holder/forceMove(atom/destination, no_tp = FALSE, harderforce = FALSE)
	if(harderforce)
		return ..()

#undef SIGNBOARD_HEIGHT
#undef SIGNBOARD_WIDTH
