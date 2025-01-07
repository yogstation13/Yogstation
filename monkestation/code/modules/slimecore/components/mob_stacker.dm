/datum/component/mob_stacker
	var/list/stacked_mobs = list()
	///until we get a better pixel proc this is a constant offset
	var/constant_offset = 0
	///this is our top most atoms
	var/mob/living/current_head
	///this is our brain the main dude
	var/mob/living/main_dude

	///are we breaking apart
	var/breaking = FALSE

	var/max_size = 1


/datum/component/mob_stacker/Initialize()
	. = ..()
	main_dude = parent
	current_head = parent
	max_size = rand(1, 7)
	main_dude.max_buckled_mobs = max_size
	var/lifetime = rand(30 SECONDS, 120 SECONDS)
	QDEL_IN(src, lifetime)

/datum/component/mob_stacker/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_CHECK_CAN_ADD_NEW_STACK, PROC_REF(can_add))
	RegisterSignal(parent, COMSIG_ATOM_JOIN_STACK, PROC_REF(try_join_stack))
	RegisterSignal(parent, COMSIG_LIVING_SET_BUCKLED, PROC_REF(check_collapse))
	RegisterSignal(parent, COMSIG_MOBSTACKER_DESTROY, PROC_REF(destroy_self))

/datum/component/mob_stacker/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_CHECK_CAN_ADD_NEW_STACK,
		COMSIG_ATOM_JOIN_STACK,
		COMSIG_LIVING_SET_BUCKLED,
		COMSIG_MOBSTACKER_DESTROY
	))

/datum/component/mob_stacker/Destroy(force)
	main_dude.buckled?.unbuckle_mob(main_dude, force = TRUE)
	main_dude = null
	current_head = null
	for(var/mob/living/dude as anything in stacked_mobs)
		if(isbasicmob(dude))
			var/mob/living/basic/basic = dude
			basic.ai_controller?.reset_ai_status()
		REMOVE_TRAIT(dude, TRAIT_IN_STACK, REF(src))
		UnregisterSignal(dude, list(COMSIG_ATOM_JOIN_STACK, COMSIG_LIVING_SET_BUCKLED))
		dude.buckled?.unbuckle_mob(dude, force = TRUE)
	stacked_mobs.len = 0
	return ..()


/datum/component/mob_stacker/proc/try_join_stack(datum/source, mob/living/joiner)
	SIGNAL_HANDLER
	if(joiner in stacked_mobs)
		return

	if(main_dude.buckle_mob(joiner, force = TRUE))
		ADD_TRAIT(joiner, TRAIT_IN_STACK, REF(src))
		if(isbasicmob(joiner))
			var/mob/living/basic/basic = joiner
			basic.ai_controller?.set_ai_status(AI_STATUS_OFF)
		current_head = joiner
		stacked_mobs += joiner
		RegisterSignal(joiner, COMSIG_ATOM_JOIN_STACK, PROC_REF(try_join_stack))
		RegisterSignal(joiner, COMSIG_LIVING_SET_BUCKLED, PROC_REF(check_collapse))
		joiner.pixel_y += constant_offset
		constant_offset += joiner.get_mob_buckling_height(current_head)

/datum/component/mob_stacker/proc/check_collapse(mob/living/source, atom/movable/new_buckled)
	if(new_buckled != main_dude && !breaking)
		breaking = TRUE
		qdel(src)

/datum/component/mob_stacker/proc/can_add(datum/source)
	SIGNAL_HANDLER
	//this isn't a 1 line return because I like to debug
	var/value = length(stacked_mobs)
	if(value < max_size)
		return TRUE
	else
		return FALSE

/datum/component/mob_stacker/proc/destroy_self()
	qdel(src)
