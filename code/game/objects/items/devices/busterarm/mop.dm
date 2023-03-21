/* Formatting for these files, from top to bottom:
	* Action
	* Trigger()
	* IsAvailable()
	* Items
	In regards to actions or items with left and right subtypes, list the base, then left, then right.
*/
////////////////// Action //////////////////
/datum/action/cooldown/buster/mop
	name = "Mop the Floor"
	desc = "Launch forward and drag whoever's in front of you on the ground. The \
			power of this move increases with closeness to the target upon using it."
	button_icon_state = "mop"
	cooldown_time = 4 SECONDS
	var/jumpdistance = 5
	var/dragdam = 8
	var/crashdam = 10

/// Mop the Floor: Launches the user forward some tiles, taking mobs with them and damaging those mobs
/datum/action/cooldown/buster/mop/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/mob/living/B = owner
	var/turf/T = get_step(get_turf(B), B.dir)
	var/turf/Z = get_turf(B)
	var/obj/effect/temp_visual/decoy/fading/threesecond/F = new(Z, B)
	var/list/mopped = list()
	B.visible_message(span_warning("[B] sprints forward with [B.p_their()] hand outstretched!"))
	playsound(B,'sound/effects/gravhit.ogg', 20, 1)
	B.Immobilize(0.1 SECONDS) //so they dont skip through the target
	for(var/i = 1 to jumpdistance)
		if(T.density) // If we're about to hit a wall, stop
			return
		for(var/obj/D in T.contents) // If we're about to hit a table or something that isn't destroyed, stop
			if(D.density == TRUE)
				return
		if(T)
			sleep(0.01 SECONDS)
			B.forceMove(T) // Move us forward
			walk_towards(F, owner, 0, 1.5)
			animate(F, alpha = 0, color = "#d40a0a", time = 0.5 SECONDS) // Cool after-image
			for(var/mob/living/L in T.contents) // Take all mobs we encounter with us
				if(L != B) // Don't want to mop ourselves haha
					B.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
					mopped |= L // Add them to the list of things we are mopping
					L.add_fingerprint(B, FALSE)
					var/turf/Q = get_step(get_turf(B), B.dir) // Get the turf ahead
					to_chat(L, span_userdanger("[B] grinds you against the ground!"))
					footsies(L)
					if(istype(T, /turf/open/space)) // If we're about to hit space, throw the first mob into space
						var/atom/throw_target = get_edge_target_turf(L, B.dir)
						wakeup(L)
						L.throw_at(throw_target, 2, 4, B, 3) // Yeet
						return // Then stop here
					if(Q.density) // If we're about to hit a wall
						wakeup(L)
						grab(B, L, crashdam) // Apply damage to mob
						B.visible_message(span_warning("[B] rams [L] into [Q]!"))
						to_chat(L, span_userdanger("[B] rams you into [Q]!"))
						L.Knockdown(1 SECONDS)
						L.Immobilize(1.5 SECONDS)
						return // Then stop here
					for(var/obj/D in Q.contents) // If we're about to hit a dense object like a table or window
						wakeup(L)
						if(D.density == TRUE)
							grab(B, L, crashdam) // Apply damage to mob
							B.visible_message(span_warning("[B] rams [L] into [D]!"))
							to_chat(L, span_userdanger("[B] rams you into [D]!"))
							D.take_damage(200) // Damage dense object
							L.Knockdown(1 SECONDS)
							L.Immobilize(1 SECONDS)
							if(D.density == TRUE) // If it wasn't destroyed, stop here
								return
					B.forceMove(get_turf(L)) // Move buster arm user (forward) on top of the mopped mob
					to_chat(L, span_userdanger("[B] catches you with [B.p_their()] hand and drags you down!"))
					B.visible_message(span_warning("[B] hits [L] and drags them through the dirt!"))
					L.forceMove(Q) // Move mopped mob forward
					grab(B, L, dragdam) // Apply damage to mopped mob
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(B, B.dir) // Move our goalpost forward one
	for(var/mob/living/C in mopped) // Return everyone to standing if they should be
		wakeup(C)

/datum/action/cooldown/buster/mop/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/mop/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
