#define DEFER_MOVE 1 //Let /client/Move() handle the movement
#define MOVE_ALLOWED 2 //Allow mob to pass through
#define MOVE_NOT_ALLOWED 3 //Do not let the mob through

#define SHADOWWALK_THRESHOLD 0.02

/datum/component/walk

/datum/component/walk/Initialize()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_PROCESS_MOVE, .proc/handle_move)
	var/datum/component/footstep/footsteps = parent.GetComponent(/datum/component/footstep)
	if(footsteps)
		footsteps.signal_enabled = FALSE

/datum/component/walk/RemoveComponent()
	var/datum/component/footstep/footsteps = parent.GetComponent(/datum/component/footstep)
	if(footsteps)
		footsteps.signal_enabled = TRUE
	return ..()

/datum/component/walk/proc/handle_move(datum/source, direction)
	var/mob/living/L = parent
	var/turf/T = get_step(L, direction)
	L.setDir(direction)
	if(!T)
		return
	var/allowed = can_walk(L, T)
	switch(allowed)
		if(DEFER_MOVE)
			return FALSE
		if(MOVE_NOT_ALLOWED)
			return TRUE
		if(MOVE_ALLOWED)
			preprocess_move(L, T)
			L.forceMove(T)
			finalize_move(L, T)
			return TRUE

/datum/component/walk/proc/can_walk(mob/living/user, turf/destination)
	return MOVE_ALLOWED

/datum/component/walk/proc/preprocess_move(mob/living/user, turf/destination)
	return

/datum/component/walk/proc/finalize_move(mob/living/user, turf/destination)
	return

/datum/component/walk/shadow
	var/atom/movable/pulled

/datum/component/walk/shadow/can_walk(mob/living/user, turf/destination)
	return (destination.get_lumcount() <= SHADOWWALK_THRESHOLD ? MOVE_ALLOWED : DEFER_MOVE)

/datum/component/walk/shadow/preprocess_move(mob/living/user, turf/destination)
	if(user.pulling)
		if(user.pulling.anchored || (user.pulling == user.loc && user.pulling.density))
			user.stop_pulling()
			return
		if(isliving(user.pulling))
			var/mob/living/L = user.pulling
			L.stop_pulling()
			if(L.buckled && L.buckled.buckle_prevents_pull)
				user.stop_pulling()
				return
			L.face_atom(user)
		pulled = user.pulling
		user.pulling.forceMove(get_turf(user))

/datum/component/walk/shadow/finalize_move(mob/living/user, turf/destination)
	if(pulled)
		user.start_pulling(pulled, TRUE)
		pulled = null

/datum/component/walk/jaunt

/datum/component/walk/jaunt/can_walk(mob/living/user, turf/destination)
	for(var/obj/effect/decal/cleanable/food/salt/S in destination)
		to_chat(user, span_warning("[S] bars your passage!"))
		if(isrevenant(user))
			var/mob/living/simple_animal/revenant/R = user
			R.reveal(20)
			R.stun(20)
		return MOVE_NOT_ALLOWED
	if(destination.flags_1 & NOJAUNT_1 || is_secret_level(destination.z))
		to_chat(user, span_warning("Some strange aura is blocking the way."))
		return MOVE_NOT_ALLOWED
	if (locate(/obj/effect/blessing, destination))
		to_chat(user, span_warning("Holy energies block your path!"))
		return MOVE_NOT_ALLOWED
	return MOVE_ALLOWED

#undef DEFER_MOVE
#undef MOVE_ALLOWED
#undef MOVE_NOT_ALLOWED
