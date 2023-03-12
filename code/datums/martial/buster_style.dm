#define COOLDOWN_WIRE 5 SECONDS
#define COOLDOWN_MOP 4 SECONDS
#define COOLDOWN_GRAPPLE 3 SECONDS
#define COOLDOWN_SLAM 0.8 SECONDS


/datum/martial_art/buster_style
	name = "Buster Style"
	id = MARTIALART_BUSTERSTYLE
	no_guns = FALSE
	help_verb = /mob/living/carbon/human/proc/buster_style_help
	var/list/thrown = list()
	COOLDOWN_DECLARE(next_wire)
	COOLDOWN_DECLARE(next_mop)
	COOLDOWN_DECLARE(next_grapple)
	COOLDOWN_DECLARE(next_slam)
	var/old_density //so people grappling something arent pushed by it until it's thrown

//proc the moves will use for damage dealing

/datum/martial_art/buster_style/proc/grab(mob/living/user, mob/living/target, damage)
		var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
		var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

//animation procs

//knocking them down
/datum/martial_art/buster_style/proc/footsies(mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		animate(target, transform = matrix(90, MATRIX_ROTATE), time = 0 SECONDS, loop = 0)

//Check for if someone is allowed to be stood back up
/datum/martial_art/buster_style/proc/wakeup(mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		animate(target, transform = null, time = 0.4 SECONDS, loop = 0)

//proc for clearing the thrown list, mostly so the lob proc doesnt get triggered when it shouldn't
/datum/martial_art/buster_style/proc/drop(mob/living/target)
	for(var/atom/movable/K in thrown)
		thrown.Remove(K)

/datum/martial_art/buster_style/can_use(mob/living/carbon/human/H)
	var/obj/item/bodypart/r_arm/robot/buster/R = H.get_bodypart(BODY_ZONE_R_ARM)
	var/obj/item/bodypart/l_arm/robot/buster/L = H.get_bodypart(BODY_ZONE_L_ARM)
	if(H.restrained() || H.get_active_held_item() || HAS_TRAIT(H, TRAIT_PACIFISM) || !(H.mobility_flags & MOBILITY_STAND))
		for(var/atom/movable/K in thrown)
			thrown.Remove(K)
			walk(K,0)
			K.density = old_density
			animate(K, time = 0 SECONDS, pixel_y = 0)
		return FALSE
	if(L && R)
		if((L?.bodypart_disabled) && (R?.bodypart_disabled))
			to_chat(H, span_warning("The arms aren't in a functional state right now!"))
			return FALSE
		else
			return TRUE //still got the other arm to pop off with
	if(R)
		if(R?.bodypart_disabled)
			to_chat(H, span_warning("The right buster arm isn't in a functional state right now!"))
			return FALSE
	if(L)
		if(L?.bodypart_disabled)
			to_chat(H, span_warning("The left buster arm isn't in a functional state right now!"))
			return FALSE
	return ..()


/datum/martial_art/buster_style/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/A)
	if(!(can_use(H)))
		return
	H.face_atom(A) //for the sake of moves that care about user orientation like mop and slam
	if(H.a_intent == INTENT_DISARM)
		mop(H,A)
	if(H.a_intent == INTENT_HELP && (H==A))
		arm_wire(H)
	if(thrown.len > 0 && H.a_intent == INTENT_GRAB)
		if(get_turf(A) != get_turf(H))
			lob(H,A)
	if(!H.Adjacent(A) || H==A)
		return
	if(H.a_intent == INTENT_HARM && isliving(A))
		slam(H,A)
	if(H.a_intent == INTENT_GRAB)
		grapple(H,A)

/datum/martial_art/buster_style/harm_act(mob/living/carbon/human/A, mob/living/D)
	return TRUE // no punching plus slamming please


/*---------------------------------------------------------------
	start of wire section 
---------------------------------------------------------------*/

/datum/martial_art/buster_style/proc/arm_wire(mob/living/carbon/human/A)
	for(var/obj/item/gun/magic/wire/J in A)
		qdel(J)
		to_chat(A, span_notice("The wire returns into your wrist."))
		return
	if(!COOLDOWN_FINISHED(src, next_wire)
		to_chat(A, span_warning("You can't do that yet!"))
		return
	COOLDOWN_START(src, next_wire, COOLDOWN_WIRE)
	var/obj/item/gun/magic/wire/gun = new /obj/item/gun/magic/wire (A)
	A.put_in_hands(gun)

/*---------------------------------------------------------------
	end of wire section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of grapple section
---------------------------------------------------------------*/

/datum/martial_art/buster_style/proc/grapple(mob/living/user, atom/target) //proc for picking something up to toss
	var/turf/Z = get_turf(user)
	target.add_fingerprint(user, FALSE)
	if(next_grapple > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	if(target == user)
		return
	if(isopenturf(target))
		return
	if(iswallturf(target))
		return
	if(isitem(target))
		return
	if(iseffect(target))
		return
	playsound(user, 'sound/effects/servostep.ogg', 60, FALSE, -1)
	if(isstructure(target) || ismachinery(target) || ismecha(target))
		var/obj/I = target
		old_density = I.density
		if(istype(I, /obj/mecha)) // Can pick up mechs
			I.anchored = FALSE
		if(I.anchored == TRUE) // Cannot pick up anchored structures
			if(istype(I, /obj/machinery/vending)) // Can pick up vending machines, even if anchored
				I.anchored = FALSE
				I.visible_message(span_warning("[user] grabs [I] and tears it off the bolts securing it!"))
			else
				return
		if(user in I.contents)
			to_chat(user, span_warning("You can't throw something while you're inside of it!")) //as funny as throwing lockers from the inside is i dont think i can get away with it
			return
		next_grapple = world.time + COOLDOWN_GRAPPLE
		user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
		I.visible_message(span_warning("[user] grabs [I] and lifts it above [user.p_their()] head!"))
		animate(I, time = 0.2 SECONDS, pixel_y = 20)
		I.forceMove(Z)
		I.density = FALSE 
		walk_towards(I, user, 0, 1)
		// Reset the item to its original state
		if(get_dist(I, user) > 2)
			I.density = old_density
		thrown |= I // Mark the item for throwing
		if(istype(I, /obj/mecha))
			I.anchored = TRUE
	if(isliving(target))
		var/mob/living/L = target
		var/obj/structure/bed/grip/F = new(Z, user) // Buckles them to an invisible bed
		next_grapple = world.time + COOLDOWN_GRAPPLE
		user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
		old_density = L.density // for the sake of noncarbons not playing nice with lying down
		L.density = FALSE
		L.visible_message(span_warning("[user] grabs [L] and lifts [L.p_them()] off the ground!"))
		L.Stun(10) //so the user has time to aim their throw
		to_chat(L, span_userdanger("[user] grapples you and lifts you up into the air! Resist [user.p_their()] grip!"))
		L.forceMove(Z)
		F.buckle_mob(target)
		walk_towards(F, user, 0, 1)
		if(get_dist(L, user) > 1)
			L.density = old_density
			return
		thrown |= L // Marks the mob to throw
		return


/datum/martial_art/buster_style/proc/lob(mob/living/user, atom/target) //proc for throwing something you picked up with grapple
	var/slamdam = 7
	var/objdam = 50
	var/throwdam = 15
	var/target_dist = get_dist(user, target)
	var/turf/D = get_turf(target)	
	var/atom/tossed = thrown[1]
	walk(tossed,0)
	tossed.density = old_density
	for(var/obj/I in thrown)
		animate(I, time = 0.2 SECONDS, pixel_y = 0) //to get it back to normal since it was lifted before
	if(get_dist(tossed, user) > 1)//cant reach the thing i was supposed to be throwing anymore
		drop()
		return
	if(user in tossed.contents)
		to_chat(user, span_warning("You can't throw something while you're inside of it!"))
		return
	user.visible_message(span_warning("[user] throws [tossed]!"))
	if(iscarbon(tossed)) // Logic that tears off a damaged limb or tail
		var/mob/living/carbon/tossedliving = thrown[1]
		var/obj/item/bodypart/limb_to_hit = tossedliving.get_bodypart(user.zone_selected)
		grab(user, tossedliving, throwdam) // Apply damage
		if(!limb_to_hit)
			limb_to_hit = tossedliving.get_bodypart(BODY_ZONE_CHEST)
		if(limb_to_hit.brute_dam == limb_to_hit.max_damage)
			if(!istype(limb_to_hit, /obj/item/bodypart/chest))
				to_chat(tossedliving, span_userdanger("[user] tears [limb_to_hit] off!"))
				playsound(user,'sound/misc/desceration-01.ogg', 20, 1)
				tossedliving.visible_message(span_warning("[user] throws [tossedliving] by [limb_to_hit], severing it from [tossedliving.p_them()]!"))
				limb_to_hit.drop_limb()
				user.put_in_hands(limb_to_hit)
		if(limb_to_hit == tossedliving.get_bodypart(BODY_ZONE_PRECISE_GROIN)) //targetting the chest works for tail removal too but who cares
			var/obj/item/organ/T = tossedliving.getorgan(/obj/item/organ/tail)
			if(T && limb_to_hit.brute_dam >= 50)
				to_chat(tossedliving, span_userdanger("[user] tears your tail off!"))
				playsound(user,'sound/misc/desceration-02.ogg', 20, 1)
				tossedliving.visible_message(span_warning("[user] throws [tossedliving] by [tossedliving.p_their()] tail, severing [tossedliving.p_them()] from it!")) //"I'm taking this back."
				T.Remove(tossedliving)
				user.put_in_hands(T)
	for(var/i = 1 to target_dist)
		var/dir_to_target = get_dir(get_turf(tossed), D) //vars that let the thing be thrown while moving similar to things thrown normally
		var/turf/T = get_step(get_turf(tossed), dir_to_target)
		if(T.density) // crash into a wall and damage everything flying towards it before stopping 
			for(var/mob/living/S in thrown)
				grab(user, S, slamdam) 
				S.Knockdown(1.5 SECONDS)
				S.Immobilize(1.5 SECONDS)
				if(isanimal(S) && S.stat == DEAD)
					S.gib()	
			for(var/obj/O in thrown)
				O.take_damage(objdam) 
				target.visible_message(span_warning("[O] collides with [T]!"))
			drop()
			return
		for(var/obj/Z in T.contents) // crash into something solid and damage it along with thrown objects that hit it
			for(var/obj/O in thrown) 
				if(Z.density == TRUE) 
					O.take_damage(objdam) 
					if(istype(O, /obj/mecha)) // mechs are probably heavy as hell so stop flying after making contact with resistance
						thrown -= O
			if(Z.density == TRUE && Z.anchored == FALSE) // if the thing hit isn't anchored it starts flying too
				thrown |= Z 
				Z.take_damage(50) 
			if(Z.density == TRUE && Z.anchored == TRUE) // If the thing is solid and anchored like a window or grille or table it hurts people thrown that crash into it too
				for(var/mob/living/S in thrown) 
					grab(user, S, slamdam) 
					S.Knockdown(1.5 SECONDS)
					S.Immobilize(1.5 SECONDS)
					if(isanimal(S) && S.stat == DEAD)
						S.gib()
					if(istype(Z, /obj/machinery/disposal/bin)) // dumpster living things tossed into the trash
						var/obj/machinery/disposal/bin/dumpster = D
						S.forceMove(Z)
						Z.visible_message(span_warning("[S] is thrown down the trash chute!"))
						dumpster.do_flush()
						drop()
						return
				Z.take_damage(objdam)
				if(Z.density == TRUE && Z.anchored == TRUE)
					drop()
					return // if the solid thing we hit doesnt break then the thrown thing is stopped
		for(var/mob/living/M in T.contents) // if the thrown mass hits a person then they get tossed and hurt too along with people in the thrown mass
			if(user != M)
				grab(user, M, slamdam) 
				M.Knockdown(1.5 SECONDS) 
				for(var/mob/living/S in thrown)
					grab(user, S, slamdam) 
					S.Knockdown(1 SECONDS) 
				thrown |= M 
			for(var/obj/O in thrown)
				O.take_damage(objdam) // Damage all thrown objects
		if(T) // if the next tile wont stop the thrown mass from continuing
			for(var/mob/living/S in thrown)
				S.Knockdown(1.5 SECONDS)
				S.Immobilize(1.5 SECONDS)
			for(var/atom/movable/K in thrown) // to make the mess of things that's being thrown almost look like a normal throw
				K.SpinAnimation(0.2 SECONDS, 1) 
				sleep(0.001 SECONDS)
				K.forceMove(T)
				if(istype(T, /turf/open/space)) // throw them like normal if it's into space
					var/atom/throw_target = get_edge_target_turf(K, dir_to_target)
					K.throw_at(throw_target, 6, 4, user, 3)
					thrown.Remove(K)
	drop()
	return

/*---------------------------------------------------------------
	end of grapple section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of mop section
---------------------------------------------------------------*/

/datum/martial_art/buster_style/proc/mop(mob/living/user)
	var/jumpdistance = 5
	var/dragdam = 8
	var/crashdam = 10
	var/mob/living/B = user
	var/turf/T = get_step(get_turf(B), B.dir)
	var/turf/Z = get_turf(B)
	var/list/mopped = list()
	if(next_mop > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	var/obj/effect/temp_visual/decoy/fading/threesecond/F = new(Z, B)
	B.visible_message(span_warning("[B] sprints forward with [B.p_their()] hand outstretched!"))
	next_mop = world.time + COOLDOWN_MOP
	playsound(B,'sound/effects/gravhit.ogg', 20, 1)
	B.Immobilize(0.1 SECONDS) //so they dont skip through the target
	for(var/i = 1 to jumpdistance)
		if(T.density) // If we're about to hit a wall, stop
			return
		for(var/obj/object in T.contents) // If we're about to hit a table or something that isn't destroyed, stop
			if(object.density == TRUE)
				return
		if(T)
			sleep(0.01 SECONDS)
			B.forceMove(T) // Move us forward
			walk_towards(F, B, 0, 1.5)
			animate(F, alpha = 0, color = "#d40a0a", time = 0.5 SECONDS) // Cool after-image
			for(var/mob/living/L in T.contents) // Take all mobs we encounter with us
				if(L != B) 
					B.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
					mopped |= L // Add them to the list of things we are mopping
					L.add_fingerprint(B, FALSE)
					var/turf/Q = get_step(get_turf(B), B.dir) // get the turf behind the thing we're attacking
					to_chat(L, span_userdanger("[B] grinds you against the ground!"))
					footsies(L)
					if(istype(T, /turf/open/space)) // If we're about to hit space, throw the first mob into space
						var/atom/throw_target = get_edge_target_turf(L, B.dir)
						wakeup(L)
						L.throw_at(throw_target, 2, 4, B, 3) // throwing them outside
					if(Q.density) // If we're about to hit a wall
						wakeup(L)
						grab(B, L, crashdam) 
						B.visible_message(span_warning("[B] rams [L] into [Q]!"))
						to_chat(L, span_userdanger("[B] rams you into [Q]!"))
						L.Knockdown(1 SECONDS)
						L.Immobilize(1.5 SECONDS)
						return // Then stop here
					for(var/obj/D in Q.contents) // If we're about to hit a dense object like a table or window
						wakeup(L)
						if(D.density == TRUE)
							grab(B, L, crashdam) 
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
					grab(B, L, dragdam) 
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(B, B.dir) // Move our goalpost forward one
	for(var/mob/living/C in mopped) // Return everyone to standing if they should be
		wakeup(C)

/*---------------------------------------------------------------
	end of mop section
---------------------------------------------------------------*/

/*---------------------------------------------------------------
	start of slam section
---------------------------------------------------------------*/

/datum/martial_art/buster_style/proc/slam(mob/living/user, mob/living/target)
	var/supdam = 20
	var/crashdam = 10
	var/walldam = 30
	var/mob/living/B = user
	var/mob/living/L = target
	var/turf/Z = get_turf(B)
	if(next_slam > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	next_slam = world.time + COOLDOWN_SLAM
	B.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
	var/turf/Q = get_step(get_turf(B), turn(B.dir,180)) // Get the turf behind us
	if(Q.density) // If there's a wall behind us
		var/turf/closed/wall/W = Q
		grab(B, L, walldam) 
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
				B.visible_message(span_warning("[L] is thrown down the trash chute!"))
				return // Stop here
			B.visible_message(span_warning("[B] turns around and slams [L] against [D]!"))
			D.take_damage(400) // Heavily damage and hopefully break the object
			grab(B, L, crashdam) 
			footsies(L)
			if(isanimal(L) && L.stat == DEAD)
				L.visible_message(span_warning("[L] explodes into gore on impact!"))
				L.gib()
			sleep(0.2 SECONDS)
			wakeup(L)
	for(var/mob/living/M in Q.contents) // If there's mobs behind us, apply damage to the mob for each one they are slammed into
		grab(B, L, crashdam) // Apply damage to the target
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
		var/atom/throw_target = get_edge_target_turf(L, user.dir)
		L.throw_at(throw_target, 2, 4, B, 3)
		B.visible_message(span_warning("[B] throws [L] behind [B.p_them()]!"))
		return
	playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
	playsound(B, 'sound/effects/gravhit.ogg', 20, 1)
	to_chat(L, span_userdanger("[B] catches you with [B.p_their()] hand and crushes you on the ground!"))
	B.visible_message(span_warning("[B] turns around and slams [L] against the ground!"))
	B.setDir(turn(B.dir, 180))
	grab(B, L, supdam) // Apply damage for the slam itself, independent of whether anything was hit
	footsies(L)
	if(isanimal(L) && L.stat == DEAD)
		L.visible_message(span_warning("[L] explodes into gore on impact!"))
		L.gib()
	sleep(0.2 SECONDS)
	wakeup(L)

/*---------------------------------------------------------------
	end of slam section
---------------------------------------------------------------*/


/*---------------------------------------------------------------
	training related section
---------------------------------------------------------------*/
/mob/living/carbon/human/proc/buster_style_help()
	set name = "Buster Style"
	set desc = "You mentally practice the stunts you can pull with the buster arm."
	set category = "Buster Style"

	to_chat(usr, "<b><i>You think about what stunts you can pull with the power of a buster arm.</i></b>")

	to_chat(usr, "[span_notice("Wire Snatch")]:By targetting yourself with help intent, you equip a grappling wire which can be used to move yourself or other objects. Landing a \
	shot on a person will immobilize them for 2 seconds. Facing an immediate solid object will slam them into it, damaging both of them. Extending the wire has a 5 second cooldown.")

	to_chat(usr, "[span_notice("Mop the Floor")]: Your disarm has been replaced with a move that sends you flying forward, damaging enemies in front of you by dragging them \
	along the ground. Ramming victims into something solid does damage to them and the object. Has a 4 second cooldown.")

	to_chat(usr, "[span_notice("Slam")]: Your harm has been replaced with a slam attack that places enemies behind you and smashes them against \
	whatever person, wall, or object is there for bonus damage. Has a 0.8 second cooldown.")
	
	to_chat(usr, "[span_notice("Grapple")]: Your grab has been amplified, allowing you to take a target object or being into your hand for up to 10 seconds and throw them at a \
	target destination by clicking again with grab intent. Throwing them into unanchored people and objects will knock them back and deal additional damage to existing thrown \
	targets. Mechs and vending machines can be tossed as well. If the target's limb is at its limit, tear it off. Has a 3 second cooldown")

	to_chat(usr, "[span_notice("Megabuster")]: Charge up your buster arm to put a powerful attack in the corresponding hand. The energy only lasts 5 seconds \
	but does hefty damage to its target, even breaking walls down when hitting things into them or connecting the attack directly. Landing the attack on a reinforced wall \
	destroys it but uses up the attack. Attacking a living target uses up the attack and sends them flying and dismembers their limb if its damaged enough. Has a 15 second \
	cooldown.")

	to_chat(usr, span_warning("You can't perform any of the moves besides megabuster if you're lying down or have an occupied hand. Additionally, if your buster arm should become \
	disabled, so shall your moves."))

	to_chat(usr, span_notice("<b>After landing an attack, you become resistant to damage slowdown and all incoming damage by 65% for 2 seconds.</b>"))

/datum/martial_art/buster_style/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	usr.click_intercept = src 

/datum/martial_art/buster_style/on_remove(mob/living/carbon/human/H)
	..()
	usr.click_intercept = null 
