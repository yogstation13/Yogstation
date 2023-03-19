/* Formatting for these files, from top to bottom:
	* Action
	* Trigger()
	* IsAvailable()
	* Items
	In regards to actions or items with left and right subtypes, list the base, then left, then right.
*/
////////////////// Action //////////////////
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
	var/mob/living/B = owner
	B.visible_message(span_warning("[B] outstretches [B.p_their()] arm and goes for a grab!"))
	for(var/mob/living/L in T.contents) // If there's a mob in front of us, note that this will return on the first mob it finds
		B.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
		var/turf/Q = get_step(get_turf(B), turn(B.dir,180)) // Get the turf behind us
		if(Q.density) // If there's a wall behind us
			var/turf/closed/wall/W = Q
			grab(B, L, walldam) // Apply damage to mob
			footsies(L)
			if(isanimal(L) && L.stat == DEAD)
				L.visible_message(span_warning("[L] explodes into gore on impact!"))
				L.gib()
			wakeup(L)
			to_chat(B, span_warning("[B] turns around and slams [L] against [Q]!"))
			to_chat(L, span_userdanger("[B] crushes you against [Q]!"))
			playsound(L, 'sound/effects/meteorimpact.ogg', 60, 1)
			playsound(B, 'sound/effects/gravhit.ogg', 20, 1)
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
					to_chat(L, span_userdanger("[B] throws you down disposals!"))
					target.visible_message(span_warning("[L] is thrown down the trash chute!"))
					return // Stop here
				B.visible_message(span_warning("[B] turns around and slams [L] against [D]!"))
				D.take_damage(400) // Heavily damage and hopefully break the object
				grab(B, L, crashdam) // Apply light damage to mob
				footsies(L)
				if(isanimal(L) && L.stat == DEAD)
					L.visible_message(span_warning("[L] explodes into gore on impact!"))
					L.gib()
				sleep(0.2 SECONDS)
				wakeup(L)
		for(var/mob/living/M in Q.contents) // If there's mobs behind us, apply damage to the mob for each one they are slammed into
			grab(B, L, crashdam) // Apply damage to slammed mob
			footsies(L)
			if(isanimal(L) && L.stat == DEAD)
				L.visible_message(span_warning("[L] explodes into gore on impact!"))
				L.gib()
			sleep(0.2 SECONDS)
			wakeup(L)
			to_chat(L, span_userdanger("[B] throws you into [M]"))
			to_chat(M, span_userdanger("[B] throws [L] into you!"))
			B.visible_message(span_warning("[L] slams into [M]!"))
			grab(B, M, crashdam) // Apply damage to mob that was behind us
		L.forceMove(Q) // Move the mob behind us
		if(istype(Q, /turf/open/space)) // If they got slammed into space, throw them into deep space
			B.setDir(turn(B.dir,180))
			var/atom/throw_target = get_edge_target_turf(L, owner.dir)
			L.throw_at(throw_target, 2, 4, B, 3)
			B.visible_message(span_warning("[B] throws [L] behind [B.p_them()]!"))
			return
		playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
		playsound(B, 'sound/effects/gravhit.ogg', 20, 1)
		to_chat(L, span_userdanger("[B] catches you with [B.p_their()] hand and crushes you on the ground!"))
		B.visible_message(span_warning("[B] turns around and slams [L] against the ground!"))
		B.setDir(turn(B.dir, 180))
		grab(B, L, supdam) // Apply damage for the suplex itself, independent of whether anything was hit
		footsies(L)
		if(isanimal(L) && L.stat == DEAD)
			L.visible_message(span_warning("[L] explodes into gore on impact!"))
			L.gib()
		sleep(0.2 SECONDS)
		wakeup(L)
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
