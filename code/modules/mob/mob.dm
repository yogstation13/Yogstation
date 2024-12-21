/**
  * Delete a mob
  *
  * Removes mob from the following global lists
  * * GLOB.mob_list
  * * GLOB.dead_mob_list
  * * GLOB.alive_mob_list
  * * GLOB.all_clockwork_mobs
  * * GLOB.mob_directory
  *
  * Unsets the focus var
  *
  * Clears alerts for this mob
  *
  * Resets all the observers perspectives to the tile this mob is on
  *
  * qdels any client colours in place on this mob
  *
  * Ghostizes the client attached to this mob
  *
  * Parent call
  *
  * Returns QDEL_HINT_HARDDEL (don't change this)
  */
/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	remove_from_mob_list()
	remove_from_dead_mob_list()
	remove_from_alive_mob_list()
	remove_from_mob_suicide_list()

	focus = null

	if(length(progressbars))
		stack_trace("[src] destroyed with elements in its progressbars list")
		progressbars = null

	for (var/alert in alerts)
		clear_alert(alert, TRUE)

	if(observers?.len)
		for(var/mob/dead/observe as anything in observers)
			observe.reset_perspective(null)

	qdel(hud_used)
	QDEL_LIST(client_colours)
	ghostize() //False, since we're deleting it currently

	if(mind?.current == src) //Let's just be safe yeah? This will occasionally be cleared, but not always. Can't do it with ghostize without changing behavior
		mind.current = null

	return ..()

/**
  * Intialize a mob
  *
  * Sends global signal COMSIG_GLOB_MOB_CREATED
  *
  * Adds to global lists
  * * GLOB.mob_list
  * * GLOB.mob_directory (by tag)
  * * GLOB.dead_mob_list - if mob is dead
  * * GLOB.alive_mob_list - if the mob is alive
  *
  * Other stuff:
  * * Sets the mob focus to itself
  * * Generates huds
  * * If there are any global alternate apperances apply them to this mob
  * * set a random nutrition level
  * * Intialize the movespeed of the mob
  */
/mob/Initialize(mapload)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_CREATED, src)
	add_to_mob_list()
	if(stat == DEAD)
		remove_from_alive_mob_list()
	else
		add_to_alive_mob_list()
	set_focus(src)
	prepare_huds()
	for(var/v in GLOB.active_alternate_appearances)
		if(!v)
			continue
		var/datum/atom_hud/alternate_appearance/AA = v
		AA.onNewMob(src)
	set_nutrition(rand(NUTRITION_LEVEL_START_MIN, NUTRITION_LEVEL_START_MAX))
	. = ..()
	update_config_movespeed()
	update_movespeed(TRUE)
	become_hearing_sensitive()

/mob/New()
	// This needs to happen IMMEDIATELY. I'm sorry :(
	GenerateTag()
	return ..()

/**
 * Generate the tag for this mob
 *
 * This is simply "mob_"+ a global incrementing counter that goes up for every mob
 */
/mob/GenerateTag()
	. = ..()
	tag = "mob_[next_mob_id++]"

/**
 * set every hud image in the given category active so other people with the given hud can see it.
 * Arguments:
 * * hud_category - the index in our active_hud_list corresponding to an image now being shown.
 * * update_huds - if FALSE we will just put the hud_category into active_hud_list without actually updating the atom_hud datums subscribed to it
 * * exclusive_hud - if given a reference to an atom_hud, will just update that hud instead of all global ones attached to that category.
 * This is because some atom_hud subtypes arent supposed to work via global categories, updating normally would affect all of these which we dont want.
 */
/atom/proc/set_hud_image_active(hud_category, update_huds = TRUE, datum/atom_hud/exclusive_hud)
	if(!istext(hud_category) || !hud_list?[hud_category] || active_hud_list?[hud_category])
		return FALSE

	LAZYSET(active_hud_list, hud_category, hud_list[hud_category])

	if(!update_huds)
		return TRUE

	if(exclusive_hud)
		exclusive_hud.add_single_hud_category_on_atom(src, hud_category)
	else
		for(var/datum/atom_hud/hud_to_update as anything in GLOB.huds_by_category[hud_category])
			hud_to_update.add_single_hud_category_on_atom(src, hud_category)

	return TRUE

///sets every hud image in the given category inactive so no one can see it
/atom/proc/set_hud_image_inactive(hud_category, update_huds = TRUE, datum/atom_hud/exclusive_hud)
	if(!istext(hud_category))
		return FALSE

	if(!update_huds)
		LAZYREMOVE(active_hud_list, hud_category)
		return TRUE

	if(exclusive_hud)
		exclusive_hud.remove_single_hud_category_on_atom(src, hud_category)
	else
		for(var/datum/atom_hud/hud_to_update as anything in GLOB.huds_by_category[hud_category])
			hud_to_update.remove_single_hud_category_on_atom(src, hud_category)

	LAZYREMOVE(active_hud_list, hud_category)

	return TRUE

/**
 * Prepare the huds for this atom
 *
 * Goes through hud_possible list and adds the images to the hud_list variable (if not already cached)
 */
/atom/proc/prepare_huds()
	if(hud_list) // I choose to be lienient about people calling this proc more then once
		return
	hud_list = list()
	for(var/hud in hud_possible)
		var/hint = hud_possible[hud]

		if(hint == HUD_LIST_LIST)
			hud_list[hud] = list()

		else
			var/image/I = image('yogstation/icons/mob/hud.dmi', src, "")
			I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
			hud_list[hud] = I
		set_hud_image_active(hud, update_huds = FALSE) //by default everything is active. but dont add it to huds to keep control.

/**
  * Some kind of debug verb that gives atmosphere environment details
  */
/mob/proc/Cell()
	set category = "Misc.Server Debug"
	set hidden = 1

	if(!loc)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t =	span_notice("Coordinates: [x],[y] \n")
	t +=	span_danger("Temperature: [environment.return_temperature()] \n")
	for(var/id in environment.get_gases())
		if(environment.get_moles(id))
			t+=span_notice("[GLOB.gas_data.names[id]]: [environment.get_moles(id)] \n")

	to_chat(usr, t)

/**
  * Return the desc of this mob for a photo
  */
/mob/proc/get_photo_description(obj/item/camera/camera)
	return "a ... thing?"

/**
  * Show a message to this mob (visual)
  */
/mob/proc/show_message(msg, type, alt_msg, alt_type, avoid_highlighting = FALSE)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)
		return

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type & 1 && eye_blind )//Vision related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type

		if(type & 2 && !can_hear())//Hearing related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type
				if(type & 1 && eye_blind)
					return
	// voice muffling
	if(stat == UNCONSCIOUS)
		if(type & 2) //audio
			to_chat(src, "<I>... You can almost hear something ...</I>")
	else
		to_chat(src, msg, avoid_highlighting = avoid_highlighting)

/**
  * Generate a visible message from this atom
  *
  * Show a message to all player mobs who sees this atom
  *
  * Show a message to the src mob (if the src is a mob)
  *
  * Use for atoms performing visible actions
  *
  * message is output to anyone who can see, e.g. "The [src] does something!"
  *
  * Vars:
  * * self_message (optional) is what the src mob sees e.g. "You do something!"
  * * blind_message (optional) is what blind people will hear e.g. "You hear something!"
  * * vision_distance (optional) define how many tiles away the message can be seen.
  * * ignored_mob (optional) doesn't show any message to a given mob if TRUE.
  */
/atom/proc/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, visible_message_flags = NONE)
	var/turf/T = get_turf(src)
	if(!T)
		return

	if(!islist(ignored_mobs))
		ignored_mobs = list(ignored_mobs)
	var/list/hearers = get_hearers_in_view(vision_distance, src) //caches the hearers and then removes ignored mobs.
	hearers -= ignored_mobs

	if(self_message)
		hearers -= src

	var/raw_msg = message
	if(visible_message_flags & EMOTE_MESSAGE)
		message = "<b>[src]</b> [message]"

	for(var/mob/M in hearers)
		if(!M.client)
			continue

		//This entire if/else chain could be in two lines but isn't for readibilties sake.
		var/msg = message
		var/msg_type = MSG_VISUAL

		if(M.see_invisible < invisibility)//if src is invisible to M
			msg = blind_message
			msg_type = MSG_AUDIBLE
		else if(T != loc && T != src) //if src is inside something and not a turf.
			if(M != loc) // Only give the blind message to hearers that aren't the location
				msg = blind_message
				msg_type = MSG_AUDIBLE
		else if(!HAS_TRAIT(M, TRAIT_HEAR_THROUGH_DARKNESS) && M.lighting_cutoff < LIGHTING_CUTOFF_HIGH && T.is_softly_lit() && !in_range(T,M)) //if it is too dark, unless we're right next to them.
			msg = blind_message
			msg_type = MSG_AUDIBLE
		if(!msg)
			continue

		if(visible_message_flags & EMOTE_MESSAGE && runechat_prefs_check(M, visible_message_flags) && !is_blind(M))
			M.create_chat_message(src, raw_message = raw_msg, runechat_flags = visible_message_flags)

		M.show_message(msg, msg_type, blind_message, MSG_AUDIBLE)




/mob/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, visible_message_flags = NONE)
	. = ..()
	if(self_message)
		show_message(self_message, MSG_VISUAL, blind_message, MSG_AUDIBLE)

/**
  * Show a message to all mobs in earshot of this atom
  *
  * Use for objects performing audible actions
  *
  * vars:
  * * message is the message output to anyone who can hear.
  * * deaf_message (optional) is what deaf people will see.
  * * hearing_distance (optional) is the range, how many tiles away the message can be heard.
  */

/atom/proc/audible_message(message, deaf_message, hearing_distance = DEFAULT_MESSAGE_RANGE, self_message, audible_message_flags = NONE)
	var/list/hearers = get_hearers_in_view(hearing_distance, src)
	if(self_message)
		hearers -= src
	var/raw_msg = message
	if(audible_message_flags & EMOTE_MESSAGE)
		message = "<b>[src]</b> [message]"
	for(var/mob/M in hearers)
		if(audible_message_flags & EMOTE_MESSAGE && runechat_prefs_check(M, audible_message_flags) && M.can_hear())
			M.create_chat_message(src, raw_message = raw_msg, runechat_flags = audible_message_flags)
		M.show_message(message, MSG_AUDIBLE, deaf_message, MSG_VISUAL)

/mob/audible_message(message, deaf_message, hearing_distance = DEFAULT_MESSAGE_RANGE, self_message, audible_message_flags = NONE)
	. = ..()
	if(self_message)
		show_message(self_message, MSG_AUDIBLE, deaf_message, MSG_VISUAL)

///Returns the client runechat visible messages preference according to the message type.
/atom/proc/runechat_prefs_check(mob/target, visible_message_flags = NONE)
	if(!target.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
		return FALSE
	if (!target.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat_non_mobs))
		return FALSE
	if(visible_message_flags & EMOTE_MESSAGE && !target.client.prefs.read_preference(/datum/preference/toggle/see_rc_emotes))
		return FALSE
	return TRUE

/mob/runechat_prefs_check(mob/target, visible_message_flags = NONE)
	if(!target.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
		return FALSE
	if(visible_message_flags & EMOTE_MESSAGE && !target.client.prefs.read_preference(/datum/preference/toggle/see_rc_emotes))
		return FALSE
	return TRUE

///Get the item on the mob in the storage slot identified by the id passed in
/mob/proc/get_item_by_slot(slot_id)
	return null

/// Gets what slot the item on the mob is held in.
/// Returns null if the item isn't in any slots on our mob.
/// Does not check if the passed item is null, which may result in unexpected outcoms.
/mob/proc/get_slot_by_item(obj/item/looking_for)
	if(looking_for in held_items)
		return ITEM_SLOT_HANDS

	return null

///Is the mob restrained
/mob/proc/restrained(ignore_grab)
	return HAS_TRAIT(src, TRAIT_RESTRAINED)

///Is the mob incapacitated
/mob/proc/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE)
	return

/**
  * This proc is called whenever someone clicks an inventory ui slot.
  *
  * Mostly tries to put the item into the slot if possible, or call attack hand
  * on the item in the slot if the users active hand is empty
  */
/mob/proc/attack_ui(slot, params)
	var/obj/item/W = get_active_held_item()

	if(istype(W))
		if(equip_to_slot_if_possible(W, slot,0,0,0))
			return 1

	if(!W)
		// Activate the item
		var/obj/item/I = get_item_by_slot(slot)
		if(istype(I))
			var/list/modifiers = params2list(params)
			I.attack_hand(src, modifiers)

	return 0

/**
  * Try to equip an item to a slot on the mob
  *
  * This is a SAFE proc. Use this instead of equip_to_slot()!
  *
  * set qdel_on_fail to have it delete W if it fails to equip
  *
  * set disable_warning to disable the 'you are unable to equip that' warning.
  *
  * unset redraw_mob to prevent the mob icons from being redrawn at the end.
  */
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, qdel_on_fail = FALSE, disable_warning = FALSE, redraw_mob = TRUE, bypass_equip_delay_self = FALSE, initial = FALSE)
	if(!istype(W))
		return FALSE
	if(!W.mob_can_equip(src, null, slot, disable_warning, bypass_equip_delay_self))
		if(qdel_on_fail)
			qdel(W)
		else
			if(!disable_warning)
				to_chat(src, span_warning("You are unable to equip that!"))
		return FALSE
	equip_to_slot(W, slot, redraw_mob, initial) //This proc should not ever fail.
	return TRUE

/**
  * Actually equips an item to a slot (UNSAFE)
  *
  * This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on
  * whether you can or can't equip need to be done before! Use mob_can_equip() for that task.
  *
  *In most cases you will want to use equip_to_slot_if_possible()
  */
/mob/proc/equip_to_slot(obj/item/W, slot)
	return

/**
  * Equip an item to the slot or delete
  *
  * This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to
  * equip people when the round starts and when events happen and such.
  *
  * Also bypasses equip delay checks, since the mob isn't actually putting it on.
  */
/mob/proc/equip_to_slot_or_del(obj/item/W, slot, initial = FALSE)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, TRUE, initial)

/**
  * Auto equip the passed in item the appropriate slot based on equipment priority
  *
  * puts the item "W" into an appropriate slot in a human's inventory
  *
  * returns 0 if it cannot, 1 if successful
  */
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W))
		return 0
	var/slot_priority = W.slot_equipment_priority

	if(!slot_priority)
		slot_priority = list( \
			ITEM_SLOT_BACK, ITEM_SLOT_ID,\
			ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING,\
			ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_NECK,\
			ITEM_SLOT_FEET, ITEM_SLOT_GLOVES,\
			ITEM_SLOT_EARS, ITEM_SLOT_EYES,\
			ITEM_SLOT_BELT, ITEM_SLOT_SUITSTORE,\
			ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET,\
			ITEM_SLOT_DEX_STORAGE\
		)

	for(var/slot in slot_priority)
		if(equip_to_slot_if_possible(W, slot, 0, 1, 1)) //qdel_on_fail = 0; disable_warning = 1; redraw_mob = 1
			return 1

	return 0
/**
  * Reset the attached clients perspective (viewpoint)
  *
  * reset_perspective() set eye to common default : mob on turf, loc otherwise
  * reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
  */
/mob/proc/reset_perspective(atom/new_eye)
	SHOULD_CALL_PARENT(TRUE)
	if(!client)
		return

	if(new_eye)
		if(ismovable(new_eye))
			//Set the new eye unless it's us
			if(new_eye != src)
				client.perspective = EYE_PERSPECTIVE
				client.set_eye(new_eye)
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE

		else if(isturf(new_eye))
			//Set to the turf unless it's our current turf
			if(new_eye != loc)
				client.perspective = EYE_PERSPECTIVE
				client.set_eye(new_eye)
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE
		else
			return TRUE //no setting eye to stupid things like areas or whatever
	else
		//Reset to common defaults: mob if on turf, otherwise current loc
		if(isturf(loc))
			client.set_eye(client.mob)
			client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.set_eye(loc)
	/// Signal sent after the eye has been successfully updated, with the client existing.
	SEND_SIGNAL(src, COMSIG_MOB_RESET_PERSPECTIVE)
	return TRUE

/**
  * Examine a mob
  *
  * mob verbs are faster than object verbs. See
  * [this byond forum post](https://secure.byond.com/forum/?post=1326139&page=2#comment8198716)
  * for why this isn't atom/verb/examine()
  */
/mob/verb/examinate(atom/A as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	set name = "Examine"
	set category = "IC"

	if(isturf(A) && !(sight & SEE_TURFS) && !(A in view(client ? client.view : world.view, src)))
		// shift-click catcher may issue examinate() calls for out-of-sight turfs
		return

	if(is_blind(src) && !blind_examine_check(A))
		return

	face_atom(A)
	var/list/result
	if(client)
		if(istype(src, /mob/living/silicon/ai) && istype(A, /mob/living/carbon/human)) //Override for AI's examining humans
			var/mob/living/carbon/human/H = A
			result = H.examine_simple(src)
		else
			LAZYINITLIST(client.recent_examines)
			if(!(isnull(client.recent_examines[A]) || client.recent_examines[A] < world.time)) // originally this wasn't an assoc list, but sometimes the timer failed and atoms stayed in a client's recent_examines, so we check here manually
				var/extra_info = A.examine_more(src)
				result = extra_info
			if(!result)
				client.recent_examines[A] = world.time + EXAMINE_MORE_WINDOW
				result = A.examine(src)
				addtimer(CALLBACK(src, PROC_REF(clear_from_recent_examines), A), RECENT_EXAMINE_MAX_WINDOW)
				handle_eye_contact(A)
	else
		result = A.examine(src) // if a tree is examined but no client is there to see it, did the tree ever really exist?

	if(result.len)
		for(var/i in 1 to (length(result) - 1))
			result[i] = "[result[i]]\n"

	to_chat(src, examine_block("<span class='infoplain'>[result.Join()]</span>"))
	SEND_SIGNAL(src, COMSIG_MOB_EXAMINATE, A)


/mob/proc/clear_from_recent_examines(atom/A)
	if(QDELETED(A) || !client)
		return
	LAZYREMOVE(client.recent_examines, A)

/mob/proc/blind_examine_check(atom/examined_thing)
	return TRUE

/mob/living/blind_examine_check(atom/examined_thing)
	//need to be next to something and awake
	if(!Adjacent(examined_thing) || incapacitated())
		to_chat(src, span_warning("Something is there, but you can't see it!"))
		return FALSE

	var/active_item = get_active_held_item()
	if(active_item && active_item != examined_thing)
		to_chat(src, span_warning("Your hands are too full to examine this!"))
		return FALSE

	//you can only initiate exaimines if you have a hand, it's not disabled, and only as many examines as you have hands
	/// our active hand, to check if it's disabled/detatched
	var/obj/item/bodypart/active_hand = has_active_hand()? get_active_hand() : null
	if(!active_hand || active_hand.bodypart_disabled || LAZYLEN(do_afters) >= get_num_arms())
		to_chat(src, span_warning("You don't have a free hand to examine this!"))
		return FALSE

	//you can only queue up one examine on something at a time
	if(examined_thing in do_afters)
		return FALSE

	to_chat(src, span_notice("You start feeling around for something..."))
	visible_message(span_notice(" [name] begins feeling around for \the [examined_thing.name]..."))

	/// how long it takes for the blind person to find the thing they're examining
	var/examine_delay_length = rand(1 SECONDS, 2 SECONDS)
	if(isobj(examined_thing))
		examine_delay_length *= 1.5
	else if(ismob(examined_thing) && examined_thing != src)
		examine_delay_length *= 2

	if(examine_delay_length > 0 && !do_after(src, examine_delay_length, examined_thing))
		to_chat(src, span_notice("You can't get a good feel for what is there."))
		return FALSE

	//now we touch the thing we're examining
	/// temporarily turn off combat mode for reasons
	var/previous_combat_mode = combat_mode
	set_combat_mode(FALSE, TRUE)
	examined_thing.attack_hand(src)
	set_combat_mode(previous_combat_mode, TRUE)

	return TRUE

/**
 * handle_eye_contact() is called when we examine() something. If we examine an alive mob with a mind who has examined us in the last 2 seconds within 5 tiles, we make eye contact!
 *
 * Note that if either party has their face obscured, the other won't get the notice about the eye contact
 * Also note that examine_more() doesn't proc this or extend the timer, just because it's simpler this way and doesn't lose much.
 * The nice part about relying on examining is that we don't bother checking visibility, because we already know they were both visible to each other within the last second, and the one who triggers it is currently seeing them
 */
/mob/proc/handle_eye_contact(mob/living/examined_mob)
	return

/mob/living/handle_eye_contact(mob/living/examined_mob)
	if(!istype(examined_mob) || src == examined_mob || examined_mob.stat >= UNCONSCIOUS || !client)
		return

	var/imagined_eye_contact = FALSE
	if(!LAZYACCESS(examined_mob.client?.recent_examines, src))
		// even if you haven't looked at them recently, if you have the shift eyes trait, they may still imagine the eye contact
		if(HAS_TRAIT(examined_mob, TRAIT_SHIFTY_EYES) && prob(10 - get_dist(src, examined_mob)))
			imagined_eye_contact = TRUE
		else
			return

	if(get_dist(src, examined_mob) > EYE_CONTACT_RANGE)
		return

	// check to see if their face is blocked or, if not, a signal blocks it
	if(examined_mob.is_face_visible() && SEND_SIGNAL(src, COMSIG_MOB_EYECONTACT, examined_mob, TRUE) != COMSIG_BLOCK_EYECONTACT)
		var/msg = span_smallnotice("You make eye contact with [examined_mob].")
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), src, msg), 3) // so the examine signal has time to fire and this will print after

	if(!imagined_eye_contact && is_face_visible() && SEND_SIGNAL(examined_mob, COMSIG_MOB_EYECONTACT, src, FALSE) != COMSIG_BLOCK_EYECONTACT)
		var/msg = span_smallnotice("[src] makes eye contact with you.")
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), examined_mob, msg), 3)

///Can this mob resist (default FALSE)
/mob/proc/can_resist()
	return FALSE		//overridden in living.dm

///Spin this mob around it's central axis
/mob/proc/spin(spintime, speed)
	set waitfor = 0
	var/D = dir
	if((spintime < 1)||(speed < 1)||!spintime||!speed)
		return
	while(spintime >= speed)
		sleep(speed)
		switch(D)
			if(NORTH)
				D = EAST
			if(SOUTH)
				D = WEST
			if(EAST)
				D = SOUTH
			if(WEST)
				D = NORTH
		setDir(D)
		spintime -= speed

///Update the pulling hud icon
/mob/proc/update_pull_hud_icon()
	if(hud_used)
		if(hud_used.pull_icon)
			hud_used.pull_icon.update_appearance(UPDATE_ICON)

///Update the resting hud icon
/mob/proc/update_rest_hud_icon()
	if(hud_used)
		if(hud_used.rest_icon)
			hud_used.rest_icon.update_appearance(UPDATE_ICON)

/**
  * Verb to activate the object in your held hand
  *
  * Calls attack self on the item and updates the inventory hud for hands
  */
/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(HAS_TRAIT(src, TRAIT_NOINTERACT)) // INTERCEPTED
		to_chat(src, span_danger("You can't interact with anything right now!"))
		return

	if(ismecha(loc))
		return

	if(incapacitated())
		return

	var/obj/item/I = get_active_held_item()
	if(I)
		I.attack_self(src)
		update_inv_hands()

///clears the client mob in our client_mobs_in_contents list
/mob/proc/clear_client_in_contents()
	if(client?.movingmob)
		LAZYREMOVE(client.movingmob.client_mobs_in_contents, src)
		client.movingmob = null

/**
  * Get the notes of this mob
  *
  * This actually gets the mind datums notes
  */
/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	set desc = "View your character's notes memory."
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't look at your notes, if you had any.")

/**
  * Add a note to the mind datum
  */
/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	if(memory_amt > 50)
		return

	if(memory_amt == 50)
		log_game("[key_name(src)] might be trying to crash the server by spamming memories, rate-limiting them.")
		message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] might be trying to crash the server by spamming memories, rate-limiting them.</span>")

	memory_amt++

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't add a note to it.")

/**
  * Allows you to respawn, abandoning your current mob
  *
  * This sends you back to the lobby creating a new dead mob
  *
  * Only works if flag/norespawn is allowed in config
  */
/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if (CONFIG_GET(flag/norespawn) && (!check_rights_for(usr.client, R_ADMIN) || tgui_alert(usr, "Respawn configs disabled. Do you want to use your permissions to circumvent it?", "Respawn", list("Yes", "No")) != "Yes"))
		return
	if ((stat != DEAD || !( SSticker )))
		to_chat(usr, span_boldnotice("You must be dead to use this!"))
		return

	log_game("[key_name(usr)] used abandon mob.")

	to_chat(usr, span_boldnotice("Please roleplay correctly!"))

	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		return
	client.screen.Cut()
	client.screen += client.void
	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		return

	var/mob/dead/new_player/M = new /mob/dead/new_player()
	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		qdel(M)
		return

	M.key = key
//	M.Login()	//wat
	return


/**
  * Sometimes helps if the user is stuck in another perspective or camera
  */
/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_perspective(null)
	unset_machine()

//suppress the .click/dblclick macros so people can't use them to identify the location of items or aimbot
/mob/verb/DisClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".click"
	set hidden = TRUE
	set category = null
	return

/mob/verb/DisDblClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".dblclick"
	set hidden = TRUE
	set category = null
	return
/**
  * Topic call back for any mob
  *
  * * Unset machines if "mach_close" sent
  * * refresh the inventory of machines in range if "refresh" sent
  * * handles the strip panel equip and unequip as well if "item" sent
  */
/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

/**
  * Controls if a mouse drop succeeds (return null if it doesnt)
  */
/mob/MouseDrop(mob/M)
	. = ..()
	if(M != usr)
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(isAI(M))
		return

/**
  * Handle the result of a click drag onto this mob
  *
  * For mobs this just shows the inventory
  */

///Is the mob muzzled (default false)
/mob/proc/is_muzzled()
	return 0


/// Adds this list to the output to the stat browser
/mob/proc/get_status_tab_items()
	. = list()
	var/list/objectives = mind?.get_all_objectives()
	if(LAZYLEN(objectives))
		var/obj_count = 1
		. += "<B>Objectives:</B>"
		for(var/datum/objective/objective in mind?.get_all_objectives())
			. += "<B>[obj_count]</B>: <font color=[objective.check_completion() ? "green" : "red"]>[objective.explanation_text][objective.check_completion() ? " (COMPLETED)" : ""]</font>"
			obj_count++

/**
  * Convert a list of spells into a displyable list for the statpanel
  *
  * Shows charge and other important info
  */
/mob/proc/get_actions_for_statpanel()
	var/list/data = list()
	for(var/datum/action/cooldown/action in actions)
		var/list/action_data = action.set_statpanel_format()
		if(!length(action_data))
			return

		data += list(list(
			// the panel the action gets displayed to
			// in the future, this could probably be replaced with subtabs (a la admin tabs)
			action_data[PANEL_DISPLAY_PANEL],
			// the status of the action, - cooldown, charges, whatever
			action_data[PANEL_DISPLAY_STATUS],
			// the name of the action
			action_data[PANEL_DISPLAY_NAME],
			// a ref to the action button of this action for this mob
			// it's a ref to the button specifically, instead of the action itself,
			// because statpanel href calls click(), which the action button (not the action itself) handles
			REF(action.viewers[hud_used]),
		))

	return data

#define MOB_FACE_DIRECTION_DELAY 1

// facing verbs
/**
  * Returns true if a mob can turn to face things
  *
  * Conditions:
  * * client.last_turn > world.time
  * * not dead or unconscious
  * * not anchored
  * * no transform not set
  * * we are not restrained
  */
/mob/proc/canface()
	if(world.time < client.last_turn)
		return FALSE
	if(stat == DEAD || stat == UNCONSCIOUS)
		return FALSE
	if(anchored)
		return FALSE
	if(notransform)
		return FALSE
	if(restrained())
		return FALSE
	return TRUE

///Checks mobility move as well as parent checks
/mob/living/canface()
	if(!(mobility_flags & MOBILITY_MOVE))
		return FALSE
	return ..()

/mob/setShift(dir)
	if (!canface())
		return FALSE

	is_shifted = TRUE

	return ..()

///This might need a rename but it should replace the can this mob use things check
/mob/proc/IsAdvancedToolUser()
	return FALSE

/mob/proc/swap_hand(held_index)
	SHOULD_NOT_OVERRIDE(TRUE) // Override perform_hand_swap instead

	var/obj/item/held_item = get_active_held_item()
	if(SEND_SIGNAL(src, COMSIG_MOB_SWAPPING_HANDS, held_item) & COMPONENT_BLOCK_SWAP)
		to_chat(src, span_warning("Your other hand is too busy holding [held_item]."))
		return FALSE

	var/result = perform_hand_swap(held_index)
	if (result)
		SEND_SIGNAL(src, COMSIG_MOB_SWAP_HANDS)

	return result

/// Performs the actual ritual of swapping hands, such as setting the held index variables
/mob/proc/perform_hand_swap(held_index)
	PROTECTED_PROC(TRUE)
	return TRUE

/mob/proc/activate_hand(selhand)
	return

/mob/proc/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) //For sec bot threat assessment
	return 0

///Get the ghost of this mob (from the mind)
/mob/proc/get_ghost(even_if_they_cant_reenter, ghosts_with_clients)
	if(mind)
		return mind.get_ghost(even_if_they_cant_reenter, ghosts_with_clients)

///Force get the ghost from the mind
/mob/proc/grab_ghost(force)
	if(mind)
		return mind.grab_ghost(force = force)

///Notify a ghost that it's body is being cloned
/mob/proc/notify_ghost_cloning(message = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!", sound = 'sound/effects/genetics.ogg', atom/source = null, flashwindow)
	var/mob/dead/observer/ghost = get_ghost()
	if(ghost)
		ghost.notify_cloning(message, sound, source, flashwindow)
		return ghost

/**
 * Checks to see if the mob can cast normal magic spells.
 *
 * args:
 * * magic_flags (optional) A bitfield with the type of magic being cast (see flags at: /datum/component/anti_magic)
**/
/mob/proc/can_cast_magic(magic_flags = MAGIC_RESISTANCE)
	if(magic_flags == NONE) // magic with the NONE flag can always be cast
		return TRUE

	var/restrict_magic_flags = SEND_SIGNAL(src, COMSIG_MOB_RESTRICT_MAGIC, magic_flags)
	return restrict_magic_flags == NONE

/**
 * Checks to see if the mob can block magic
 *
 * args:
 * * casted_magic_flags (optional) A bitfield with the types of magic resistance being checked (see flags at: /datum/component/anti_magic)
 * * charge_cost (optional) The cost of charge to block a spell that will be subtracted from the protection used
**/
/mob/proc/can_block_magic(casted_magic_flags = MAGIC_RESISTANCE, charge_cost = 1)
	if(casted_magic_flags == NONE) // magic with the NONE flag is immune to blocking
		return FALSE

	// A list of all things which are providing anti-magic to us
	var/list/antimagic_sources = list()
	var/is_magic_blocked = FALSE

	if(SEND_SIGNAL(src, COMSIG_MOB_RECEIVE_MAGIC, casted_magic_flags, charge_cost, antimagic_sources) & COMPONENT_MAGIC_BLOCKED)
		is_magic_blocked = TRUE
	if(HAS_TRAIT(src, TRAIT_ANTIMAGIC))
		is_magic_blocked = TRUE
	if((casted_magic_flags & MAGIC_RESISTANCE_HOLY) && HAS_TRAIT(src, TRAIT_HOLY))
		is_magic_blocked = TRUE

	if(is_magic_blocked && charge_cost > 0 && !HAS_TRAIT(src, TRAIT_RECENTLY_BLOCKED_MAGIC))
		on_block_magic_effects(casted_magic_flags, antimagic_sources)

	return is_magic_blocked

/// Called whenever a magic effect with a charge cost is blocked and we haven't recently blocked magic.
/mob/proc/on_block_magic_effects(magic_flags, list/antimagic_sources)
	return

/mob/living/on_block_magic_effects(magic_flags, list/antimagic_sources)
	ADD_TRAIT(src, TRAIT_RECENTLY_BLOCKED_MAGIC, MAGIC_TRAIT)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_RECENTLY_BLOCKED_MAGIC, MAGIC_TRAIT), 6 SECONDS)

/* //comment this in if you want antimagic to have a visible effect.
	var/mutable_appearance/antimagic_effect
	var/antimagic_color
	var/atom/antimagic_source = length(antimagic_sources) ? pick(antimagic_sources) : src

	if(magic_flags & MAGIC_RESISTANCE)
		visible_message(
			span_warning("[src] pulses red as [ismob(antimagic_source) ? p_they() : antimagic_source] absorbs magic energy!"),
			span_userdanger("An intense magical aura pulses around [ismob(antimagic_source) ? "you" : antimagic_source] as it dissipates into the air!"),
		)
		antimagic_effect = mutable_appearance('icons/effects/effects.dmi', "shield-red", MOB_SHIELD_LAYER)
		antimagic_color = LIGHT_COLOR_BLOOD_MAGIC
		playsound(src, 'sound/magic/magic_block.ogg', 50, TRUE)

	else if(magic_flags & MAGIC_RESISTANCE_HOLY)
		visible_message(
			span_warning("[src] starts to glow as [ismob(antimagic_source) ? p_they() : antimagic_source] emits a halo of light!"),
			span_userdanger("A feeling of warmth washes over [ismob(antimagic_source) ? "you" : antimagic_source] as rays of light surround your body and protect you!"),
		)
		antimagic_effect = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
		antimagic_color = LIGHT_COLOR_HOLY_MAGIC
		playsound(src, 'sound/magic/magic_block_holy.ogg', 50, TRUE)

	else if(magic_flags & MAGIC_RESISTANCE_MIND)
		visible_message(
			span_warning("[src] forehead shines as [ismob(antimagic_source) ? p_they() : antimagic_source] repulses magic from their mind!"),
			span_userdanger("A feeling of cold splashes on [ismob(antimagic_source) ? "you" : antimagic_source] as your forehead reflects magic usering your mind!"),
		)
		antimagic_effect = mutable_appearance('icons/effects/genetics.dmi', "telekinesishead", MOB_SHIELD_LAYER)
		antimagic_color = LIGHT_COLOR_DARK_BLUE
		playsound(src, 'sound/magic/magic_block_mind.ogg', 50, TRUE)

	mob_light(range = 2, color = antimagic_color, duration = 5 SECONDS)
	add_overlay(antimagic_effect)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, cut_overlay), antimagic_effect), 5 SECONDS)
*/

/**
  * Buckle to another mob
  *
  * You can buckle on mobs if you're next to them since most are dense
  *
  * Turns you to face the other mob too
  */
/mob/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(M.buckled)
		return 0
	var/turf/T = get_turf(src)
	if(M.loc != T)
		var/old_density = density
		density = FALSE
		var/can_step = step_towards(M, T)
		density = old_density
		if(!can_step)
			return 0
	return ..()

///Call back post buckle to a mob to offset your visual height
/mob/post_buckle_mob(mob/living/M)
	var/height = M.get_mob_buckling_height(src)
	M.pixel_y = initial(M.pixel_y) + height
	if(M.layer < layer)
		M.layer = layer + 0.1
///Call back post unbuckle from a mob, (reset your visual height here)
/mob/post_unbuckle_mob(mob/living/M)
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)

///returns the height in pixel the mob should have when buckled to another mob.
/mob/proc/get_mob_buckling_height(mob/seat)
	if(isliving(seat))
		var/mob/living/L = seat
		if(L.mob_size <= MOB_SIZE_SMALL) //being on top of a small mob doesn't put you very high.
			return 0
	return 9

///can the mob be buckled to something by default?
/mob/proc/can_buckle()
	return 1

///can the mob be unbuckled from something by default?
/mob/proc/can_unbuckle()
	return 1

///Can the mob interact() with an atom?
/mob/proc/can_interact_with(atom/A)
	return IsAdminGhost(src) || Adjacent(A)

///Can the mob use Topic to interact with machines
/mob/proc/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	return

///Can this mob use storage
/mob/proc/canUseStorage()
	return FALSE
/**
  * Check if the other mob has any factions the same as us
  *
  * If exact match is set, then all our factions must match exactly
  */
/mob/proc/faction_check_mob(mob/target, exact_match)
	if(exact_match) //if we need an exact match, we need to do some bullfuckery.
		var/list/faction_src = faction.Copy()
		var/list/faction_target = target.faction.Copy()
		if(!("[REF(src)]" in faction_target)) //if they don't have our ref faction, remove it from our factions list.
			faction_src -= "[REF(src)]" //if we don't do this, we'll never have an exact match.
		if(!("[REF(target)]" in faction_src))
			faction_target -= "[REF(target)]" //same thing here.
		return faction_check(faction_src, faction_target, TRUE)
	return faction_check(faction, target.faction, FALSE)
/*
 * Compare two lists of factions, returning true if any match
 *
 * If exact match is passed through we only return true if both faction lists match equally
 */
/proc/faction_check(list/faction_A, list/faction_B, exact_match)
	var/list/match_list
	if(exact_match)
		match_list = faction_A&faction_B //only items in both lists
		var/length = LAZYLEN(match_list)
		if(length)
			return (length == LAZYLEN(faction_A)) //if they're not the same len(gth) or we don't have a len, then this isn't an exact match.
	else
		match_list = faction_A&faction_B
		return LAZYLEN(match_list)
	return FALSE


/**
  * Fully update the name of a mob
  *
  * This will update a mob's name, real_name, mind.name, GLOB.data_core records, pda, id and traitor text
  *
  * Calling this proc without an oldname will only update the mob and skip updating the pda, id and records ~Carn
  */
/mob/proc/fully_replace_character_name(oldname,newname)
	log_message("[src] name changed from [oldname] to [newname]", LOG_OWNERSHIP)
	if(!newname)
		return 0

	log_played_names(ckey,newname)

	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
		if(mind.key)
			log_played_names(mind.key,newname) //Just in case the mind is unsynced at the moment.

	if(oldname)
		//update the datacore records! This is goig to be a bit costly.
		replace_records_name(oldname,newname)

		//update our pda and id if we have them on our person
		replace_identification_name(oldname,newname)

		for(var/datum/mind/T in SSticker.minds)
			for(var/datum/objective/obj in T.get_all_objectives())
				// Only update if this player is a target
				if(obj.target && obj.target.current && obj.target.current.real_name == name)
					obj.update_explanation_text()
	return 1

///Updates GLOB.data_core records with new name , see mob/living/carbon/human
/mob/proc/replace_records_name(oldname,newname)
	return

///update the ID name of this mob
/mob/proc/replace_identification_name(oldname,newname)
	var/list/searching = get_all_contents()
	var/search_id = 1
	var/search_pda = 1

	for(var/A in searching)
		if( search_id && istype(A, /obj/item/card/id) )
			var/obj/item/card/id/ID = A
			if(ID.registered_name == oldname)
				ID.registered_name = newname
				ID.update_label()
				if(istype(ID.loc, /obj/item/computer_hardware/card_slot))
					var/obj/item/computer_hardware/card_slot/CS = ID.loc
					CS.holder?.update_label()
				if(ID.registered_account?.account_holder == oldname)
					ID.registered_account.account_holder = newname
				if(!search_pda)
					break
				search_id = 0

		else if( search_pda && istype(A, /obj/item/modular_computer/tablet) )
			var/obj/item/modular_computer/tablet/PDA_or_phone = A
			PDA_or_phone.update_label()
			if(!search_id)
				break
			search_pda = 0

/mob/proc/update_stat()
	return

/mob/proc/update_health_hud()
	return

/// Changes the stamina HUD based on new information
/mob/proc/update_stamina_hud()
	return

///Update the lighting plane and sight of this mob (sends COMSIG_MOB_UPDATE_SIGHT)
/mob/proc/update_sight()
	SHOULD_CALL_PARENT(TRUE)
	if(HAS_TRAIT(src, TRAIT_NIGHT_VISION))
		lighting_cutoff = max(lighting_cutoff, 6)
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_cutoff()

///Set the lighting plane hud alpha to the mobs lighting_alpha var
/mob/proc/sync_lighting_plane_cutoff()
	if(!hud_used)
		return
	for(var/atom/movable/screen/plane_master/rendering_plate/lighting/light as anything in hud_used.get_true_plane_masters(RENDER_PLANE_LIGHTING))
		light.set_light_cutoff(lighting_cutoff, lighting_color_cutoffs)

///Update the mouse pointer of the attached client in this mob
/mob/proc/update_mouse_pointer()
	if (!client)
		return
	client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
	if (ismecha(loc))
		var/obj/mecha/M = loc
		if(M.mouse_pointer)
			client.mouse_pointer_icon = M.mouse_pointer
	else if (istype(loc, /obj/vehicle/sealed))
		var/obj/vehicle/sealed/E = loc
		if(E.mouse_pointer)
			client.mouse_pointer_icon = E.mouse_pointer

	if(client.mouse_override_icon)
		client.mouse_pointer_icon = client.mouse_override_icon

/mob/proc/has_nightvision()
	// Somewhat conservative, basically is your lighting plane bright enough that you the user can see stuff
	var/light_offset = (lighting_color_cutoffs[1] + lighting_color_cutoffs[2] + lighting_color_cutoffs[3]) / 3 + lighting_cutoff
	return light_offset >= LIGHTING_NIGHTVISION_THRESHOLD

///This mob is abile to read books
/mob/proc/is_literate()
	return FALSE

///Can this mob read (is literate and not blind)
/mob/proc/can_read(obj/O)
	if(is_blind(src))
		to_chat(src, span_warning("As you are trying to read [O], you suddenly feel very stupid!"))
		return
	if(!is_literate())
		to_chat(src, span_notice("You try to read [O], but can't comprehend any of it."))
		return
	return TRUE

///Can this mob hold items
/mob/proc/can_hold_items()
	return FALSE

///Get the id card on this mob
/mob/proc/get_idcard(hand_first)
	return

/mob/proc/get_id_in_hand()
	return

/**
  * Get the mob VV dropdown extras
  */
/mob/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_SEPERATOR
	VV_DROPDOWN_OPTION(VV_HK_GIB, "Gib")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_SPELL, "Give Spell")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_SPELL, "Remove Spell")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_DISEASE, "Give Disease")
	VV_DROPDOWN_OPTION(VV_HK_GODMODE, "Toggle Godmode")
	VV_DROPDOWN_OPTION(VV_HK_DROP_ALL, "Drop Everything")
	VV_DROPDOWN_OPTION(VV_HK_REGEN_ICONS, "Regenerate Icons")
	VV_DROPDOWN_OPTION(VV_HK_PLAYER_PANEL, "Show player panel")
	VV_DROPDOWN_OPTION(VV_HK_BUILDMODE, "Toggle Buildmode")
	VV_DROPDOWN_OPTION(VV_HK_DIRECT_CONTROL, "Assume Direct Control")
	VV_DROPDOWN_OPTION(VV_HK_OFFER_GHOSTS, "Offer Control to Ghosts")
	VV_DROPDOWN_OPTION(VV_HK_SET_AFK_TIMER, "Set AFK Timer")


/mob/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_REGEN_ICONS] && check_rights(R_VAREDIT))
		regenerate_icons()
	if(href_list[VV_HK_PLAYER_PANEL])
		usr.client.holder.show_player_panel(src)
	if(href_list[VV_HK_GODMODE]  && check_rights(R_ADMIN))
		usr.client.cmd_admin_godmode(src)
	if(href_list[VV_HK_GIVE_SPELL] && check_rights(R_VAREDIT))
		usr.client.give_spell(src)
	if(href_list[VV_HK_REMOVE_SPELL]  && check_rights(R_VAREDIT))
		usr.client.remove_spell(src)
	if(href_list[VV_HK_GIVE_DISEASE] && check_rights(R_VAREDIT))
		usr.client.give_disease(src)
	if(href_list[VV_HK_GIB] && check_rights(R_FUN))
		usr.client.cmd_admin_gib(src)
	if(href_list[VV_HK_BUILDMODE] && check_rights(R_BUILDMODE))
		togglebuildmode(src)
	if(href_list[VV_HK_DROP_ALL] && check_rights(R_ADMIN))
		usr.client.cmd_admin_drop_everything(src)
	if(href_list[VV_HK_DIRECT_CONTROL] && check_rights(R_VAREDIT))
		usr.client.cmd_assume_direct_control(src)
	if(href_list[VV_HK_OFFER_GHOSTS] && check_rights(R_ADMIN))
		offer_control(src)
	if(href_list[VV_HK_SET_AFK_TIMER] && check_rights(R_ADMIN))
		if(!mind)
			to_chat(usr, "This cannot be used on mobs without a mind")
			return

		var/timer = input("Input AFK length in minutes, 0 to cancel the current timer", text("Input"))  as num|null
		if(timer == null) // Explicit null check for cancel, rather than generic truthyness, so 0 is handled differently
			return

		deltimer(mind.afk_verb_timer)
		mind.afk_verb_used = FALSE

		if(!timer)
			return

		mind.afk_verb_used = TRUE
		mind.afk_verb_timer = addtimer(VARSET_CALLBACK(mind, afk_verb_used, FALSE), timer MINUTES, TIMER_STOPPABLE);


/**
  * extra var handling for the logging var
  */
/mob/vv_get_var(var_name)
	switch(var_name)
		if("logging")
			return debug_variable(var_name, logging, 0, src, FALSE)
	. = ..()

/mob/vv_auto_rename(new_name)
	//Do not do parent's actions, as we *usually* do this differently.
	fully_replace_character_name(real_name, new_name)
	usr.client.vv_update_display(src, "name", new_name)
	usr.client.vv_update_display(src, "real_name", real_name || "No real name")

///Show the language menu for this mob
/mob/verb/open_language_menu()
	set name = "Open Language Menu"
	set category = "IC"

	var/datum/language_holder/H = get_language_holder()
	H.open_language_menu(usr)

///Adjust the nutrition of a mob
/mob/proc/adjust_nutrition(change) //Honestly FUCK the oldcoders for putting nutrition on /mob someone else can move it up because holy hell I'd have to fix SO many typechecks
	nutrition = max(0, nutrition + change)
	return nutrition

///Force set the mob nutrition
/mob/proc/set_nutrition(change) //Seriously fuck you oldcoders.
	nutrition = max(0, change)
	return nutrition

/mob/proc/set_stat(new_stat)
	if(new_stat == stat)
		return
	. = stat
	stat = new_stat
	SEND_SIGNAL(src, COMSIG_MOB_STATCHANGE, new_stat, .)

///Set the movement type of the mob and update it's movespeed
/mob/setMovetype(newval)
	. = ..()
	update_movespeed(FALSE)

//I am looking respectfully

/mob/living/verb/lookup()
	set name = "Look Up"
	set category = "IC"

	if(looking_vertically)
		end_look_up()
	else
		look_up()

/mob/living/verb/lookdown()
	set name = "Look Down"
	set category = "IC"

	if(looking_vertically)
		end_look_down()
	else
		look_down()

/**
 * look_up Changes the perspective of the mob to any openspace turf above the mob
 *
 * This also checks if an openspace turf is above the mob before looking up or resets the perspective if already looking up
 *
 */
/mob/living/proc/look_up()
	if(client.perspective != MOB_PERSPECTIVE) //We are already looking up.
		stop_look_up()
	if(!can_look_up())
		return
	changeNext_move(CLICK_CD_LOOK_UP)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(stop_look_up)) //We stop looking up if we move.
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(start_look_up)) //We start looking again after we move.
	start_look_up()

/mob/living/proc/start_look_up()
	SIGNAL_HANDLER
	var/turf/ceiling = get_step_multiz(src, UP)
	if(!ceiling) //We are at the highest z-level.
		if (prob(0.1))
			to_chat(src, span_warning("You gaze out into the infinite vastness of deep space, for a moment, you have the impulse to continue travelling, out there, out into the deep beyond, before your conciousness reasserts itself and you decide to stay within travelling distance of the station."))
			return
		to_chat(src, span_warning("There's nothing interesting up there."))
		return
	else if(!istransparentturf(ceiling)) //There is no turf we can look through above us
		var/turf/front_hole = get_step(ceiling, dir)
		if(istransparentturf(front_hole))
			ceiling = front_hole
		else
			for(var/turf/checkhole in TURF_NEIGHBORS(ceiling))
				if(istransparentturf(checkhole))
					ceiling = checkhole
					break
		if(!istransparentturf(ceiling))
			to_chat(src, span_warning("You can't see through the floor above you."))
			return

	looking_vertically = TRUE
	reset_perspective(ceiling)

/mob/living/proc/stop_look_up()
	SIGNAL_HANDLER
	reset_perspective()

/mob/living/proc/end_look_up()
	stop_look_up()
	looking_vertically = FALSE
	UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/**
 * look_down Changes the perspective of the mob to any openspace turf below the mob
 *
 * This also checks if an openspace turf is below the mob before looking down or resets the perspective if already looking up
 *
 */
/mob/living/proc/look_down()
	if(client.perspective != MOB_PERSPECTIVE) //We are already looking down.
		stop_look_down()
	if(!can_look_up()) //if we cant look up, we cant look down.
		return
	changeNext_move(CLICK_CD_LOOK_UP)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(stop_look_down)) //We stop looking down if we move.
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(start_look_down)) //We start looking again after we move.
	start_look_down()

/mob/living/proc/start_look_down()
	SIGNAL_HANDLER
	var/turf/floor = get_turf(src)
	var/turf/lower_level = get_step_multiz(floor, DOWN)
	if(!lower_level) //We are at the lowest z-level.
		to_chat(src, span_warning("You can't see through the floor below you."))
		return
	else if(!istransparentturf(floor)) //There is no turf we can look through below us
		var/turf/front_hole = get_step(floor, dir)
		if(istransparentturf(front_hole))
			floor = front_hole
			lower_level = get_step_multiz(front_hole, DOWN)
		else
			// Try to find a hole near us
			for(var/turf/checkhole in TURF_NEIGHBORS(floor))
				if(istransparentturf(checkhole))
					floor = checkhole
					lower_level = get_step_multiz(checkhole, DOWN)
					break
		if(!istransparentturf(floor))
			to_chat(src, span_warning("You can't see through the floor below you."))
			return

	looking_vertically = TRUE
	reset_perspective(lower_level)

/mob/living/proc/stop_look_down()
	SIGNAL_HANDLER
	reset_perspective()

/mob/living/proc/end_look_down()
	stop_look_down()
	looking_vertically = FALSE
	UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

///Checks if the user is incapacitated or on cooldown.
/mob/living/proc/can_look_up()
	if(next_move > world.time)
		return FALSE
	if(incapacitated(ignore_restraints = TRUE))
		return FALSE
	return TRUE
