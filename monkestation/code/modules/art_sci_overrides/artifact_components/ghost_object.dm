///This is straight up an object version of the spirit plade one
/datum/component/ghost_object_control
	var/attempting_awakening = FALSE
	///mob contained in the item,null untill controlled!
	var/mob/living/basic/shade/bound_spirit
	///do we make a callback to retry untill someone posesses it?
	var/repolling= FALSE
	///How often can this thing move in seconds
	var/speed= 1.25
	COOLDOWN_DECLARE(move_cooldown)
/datum/component/ghost_object_control/Initialize(repoll = FALSE,move_speed = null)
	if(!ismovable(parent)) //you may apply this to mobs, I take no responsibility for how that works out
		return COMPONENT_INCOMPATIBLE
	if(move_speed)
		speed = move_speed

/datum/component/ghost_object_control/Destroy(force, silent)
	. = ..()
	if(bound_spirit)
		QDEL_NULL(bound_spirit)

/datum/component/ghost_object_control/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_destroy))
	RegisterSignal(parent, COMSIG_ATOM_RELAYMOVE, TYPE_PROC_REF(/datum/component/ghost_object_control,move_host))
	//RegisterSignal(parent, COMSIG_RIDDEN_DRIVER_MOVE, TYPE_PROC_REF(/datum/component/ghost_object_control,move_host))

/datum/component/ghost_object_control/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_QDELETING, COMSIG_ATOM_RELAYMOVE))

///Moves the object. Yippee!
/datum/component/ghost_object_control/proc/move_host(atom/movable/movable_parent,mob/buckled_mob,dir_to_move)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, move_cooldown))
		return COMSIG_BLOCK_RELAYMOVE
	var/turf/next = get_step(movable_parent, dir_to_move)
	var/turf/current = get_turf(movable_parent)
	if(!istype(next) || !istype(current))
		return COMSIG_BLOCK_RELAYMOVE
	if(next.density)
		return COMSIG_BLOCK_RELAYMOVE
	if(!isturf(movable_parent.loc))
		return COMSIG_BLOCK_RELAYMOVE

	step(movable_parent, dir_to_move)
	var/last_move_diagonal = ((dir_to_move & (dir_to_move - 1)) && (movable_parent.loc == next))
	COOLDOWN_START(src, move_cooldown, ((last_move_diagonal ? 2 : 1) * speed) SECOND)

	if(QDELETED(src))
		return COMSIG_BLOCK_RELAYMOVE
	return TRUE

///signal fired on examining the parent
/datum/component/ghost_object_control/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!bound_spirit)
		return
	examine_list += span_notice("[parent] is moving somehow?")

///Call to poll for ghost role
/datum/component/ghost_object_control/proc/request_control(movement_speed)
	if(attempting_awakening)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return

	attempting_awakening = TRUE

	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as [parent]?",
		check_jobban = ROLE_SENTIENCE,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_SENTIENCE_POTION,
		alert_pic = parent,
		role_name_text = "[parent]",
	)
	if(!LAZYLEN(candidates))
		if(repolling)
			addtimer(CALLBACK(src,PROC_REF(request_control),2.5 MINUTE))
		attempting_awakening = FALSE
		return

	var/mob/dead/observer/chosen_spirit = pick(candidates)
	bound_spirit = new(parent)
	bound_spirit.ckey = chosen_spirit.ckey
	bound_spirit.fully_replace_character_name(null, "[parent]")
	bound_spirit.status_flags |= GODMODE
	bound_spirit.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue
	bound_spirit.update_atom_languages()
	speed = movement_speed

	//Add new signals for parent and stop attempting to awaken

	// Now that all of the important things are in place for our spirit, it's time for them to choose their name.
	var/valid_input_name = custom_name(bound_spirit)
	if(valid_input_name)
		bound_spirit.fully_replace_character_name(null, "[valid_input_name]")

	attempting_awakening = FALSE

/**
 * custom_name : Simply sends a tgui input text box to the blade asking what name they want to be called, and retries it if the input is invalid.
 *
 * Arguments:
 * * awakener: user who interacted with the blade
 */
/datum/component/ghost_object_control/proc/custom_name(mob/subject)
	var/chosen_name = sanitize_name(tgui_input_text(bound_spirit, "What are you named?", "Spectral Nomenclature", max_length = MAX_NAME_LEN))
	if(!chosen_name) // with the way that sanitize_name works, it'll actually send the error message to the awakener as well.
		return custom_name(subject) //YOU WILL PICK A NAME.
	return chosen_name

///signal fired from parent being destroyed
/datum/component/ghost_object_control/proc/on_destroy(datum/source)
	SIGNAL_HANDLER
	to_chat(bound_spirit, span_userdanger("You were destroyed!"))
	QDEL_NULL(bound_spirit)
