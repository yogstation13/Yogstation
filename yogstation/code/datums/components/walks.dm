#define DEFER_MOVE 1 //Let /client/Move() handle the movement
#define MOVE_ALLOWED 2 //Allow mob to pass through
#define MOVE_NOT_ALLOWED 3 //Do not let the mob through

/datum/component/walk
/datum/component/walk/Initialize()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_PROCESS_MOVE, .proc/handle_move)

/datum/component/walk/proc/handle_move(direction)
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
			L.forceMove(T)
			return TRUE

/datum/component/walk/proc/can_walk(mob/living/user, turf/destination)
	return MOVE_ALLOWED

/datum/component/walk/shadow
/datum/component/walk/shadow/can_walk(mob/living/user, turf/destination)
	return (destination.get_lumcount() ? DEFER_MOVE : MOVE_ALLOWED)

/datum/component/walk/jaunt
/datum/component/walk/jaunt/can_walk(mob/living/user, turf/destination)
	for(var/obj/effect/decal/cleanable/salt/S in destination)
		to_chat(user, "<span class='warning'>[S] bars your passage!</span>")
		if(isrevenant(user))
			var/mob/living/simple_animal/revenant/R = user
			R.reveal(20)
			R.stun(20)
		return MOVE_NOT_ALLOWED
	if(destination.flags_1 & NOJAUNT_1)
		to_chat(user, "<span class='warning'>Some strange aura is blocking the way.</span>")
		return MOVE_NOT_ALLOWED
	if (locate(/obj/effect/blessing, destination))
		to_chat(user, "<span class='warning'>Holy energies block your path!</span>")
		return MOVE_NOT_ALLOWED
	return MOVE_ALLOWED

#undef DEFER_MOVE
#undef MOVE_ALLOWED
#nudef MOVE_NOT_ALLOWED