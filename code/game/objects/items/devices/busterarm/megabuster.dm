/* Formatting for these files, from top to bottom:
	* Spell/Action
	* Trigger()
	* IsAvailable()
	* Items
	In regards to spells or items with left and right subtypes, list the base, then left, then right.
*/
////////////////// Spell //////////////////
/datum/action/cooldown/buster/megabuster
	name = "Mega Buster"
	// Literal essay. It just punches shit really hard.
	desc = "Put the buster arm through its paces to gain extreme power for five seconds. Connecting the blow will \
			devastate the target and send them flying. Flying targets will have a snowball effect on hitting other \
			unanchored people or objects collided with. Punching a mangled limb will instead send it flying and \
			momentarily stun its owner. Once the five seconds are up or a strong wall or person or exosuit is hit, \
			the arm won't be able to do that again for 20 seconds."
	button_icon_state = "ponch"
	cooldown_time = 20 SECONDS

/// Left buster-arm means megabuster goes in left hand
/datum/action/cooldown/buster/megabuster/l/Trigger()
	if(!..())
		return FALSE
	var/obj/item/buster/megabuster/B = new()
	owner.visible_message(span_userdanger("[owner]'s left arm begins crackling loudly!"))
	playsound(owner,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	if(do_after(owner, 2 SECONDS, owner, TRUE, stayStill = FALSE))
		if(!owner.put_in_l_hand(B))
			to_chat(owner, span_warning("You can't do this with your left hand full!"))
		else
			owner.visible_message(span_danger("[owner]'s arm begins shaking violently!"))
			if(owner.active_hand_index % 2 == 0)
				owner.swap_hand(0)
			StartCooldown()

/// Right buster-arm means megabuster goes in right hand
/datum/action/cooldown/buster/megabuster/r/Trigger()
	if(!..())
		return FALSE
	var/obj/item/buster/megabuster/B = new()
	owner.visible_message(span_userdanger("[owner]'s right arm begins crackling loudly!"))
	playsound(owner,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	if(do_after(owner, 2 SECONDS, owner, TRUE, stayStill = FALSE))
		if(!owner.put_in_r_hand(B))
			to_chat(owner, span_warning("You can't do this with your right hand full!"))
		else
			owner.visible_message(span_danger("[owner]'s arm begins shaking violently!"))
			if(owner.active_hand_index % 2 == 1)
				owner.swap_hand(0)
			StartCooldown()

/datum/action/cooldown/buster/megabuster/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/megabuster/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

////////////////// Megabuster Item //////////////////
/obj/item/buster/megabuster
	name = "supercharged emitter"
	desc = "The result of all the prosthetic's power building up in its palm. It's fading fast."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "fist"
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	var/flightdist = 8
	var/punchdam = 30
	var/colldam = 20
	var/mechdam = 150
	var/objdam = 400
	var/objcolldam = 120
	var/hitobjdam = 10

/// Lights cigarettes
/obj/item/buster/megabuster/ignition_effect(atom/A, mob/user)
	playsound(user,'sound/misc/fingersnap1.ogg', 20, 1)
	playsound(user,'sound/effects/sparks4.ogg', 20, 1)
	do_sparks(5, TRUE, src)
	. = span_rose("With a single snap, [user] sets [A] alight with sparks from [user.p_their()] metal fingers.")

/// Only lasts 5 seconds, fades out
/obj/item/buster/megabuster/Initialize(mob/living/user)
	. = ..()
	animate(src, alpha = 50, time = 5 SECONDS)
	QDEL_IN(src, 5 SECONDS)

/// Punch logic
/// Stuff that you can do multiple times:
/// 	Destroy walls
/// 	Harm and throw structures
/// 	Harm items
/// Stuff that you can do ONCE and then it self-deletes:
/// 	Destroy r-walls
/// 	Harm mechs
/// 	Harm and throw mobs
/obj/item/buster/megabuster/afterattack(atom/target, mob/living/user, proximity)
	var/direction = user.dir
	var/list/knockedback = list()
	var/mob/living/L = target

	// Sanity
	if(!proximity)
		return
	if(target == user)
		return
	
	// Punch items, if you wanted to do that for some reason. Can't destroy brains though.
	if(isitem(target))
		var/obj/I = target
		if(!isturf(I.loc))
			if(!istype(I, /obj/item/clothing/mask/cigarette))
				to_chat(user, span_warning("You probably shouldn't attack something on your person."))
			return
		if(!istype(I, /obj/item/organ/brain) && !istype(I, /obj/item/clothing/mask/cigarette))
			I.take_damage(objdam)
			user.visible_message(span_warning("[user] pulverizes [I]!"))
		return
	
	// Punch open turf (does nothing)
	if(isopenturf(target))
		return

	playsound(L, 'sound/effects/gravhit.ogg', 60, 1)
	if(iswallturf(target)) // Destroys a wall
		var/turf/closed/wall/W = target
		if(istype(W, /turf/closed/wall/r_wall))
			W.dismantle_wall(1)
			qdel(src) // Destroying reinforced walls will instantly start cooldown
		else
			W.dismantle_wall(1)
		user.visible_message(span_warning("[user] demolishes [W]!"))
		return
	
	if(ismecha(target)) // Do good damage to a mech 
		var/obj/mecha/A = target
		A.take_damage(mechdam) // Apply damage
		user.visible_message(span_warning("[user] crushes [target]!"))
		qdel(src) // Hitting mechs will instantly start cooldown
	
	if(isstructure(target) || ismachinery(target)) // Do big damage to anchored objects, or less to unanchored, but throw them
		user.visible_message(span_warning("[user] strikes [target]!"))
		var/obj/I = target
		if(I.anchored == TRUE)
			I.take_damage(objdam)
			return // Stop here
		I.take_damage(50) // If not anchored, do less damage
		knockedback |= I // and then throw it backwards
		if(QDELETED(I)) // If it was destroyed by the damage, don't try to throw it
			return
	
	if(isliving(L)) // Punching a mob
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(user.zone_selected)
		var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		qdel(src, force = TRUE) // Punching mobs instantly starts the cooldown
		shake_camera(L, 4, 3) // Shake their camera
		L.apply_damage(punchdam, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND) // Apply damage to mob
		if(!limb_to_hit)
			limb_to_hit = L.get_bodypart(BODY_ZONE_CHEST)
		if(iscarbon(L))
			if(limb_to_hit.brute_dam == limb_to_hit.max_damage) // If the limb is destroyed
				if(istype(limb_to_hit, /obj/item/bodypart/chest))
					knockedback |= L // You can't toss off their torso.
				else // If you target a limb and it's fully damaged then lop it off
					var/atom/throw_target = get_edge_target_turf(L, direction)
					to_chat(L, span_userdanger("[user] blows [limb_to_hit] off with inhuman force!"))
					user.visible_message(span_warning("[user] punches [L]'s [limb_to_hit] clean off!"))
					limb_to_hit.drop_limb()
					limb_to_hit.throw_at(throw_target, 8, 4, user, 3)
					L.Paralyze(3 SECONDS)
					return // Stop here, don't bother throwing
		L.SpinAnimation(0.5 SECONDS, 2)
		to_chat(L, span_userdanger("[user] hits you with a blast of energy and sends you flying!"))
		user.visible_message(span_warning("[user] blasts [L] with a surge of energy and sends [L.p_them()] flying!"))
		knockedback |= L
	// Shake cameras Woosh
	for(var/mob/M in view(7, user))
		shake_camera(M, 2, 3)
	var/turf/P = get_turf(user)
	// Introducing: snowflake throw logic
	// Like grapple, but much stronger
	// Damages most structures and walls it comes in contact with
	// Applies damage to the victim depending on what they hit, if anything
	for(var/i = 2 to flightdist) // For each tile they are thrown
		var/turf/T = get_ranged_target_turf(P, direction, i)
		if(T.density) // Ouch, we hit a wall!
			var/turf/closed/wall/W = T
			for(var/obj/J in knockedback) // For every object that is flying, damage it again
				J.take_damage(objcolldam)
			for(var/mob/living/S in knockedback) // For every mob that is flying, damage them again
				hit(user, S, colldam)
				if(isanimal(S) && S.stat == DEAD)
					S.gib()
			if(!istype(W, /turf/closed/wall/r_wall)) // Destroy the wall if it's not a reinforced wall
				playsound(L,'sound/effects/meteorimpact.ogg', 50, 1)
				W.dismantle_wall(1)
			else
				return // We can't destroy rwalls, stop!
		for(var/obj/D in T.contents)
			if(D.density == TRUE) // Ouch, we hit a dense object like a window or table!
				for(var/obj/J in knockedback) // For every object that is flying, damage it again
					J.take_damage(objcolldam)
				for(var/mob/living/S in knockedback) // For every mob that is flying, damage them again
					hit(user, S, hitobjdam)
				if(D.anchored == FALSE) // If the object is unanchored, take it with us
					knockedback |= D
					D.take_damage(50)
				if(D.anchored == TRUE) // If the object is anchored, damage it
					D.take_damage(objdam)
					if(D.density == TRUE) // If the object is still dense, stop!!!
						return
					for(var/mob/living/S in knockedback)
						hit(user, S, colldam)
						if(isanimal(S) && S.stat == DEAD)
							S.gib()		
		for(var/mob/living/M in T.contents) // For each mob we hit, damage our mobs, damage them, and take them with us
			hit(user, M, colldam)
			for(var/mob/living/S in knockedback)
				hit(user, S, colldam)
			knockedback |= M
		if(T)
			// Move us forward
			for(var/atom/movable/K in knockedback)
				K.SpinAnimation(0.2 SECONDS, 1)
				sleep(0.001 SECONDS)
				K.forceMove(T)
				if(istype(T, /turf/open/space)) // If we hit space, YEET
					var/atom/throw_target = get_edge_target_turf(K, direction)
					K.throw_at(throw_target, 6, 4, user, 3)
					return
