/* Formatting for these files, from top to bottom:
	* Spell/Action
	* Trigger()
	* IsAvailable()
	* Items
	In regards to spells or items with left and right subtypes, list the base, then left, then right.
*/
////////////////// Spell //////////////////
/datum/action/cooldown/buster/slam
	name = "Slam"
	desc = "Grab the target in front of you and slam them back onto the ground. If there's a solid \
			object or wall behind you when the move is successfully performed then it will \
			take substantial damage."
	button_icon_state = "suplex"
	cooldown_time = 0.7 SECONDS
	var/supdam = 25
	var/crashdam = 10
	var/walldam = 30

/// Takes the mob directly in front of you, attempts to smash whatever is behind you, and then tries to put them behind you
/datum/action/cooldown/buster/slam/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/turf/T = get_step(get_turf(owner), owner.dir)
	var/turf/Z = get_turf(owner)
	owner.visible_message(span_warning("[owner] outstretches [owner.p_their()] arm and goes for a grab!"))
	for(var/mob/living/L in T.contents) // If there's a mob in front of us, note that this will return on the first mob it finds
		var/turf/Q = get_step(get_turf(owner), turn(owner.dir,180)) // Get the turf behind us
		if(Q.density) // If there's a wall behind us
			var/turf/closed/wall/W = Q
			grab(owner, L, walldam) // Apply damage to mob
			if(L.stat == CONSCIOUS && L.resting == FALSE)
				animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
			if(isanimal(L) && L.stat == DEAD)
				L.visible_message(span_warning("[L] explodes into gore on impact!"))
				L.gib()
			if(L.stat == CONSCIOUS && L.resting == FALSE)
				animate(L, transform = null, time = 0.2 SECONDS, loop = 0)
			to_chat(owner, span_warning("[owner] turns around and slams [L] against [Q]!"))
			to_chat(L, span_userdanger("[owner] crushes you against [Q]!"))
			playsound(L, 'sound/effects/meteorimpact.ogg', 60, 1)
			playsound(owner, 'sound/effects/gravhit.ogg', 20, 1)
			if(!istype(W, /turf/closed/wall/r_wall)) // Attempt to destroy the wall
				W.dismantle_wall(1)
				L.forceMove(Q) // Move the mob behind us
			else		
				L.forceMove(Z) // If we couldn't smash the wall, put them under our tile
			return // Stop here, don't apply any more damage or checks
		for(var/obj/D in Q.contents) // If there's dense objects behind us, apply damage to the mob for each one they are slammed into
			if(D.density == TRUE) // If it's a dense object like a window or table, otherwise skip
				if(istype(D, /obj/machinery/disposal/bin)) // Flush them down disposals
					var/obj/machinery/disposal/bin/dumpster = D
					L.forceMove(D)
					dumpster.do_flush()
					to_chat(L, span_userdanger("[owner] throws you down disposals!"))
					target.visible_message(span_warning("[L] is thrown down the trash chute!"))
					return // Stop here
				owner.visible_message(span_warning("[owner] turns around and slams [L] against [D]!"))
				D.take_damage(400) // Heavily damage and hopefully break the object
				grab(owner, L, crashdam) // Apply light damage to mob
				if(L.stat == CONSCIOUS && L.resting == FALSE)
					animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
				if(isanimal(L) && L.stat == DEAD)
					L.visible_message(span_warning("[L] explodes into gore on impact!"))
					L.gib()
				sleep(0.2 SECONDS)
				if(L.stat == CONSCIOUS && L.resting == FALSE)
					animate(L, transform = null, time = 0.2 SECONDS, loop = 0)
		for(var/mob/living/M in Q.contents) // If there's mobs behind us, apply damage to the mob for each one they are slammed into
			grab(owner, L, crashdam) // Apply damage to slammed mob
			if(L.stat == CONSCIOUS && L.resting == FALSE)
				animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
			if(isanimal(L) && L.stat == DEAD)
				L.visible_message(span_warning("[L] explodes into gore on impact!"))
				L.gib()
			sleep(0.2 SECONDS)
			if(L.stat == CONSCIOUS && L.resting == FALSE)
				animate(L, transform = null, time = 0.2 SECONDS, loop = 0)
			to_chat(L, span_userdanger("[owner] throws you into [M]"))
			to_chat(M, span_userdanger("[owner] throws [L] into you!"))
			owner.visible_message(span_warning("[L] slams into [M]!"))
			grab(owner, M, crashdam) // Apply damage to mob that was behind us
		L.forceMove(Q) // Move the mob behind us
		if(istype(Q, /turf/open/space)) // If they got slammed into space, throw them into deep space
			owner.setDir(turn(owner.dir,180))
			var/atom/throw_target = get_edge_target_turf(L, owner.dir)
			L.throw_at(throw_target, 2, 4, owner, 3)
			owner.visible_message(span_warning("[owner] throws [L] behind [owner.p_them()]!"))
			return
		playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
		playsound(owner, 'sound/effects/gravhit.ogg', 20, 1)
		to_chat(L, span_userdanger("[owner] catches you with [owner.p_their()] hand and crushes you on the ground!"))
		owner.visible_message(span_warning("[owner] turns around and slams [L] against the ground!"))
		owner.setDir(turn(owner.dir, 180))
		grab(owner, L, supdam) // Apply damage for the suplex itself, independent of whether anything was hit
		if(L.stat == CONSCIOUS && L.resting == FALSE)
			animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
		if(isanimal(L) && L.stat == DEAD)
			L.visible_message(span_warning("[L] explodes into gore on impact!"))
			L.gib()
		sleep(0.2 SECONDS)
		if(L.stat == CONSCIOUS && L.resting == FALSE)
			animate(L, transform = null, time = 0.2 SECONDS, loop = 0)

/datum/action/cooldown/buster/slam/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/slam/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
