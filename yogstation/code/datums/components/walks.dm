#define DEFER_MOVE 1 //Let /client/Move() handle the movement
#define MOVE_ALLOWED 2 //Allow mob to pass through
#define MOVE_NOT_ALLOWED 3 //Do not let the mob through

#define WALK_COMPONENT_TRAIT "walk_component_trait"

/datum/component/walk

/datum/component/walk/Initialize()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(handle_move))
	ADD_TRAIT(parent, TRAIT_SILENT_FOOTSTEPS, WALK_COMPONENT_TRAIT)

/datum/component/walk/ClearFromParent()
	REMOVE_TRAIT(parent, TRAIT_SILENT_FOOTSTEPS, WALK_COMPONENT_TRAIT)
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
	///use for tracking movement delay for shadow walking through walls
	var/move_delay = 0
	var/atom/movable/pulled

/datum/component/walk/shadow/handle_move(datum/source, direction)
	if(world.time < move_delay) //do not move anything ahead of this check please
		return TRUE

	var/mob/living/L = parent
	if(!isshadowperson(L))
		return FALSE
	var/turf/T = get_step(L, direction)
	L.setDir(direction)
	if(!T)
		return

	//copied from mob_movement.dm to add proper movement delay to shadow walking
	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag //this is here because Move() can now be called mutiple times per tick
	var/add_delay = L.movement_delay()
	L.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay * (((direction & 3) && (direction & 12)) ? 2 : 1))) // set it now in case of pulled objects
	if(old_move_delay + (add_delay*MOVEMENT_DELAY_BUFFER_DELTA) + MOVEMENT_DELAY_BUFFER > world.time)
		move_delay = old_move_delay
	else
		move_delay = world.time

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
			if(direction & (direction - 1)) //extra delay for diagonals
				add_delay *= 1.414214 // sqrt(2)
			L.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay))
			move_delay += add_delay
			return TRUE

/datum/component/walk/shadow/can_walk(mob/living/user, turf/destination)
	return ((destination.get_lumcount() <= SHADOW_SPECIES_DIM_LIGHT && !istype(destination, /turf/closed/mineral)) ? MOVE_ALLOWED : DEFER_MOVE)

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
		pulled.set_glide_size(user.glide_size)
		user.pulling.forceMove(get_turf(user))

/datum/component/walk/shadow/finalize_move(mob/living/user, turf/destination)
	if(pulled)
		user.start_pulling(pulled, TRUE, supress_message = TRUE)
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
	if(destination.turf_flags & NOJAUNT || is_secret_level(destination.z))
		to_chat(user, span_warning("Some strange aura is blocking the way."))
		return MOVE_NOT_ALLOWED
	if (locate(/obj/effect/blessing, destination))
		to_chat(user, span_warning("Holy energies block your path!"))
		return MOVE_NOT_ALLOWED
	return MOVE_ALLOWED

#undef DEFER_MOVE
#undef MOVE_ALLOWED
#undef MOVE_NOT_ALLOWED
