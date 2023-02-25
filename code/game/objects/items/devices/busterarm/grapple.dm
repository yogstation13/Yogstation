/* Formatting for these files, from top to bottom:
	* Spell/Action
	* Trigger()
	* IsAvailable()
	* Items
	In regards to spells or items with left and right subtypes, list the base, then left, then right.
*/
////////////////// Spell //////////////////
/datum/action/cooldown/buster/grap
	name = "Grapple"
	desc = "Prepare your left hand for grabbing. Throw your target and inflict more damage \
			if they hit a solid object. If the targeted limb is horribly bruised, you'll \
			tear it off when throwing the victim."
	button_icon_state = "lariat"
	cooldown_time = 3 SECONDS

/// Left buster-arm means grapple goes in left hand
/datum/action/cooldown/buster/grap/l/Trigger()
	if(!..())
		return FALSE
	var/obj/item/buster/graphand/G = new()
	if(!owner.put_in_l_hand(G))
		to_chat(owner, span_warning("You can't do this with your left hand full!"))
	else
		StartCooldown()
		owner.visible_message(span_warning("The fingers on [owner]'s left buster arm begin to tense up."))
		owner.put_in_l_hand(G)
		if(owner.active_hand_index % 2 == 0)
			owner.swap_hand(0)

/// Right buster-arm means grapple goes in right hand
/datum/action/cooldown/buster/grap/r/Trigger()
	if(!..())
		return FALSE
	var/obj/item/buster/graphand/G = new()
	if(!owner.put_in_r_hand(G))
		to_chat(owner, span_warning("You can't do this with your right hand full!"))
	else
		owner.visible_message(span_warning("The fingers on [owner]'s right buster arm begin to tense up."))
		playsound(owner,'sound/effects/servostep.ogg', 60, 1)
		owner.put_in_r_hand(G)
		StartCooldown()
		if(owner.active_hand_index % 2 == 1)
			owner.swap_hand(0)

/datum/action/cooldown/buster/grap/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/grap/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

////////////////// Grapple Hand Item //////////////////
/// Grabs something and buckles it to you, then after a small bit throws it in the direction you're facing
/obj/item/buster/graphand
	name = "grapple"
	desc = "Your fingers occasionally curl as if they have their own urge to dig into something."
	color = "#f14b4b"
	var/throwdist = 5
	var/throwdam = 15
	var/slamdam = 7
	var/objdam = 50

/// Lights cigarettes
/obj/item/buster/graphand/ignition_effect(atom/A, mob/user)
	playsound(user,'sound/misc/fingersnap2.ogg', 20, 1)
	playsound(user,'sound/effects/sparks4.ogg', 20, 1)
	do_sparks(5, TRUE, src)
	. = span_rose("With a single snap, [user] sets [A] alight with sparks from [user.p_their()] metal fingers.")

/// Attacking (grabbing) someone with the hand
/obj/item/buster/graphand/afterattack(atom/target, mob/living/user, proximity)
	var/turf/Z = get_turf(user)
	var/list/thrown = list()
	var/side = user.get_held_index_of_item(src)
	target.add_fingerprint(user, FALSE)

	// Sanity checks
	if(!proximity)
		return
	if(target == user)
		return
	if(isfloorturf(target))
		return
	if(iswallturf(target))
		return
	if(isitem(target))
		return
	
	if(isstructure(target) || ismachinery(target) ||ismecha(target))
		var/obj/I = target
		var/old_density = I.density
		if(istype(I, /obj/mecha)) // Can pick up mechs
			I.anchored = FALSE
		if(I.anchored == TRUE) // Cannot pick up anchored structures
			if(istype(I, /obj/machinery/vending)) // Can pick up vending machines, even if anchored
				I.anchored = FALSE
				I.visible_message(span_warning("[user] grabs [I] and tears it off the bolts securing it!"))
			else
				return
		I.visible_message(span_warning("[user] grabs [I] and lifts it above [user.p_their()] head!"))
		qdel(src) // Remove the grapple hand so we cant carry several things at once
		animate(I, time = 0.2 SECONDS, pixel_y = 20)
		I.forceMove(Z)
		I.density = FALSE 
		walk_towards(I, user, 0, 2)
		sleep(2 SECONDS) // Wait 2 seconds
		// Reset the item to its original state
		if(get_dist(I, user) > 1)
			I.density = old_density
		walk(I,0)
		thrown |= I // Mark the item for throwing
		I.density = old_density
		if(istype(I, /obj/mecha))
			I.anchored = TRUE
		animate(I, time = 0.2 SECONDS, pixel_y = 0)
	if(isliving(target))
		var/mob/living/L = target
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(user.zone_selected)
		var/obj/structure/bed/grip/F = new(Z, user) // Buckles them to an invisible bed
		var/old_density = L.density // for the sake of noncarbons not playing nice with lying down
		L.density = FALSE
		qdel(src)
		to_chat(L, span_userdanger("[user] grapples you and lifts you up into the air!"))
		L.forceMove(Z)
		F.buckle_mob(target)
		walk_towards(F, user, 0, 2)
		sleep(1 SECONDS) // Wait only 1 second (Objects take 2 seconds to throw)
		if(get_dist(L, user) > 1)
			L.density = old_density
			return
		hit(user, L, throwdam) // Apply damage
		if(iscarbon(L)) // Logic that tears off a damaged limb or tail
			if(!limb_to_hit)
				limb_to_hit = L.get_bodypart(BODY_ZONE_CHEST)
			if(limb_to_hit.brute_dam == limb_to_hit.max_damage)
				if(istype(limb_to_hit, /obj/item/bodypart/chest))
					thrown |= L
				else
					to_chat(L, span_userdanger("[user] tears [limb_to_hit] off!"))
					playsound(user,'sound/misc/desceration-01.ogg', 20, 1)
					L.visible_message(span_warning("[user] throws [L], severing [limb_to_hit] from [L.p_them()]!"))
					limb_to_hit.drop_limb()
					if(side == LEFT_HANDS)
						user.put_in_l_hand(limb_to_hit)
					else
						user.put_in_r_hand(limb_to_hit)
			if(limb_to_hit == L.get_bodypart(BODY_ZONE_PRECISE_GROIN))
				var/obj/item/organ/T = L.getorgan(/obj/item/organ/tail)
				if(T && limb_to_hit.brute_dam >= 50)
					to_chat(L, span_userdanger("[user] tears your tail off!"))
					playsound(user,'sound/misc/desceration-02.ogg', 20, 1)
					L.visible_message(span_warning("[user] throws [L], severing [L.p_them()] from [L.p_their()] tail!")) //"I'm taking this back."
					T.Remove(L)
					if(side == LEFT_HANDS)
						user.put_in_l_hand(T)
					else
						user.put_in_r_hand(T)
			L.density = old_density
		thrown |= L // Marks the mob to throw
	
	// Throwing logic
	target.visible_message(span_warning("[user] throws [target]!"))
	var/direction = user.dir
	var/turf/P = get_turf(user)
	// Introducing: snowflake throw logic
	// Damages or pushes through structures it comes in contact with
	// Applies special damage and statuses to the victim depending on what they hit, if anything
	for(var/i = 1 to throwdist)
		var/turf/C = get_ranged_target_turf(P, direction, i)
		if(C.density) // Hit a wall
			for(var/mob/living/S in thrown)
				hit(user, S, slamdam) // Apply damage to mob thrown
				S.Knockdown(1.5 SECONDS)
				S.Immobilize(1.5 SECONDS)
				if(isanimal(S) && S.stat == DEAD)
					S.gib()	
			for(var/obj/O in thrown)
				O.take_damage(objdam) // Apply damage to object thrown
				target.visible_message(span_warning("[target] collides with [C]!"))
			return
		for(var/obj/D in C.contents) // Hit object(s)
			for(var/obj/O in thrown) // If the object we hit is also being thrown
				if(D.density == TRUE) // If the object is dense, like a window, table, or mech
					O.take_damage(objdam) // Apply damage to thrown&hit object
					if(istype(O, /obj/mecha)) // If mech is thrown&hit, stop throwing it
						thrown -= O
			if(D.density == TRUE && D.anchored == FALSE) // If it's dense but unanchored
				thrown |= D // Take it with us
				D.take_damage(50) // Damage it
			if(D.density == TRUE && D.anchored == TRUE) // If it's dense and anchored
				for(var/mob/living/S in thrown) // For all mobs being thrown
					hit(user, S, slamdam) // Apply damage to thrown mob
					S.Knockdown(1.5 SECONDS)
					S.Immobilize(1.5 SECONDS)
					if(isanimal(S) && S.stat == DEAD)
						S.gib()
					if(istype(D, /obj/machinery/disposal/bin)) // Toss them down disposals
						var/obj/machinery/disposal/bin/dumpster = D
						S.forceMove(D)
						D.visible_message(span_warning("[S] is thrown down the trash chute!"))
						dumpster.do_flush()
						return
				D.take_damage(objdam) // Damage the thing we hit
				if(D.density == TRUE)
					return // Stop here completely if it's still dense and not destroyed
		for(var/mob/living/M in C.contents) // Hit mob(s)
			hit(user, M, slamdam) // Apply damage to hit mob
			M.Knockdown(1.5 SECONDS) // Knockdown hit mob
			for(var/mob/living/S in thrown)
				hit(user, S, slamdam) // Apply damage to thrown mob
				S.Knockdown(1 SECONDS) // Knockdown thrown mob
			thrown |= M // Take them with us
			for(var/obj/O in thrown)
				O.take_damage(objdam) // Damage all thrown objects
		if(C) // Actual throw logic; throws us another tile
			for(var/atom/movable/K in thrown) // For all things that we are throwing
				K.SpinAnimation(0.2 SECONDS, 1) // The source of the spastic spins
				sleep(0.001 SECONDS) // Sleep for a frame
				K.forceMove(C) // Pretend to throw us by simply setting our location to the next tile
				if(istype(C, /turf/open/space)) // If we got thrown into space, rocket us off
					var/atom/throw_target = get_edge_target_turf(K, direction)
					K.throw_at(throw_target, 6, 4, user, 3) // Weeeeee

/// Invisible bed helper that buckles mobs to us
/obj/structure/bed/grip
	name = ""
	icon_state = ""
	can_buckle = TRUE
	density = FALSE

/obj/structure/bed/grip/Initialize()
	. = ..()
	QDEL_IN(src, 1.2 SECONDS)

/obj/structure/bed/grip/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(has_buckled_mobs())
		for(var/buckl in buckled_mobs)
			var/mob/living/M = buckl
			// Can't be accomplished under normal circumstances because it self deletes in 1.2 seconds
			if(!do_after(M, 2 SECONDS, src))
				if(M && M.buckled)
					to_chat(M, span_warning("You fail to free yourself!"))
				return
			if(!M.buckled)
				return
			unbuckle_mob(M)
			add_fingerprint(user)
