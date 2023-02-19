/datum/action/cooldown/buster
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	transparent_when_unavailable = TRUE
	icon_icon = 'icons/mob/actions/actions_arm.dmi'

/datum/action/cooldown/buster/IsAvailable()
	. = ..()
	if(!isliving(owner))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_PACIFISM))
		return FALSE

//Separate isavailables so if someone is using two arms they won't care about the other

/datum/action/cooldown/buster/mop/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/slam/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/megabuster/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/wire_snatch/l/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	
/datum/action/cooldown/buster/grap/l/IsAvailable()
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

/datum/action/cooldown/buster/slam/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/megabuster/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE

/datum/action/cooldown/buster/wire_snatch/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	
/datum/action/cooldown/buster/grap/r/IsAvailable()
	. = ..()
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE



/obj/item/buster/proc/hit(mob/living/user, mob/living/target, damage)
		var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
		var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

/datum/action/cooldown/buster/proc/grab(mob/living/user, mob/living/target, damage)
		var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
		var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

/obj/item/buster
	item_flags = DROPDEL
	w_class = 5
	icon = 'icons/obj/wizard.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'

/obj/item/buster/Initialize(mob/living/user)
	. = ..()
	ADD_TRAIT(src, HAND_REPLACEMENT_TRAIT, NOBLUDGEON)


/datum/action/cooldown/buster/wire_snatch
	name = "Wire Snatch"
	desc = "Extend a wire for reeling in foes from a distance. Reeled in targets will be unable to walk for 1.5 seconds. Anchored targets that are hit will\
	pull you towards them instead. It can be used 3 times before reeling back into the arm."
	icon_icon = 'icons/obj/guns/magic.dmi'
	button_icon_state = "hook"
	cooldown_time = 5 SECONDS
	
/datum/action/cooldown/buster/wire_snatch/l/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/obj/item/gun/magic/wire/T = new()
	for(var/obj/item/gun/magic/wire/J in owner)
		qdel(J)
		to_chat(owner, span_notice("The wire returns into your wrist."))
		return
	if(!owner.put_in_r_hand(T))
		to_chat(owner, span_warning("You can't do this with your right hand full!"))
	else
		if(owner.active_hand_index % 2 == 1)
			owner.swap_hand(0) //making the grappling hook hand (right) the active one so using it is streamlined



/obj/item/gun/magic/wire/Initialize()
	. = ..()
	ADD_TRAIT(src, HAND_REPLACEMENT_TRAIT, NOBLUDGEON)
	if(ismob(loc))
		loc.visible_message(span_warning("A long cable comes out from [loc.name]'s arm!"), span_warning("You extend the breaker's wire from your arm."))

/obj/item/gun/magic/wire
	name = "grappling wire"
	desc = "A combat-ready cable usable for closing the distance, bringing you to walls and heavy targets you hit or bringing lighter ones to you."
	ammo_type = /obj/item/ammo_casing/magic/wire
	icon_state = "hook"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 3
	item_flags = NEEDS_PERMIT | DROPDEL
	force = 0
	can_charge = FALSE

/obj/item/ammo_casing/magic/wire
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/item/projectile/wire
	caliber = "hook"
	icon_state = "hook"

/obj/item/projectile/wire
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 0
	armour_penetration = 100
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/effects/splat.ogg'
	knockdown = 0
	var/wire

/obj/item/projectile/wire/fire(setAngle)
	if(firer)
		wire = firer.Beam(src, icon_state = "chain", time = INFINITY, maxdistance = INFINITY)
	..()
	
/obj/item/projectile/wire/proc/zip(mob/living/user, turf/open/target)
	to_chat(user, span_warning("You pull yourself towards [target]."))
	playsound(user, 'sound/magic/tail_swing.ogg', 10, TRUE)
	user.Immobilize(0.2 SECONDS)//so it's not cut short by walking
	user.throw_at(get_step_towards(target,user), 8, 4)

/obj/item/projectile/wire/on_hit(atom/target)
	var/mob/living/carbon/human/H = firer
	if(!H)
		return
	if(isobj(target))
		var/obj/item/I = target
		if(!I?.anchored)
			I.throw_at(get_step_towards(H,I), 8, 2)
			H.visible_message(span_danger("[I] is pulled by [H]'s wire!"))
			if(istype(I, /obj/item/clothing/head))
				H.equip_to_slot_if_possible(I, SLOT_HEAD)
				H.visible_message(span_danger("[H] pulls [I] onto [H.p_their()] head!"))
			else
				H.put_in_hands(I)
			return
		zip(H, target)
	if(isliving(target))
		var/mob/living/L = target
		var/turf/T = get_step(get_turf(H), H.dir)
		var/turf/Q = get_turf(H)
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(H.zone_selected)
		var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		if(!L.anchored)
			if(istype(H))
				L.visible_message(span_danger("[L] is pulled by [H]'s wire!"),span_userdanger("A wire grabs you and pulls you towards [H]!"))				
				L.Immobilize(1.5 SECONDS)
				if(prob(5))
					firer.say("GET OVER HERE!!")//slicer's request
				if(T.density)
					to_chat(H, span_warning("[H] catches [L] and throws [L.p_them()] against [T]!"))
					to_chat(L, span_userdanger("[H] crushes you against [T]!"))
					playsound(L,'sound/effects/pop_expl.ogg', 130, 1)
					L.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
					L.forceMove(Q)
					return
				for(var/obj/D in T.contents)
					if(D.density == TRUE)
						D.take_damage(50)	
						L.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
						L.forceMove(Q)
						to_chat(H, span_warning("[H] catches [L] throws [L.p_them()] against [D]!"))
						playsound(L,'sound/effects/pop_expl.ogg', 20, 1)
						return
				L.forceMove(T)
	if(iswallturf(target))
		var/turf/W = target
		zip(H, W)

/obj/item/gun/magic/wire/process_chamber()
	. = ..()
	if(!charges)
		qdel(src)

/obj/item/projectile/wire/Destroy()
	qdel(wire)
	return ..()


/datum/action/cooldown/buster/grap/l
	name = "Grapple"
	desc = "Prepare your left hand for grabbing. Throw your target and inflict more damage if they hit a solid object. If the targeted limb is horribly bruised, you'll tear it off\
	when throwing the victim."
	button_icon_state = "lariat"
	cooldown_time = 3 SECONDS

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
		

/obj/item/buster/graphand
	name = "grapple"
	desc = "Your fingers occasionally curl as if they have their own urge to dig into something."
	color = "#f14b4b"
	var/throwdist = 5
	var/throwdam = 15
	var/slamdam = 7
	var/objdam = 50

/obj/item/buster/graphand/afterattack(atom/target, mob/living/user, proximity)
	var/turf/Z = get_turf(user)
	var/list/thrown = list()
	var/side = user.get_held_index_of_item(src)
	target.add_fingerprint(user, FALSE)
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
		if(istype(I, /obj/mecha))
			I.anchored = FALSE
		if(I.anchored == TRUE)
			if(istype(I, /obj/machinery/vending))
				I.anchored = FALSE
				I.visible_message(span_warning("[user] grabs [I] and tears it off the bolts securing it!"))
			else
				return
		I.visible_message(span_warning("[user] grabs [I] and lifts it above [user.p_their()] head!"))
		qdel(src)
		animate(I, time = 0.2 SECONDS, pixel_y = 20)
		I.forceMove(Z)
		I.density = FALSE 
		walk_towards(I, user, 0, 2)
		sleep(2 SECONDS)
		if(get_dist(I, user) > 1)
			I.density = old_density
		walk(I,0)
		thrown |= I
		I.density = old_density
		if(istype(I, /obj/mecha))
			I.anchored = TRUE
		animate(I, time = 0.2 SECONDS, pixel_y = 0)
	if(isliving(target))
		var/mob/living/L = target
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(user.zone_selected)
		var/obj/structure/bed/grip/F = new(Z, user)
		var/old_density = L.density // for the sake of noncarbons not playing nice with lying down
		L.density = FALSE
		qdel(src)
		to_chat(L, span_userdanger("[user] grapples you and lifts you up into the air!"))
		L.forceMove(Z)
		F.buckle_mob(target)
		walk_towards(F, user, 0, 2)
		sleep(1 SECONDS)
		if(get_dist(L, user) > 1)
			L.density = old_density
			return
		hit(user, L, throwdam)
		if(iscarbon(L))
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
		thrown |= L
	target.visible_message(span_warning("[user] throws [target]!"))
	var/direction = user.dir
	var/turf/P = get_turf(user)
	for(var/i = 1 to throwdist)
		var/turf/C = get_ranged_target_turf(P, direction, i)
		if(C.density)
			for(var/mob/living/S in thrown)
				hit(user, S, slamdam)
				S.Knockdown(1.5 SECONDS)
				S.Immobilize(1.5 SECONDS)
				if(isanimal(S) && S.stat == DEAD)
					S.gib()	
			for(var/obj/O in thrown)
				O.take_damage(objdam)
				target.visible_message(span_warning("[target] collides with [C]!"))
			return
		for(var/obj/D in C.contents)
			for(var/obj/O in thrown)
				if(D.density == TRUE)
					O.take_damage(objdam)	
					if(istype(O, /obj/mecha))
						thrown -= O
			if(D.density == TRUE && D.anchored == FALSE)
				thrown |= D
				D.take_damage(50)
			if(D.density == TRUE && D.anchored == TRUE)
				for(var/mob/living/S in thrown)
					hit(user, S, slamdam)
					S.Knockdown(1.5 SECONDS)
					S.Immobilize(1.5 SECONDS)
					if(isanimal(S) && S.stat == DEAD)
						S.gib()	
					if(istype(D, /obj/machinery/disposal/bin))
						var/obj/machinery/disposal/bin/dumpster = D
						S.forceMove(D)
						D.visible_message(span_warning("[S] is thrown down the trash chute!"))
						dumpster.do_flush()
						return
				D.take_damage(objdam)
				if(D.density == TRUE)
					return
		for(var/mob/living/M in C.contents)
			hit(user, M, slamdam)
			M.Knockdown(1.5 SECONDS)
			for(var/mob/living/S in thrown)
				hit(user, S, slamdam)
				S.Knockdown(1 SECONDS)
			thrown |= M
			for(var/obj/O in thrown)
				O.take_damage(objdam)
		if(C)
			for(var/atom/movable/K in thrown)
				K.SpinAnimation(0.2 SECONDS, 1)
				sleep(0.001 SECONDS)
				K.forceMove(C)
				if(istype(C, /turf/open/space))
					var/atom/throw_target = get_edge_target_turf(K, direction)
					K.throw_at(throw_target, 6, 4, user, 3)

/obj/item/buster/graphand/ignition_effect(atom/A, mob/user)
	playsound(user,'sound/misc/fingersnap2.ogg', 20, 1)
	playsound(user,'sound/effects/sparks4.ogg', 20, 1)
	do_sparks(5, TRUE, src)
	. = span_rose("With a single snap, [user] sets [A] alight with sparks from [user.p_their()] metal fingers.")



/datum/action/cooldown/buster/mop
	name = "Mop the Floor"
	desc = "Launch forward and drag whoever's in front of you on the ground. The power of this move increases with closeness to the target upon using it."
	button_icon_state = "mop"
	cooldown_time = 4 SECONDS
	var/jumpdistance = 5
	var/dragdam = 8
	var/crashdam = 10

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
		if(T.density)
			return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				return
		if(T)
			sleep(0.01 SECONDS)
			B.forceMove(T)
			walk_towards(F, owner, 0, 1.5)
			animate(F, alpha = 0, color = "#d40a0a", time = 0.5 SECONDS)
			for(var/mob/living/L in T.contents)
				if(L != B)
					mopped |= L
					L.add_fingerprint(B, FALSE)
					var/turf/Q = get_step(get_turf(B), B.dir)
					var/mob/living/U = B
					to_chat(L, span_userdanger("[B] grinds you against the ground!"))
					if(L.stat == CONSCIOUS && L.resting == FALSE)
						animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
					if(istype(T, /turf/open/space))
						var/atom/throw_target = get_edge_target_turf(L, B.dir)
						if(L.stat == CONSCIOUS && L.resting == FALSE)
							animate(L, transform = null, time = 0.5 SECONDS, loop = 0)
						L.throw_at(throw_target, 2, 4, B, 3)
						return
					if(Q.density)
						if(L.stat == CONSCIOUS && L.resting == FALSE)
							animate(L, transform = null, time = 0.5 SECONDS, loop = 0)
						grab(B, L, crashdam)
						U.visible_message(span_warning("[U] rams [L] into [Q]!"))
						to_chat(L, span_userdanger("[U] rams you into [Q]!"))
						L.Knockdown(1 SECONDS)
						L.Immobilize(1.5 SECONDS)
						return
					for(var/obj/D in Q.contents)
						if(L.stat == CONSCIOUS && L.resting == FALSE)
							animate(L, transform = null, time = 0.5 SECONDS, loop = 0)
						if(D.density == TRUE)
							grab(B, L, crashdam)
							U.visible_message(span_warning("[B] rams [L] into [D]!"))
							to_chat(L, span_userdanger("[B] rams you into [D]!"))
							D.take_damage(200)
							L.Knockdown(1 SECONDS)
							L.Immobilize(1 SECONDS)
							if(D.density == TRUE)
								return
					U.forceMove(get_turf(L))
					to_chat(L, span_userdanger("[U] catches you with [U.p_their()] hand and drags you down!"))
					U.visible_message(span_warning("[U] hits [L] and drags them through the dirt!"))
					L.forceMove(Q)
					grab(B, L, dragdam)
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(B, B.dir)
	for(var/mob/living/C in mopped)
		if(C.stat == CONSCIOUS && C.resting == FALSE)
			animate(C, transform = null, time = 0.5 SECONDS, loop = 0)


/datum/action/cooldown/buster/slam
	name = "Slam"
	desc = "Grab the target in front of you and slam them back onto the ground. If there's a solid object or wall behind you when the move is successfully performed then\
	it will take substantial damage."
	button_icon_state = "suplex"
	cooldown_time = 0.7 SECONDS
	var/supdam = 25
	var/crashdam = 10
	var/walldam = 30

/datum/action/cooldown/buster/slam/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/turf/T = get_step(get_turf(owner), owner.dir)
	var/turf/Z = get_turf(owner)
	owner.visible_message(span_warning("[owner] outstretches [owner.p_their()] arm and goes for a grab!"))
	for(var/mob/living/L in T.contents)
		var/turf/Q = get_step(get_turf(owner), turn(owner.dir,180))
		if(Q.density)
			var/turf/closed/wall/W = Q
			grab(owner, L, walldam)
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
			if(!istype(W, /turf/closed/wall/r_wall))
				W.dismantle_wall(1)
				L.forceMove(Q)
			else		
				L.forceMove(Z)
			return
		for(var/obj/D in Q.contents)
			if(D.density == TRUE)
				if(istype(D, /obj/machinery/disposal/bin))
					var/obj/machinery/disposal/bin/dumpster = D
					L.forceMove(D)
					dumpster.do_flush()
					to_chat(L, span_userdanger("[owner] throws you down disposals!"))
					target.visible_message(span_warning("[L] is thrown down the trash chute!"))
					return
				owner.visible_message(span_warning("[owner] turns around and slams [L] against [D]!"))
				D.take_damage(400)
				grab(owner, L, crashdam)
				if(L.stat == CONSCIOUS && L.resting == FALSE)
					animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
				if(isanimal(L) && L.stat == DEAD)
					L.visible_message(span_warning("[L] explodes into gore on impact!"))
					L.gib()
				sleep(0.2 SECONDS)
				if(L.stat == CONSCIOUS && L.resting == FALSE)
					animate(L, transform = null, time = 0.2 SECONDS, loop = 0)
		for(var/mob/living/M in Q.contents)
			grab(owner, L, crashdam)
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
			grab(owner, M, crashdam)
		L.forceMove(Q)
		if(istype(Q, /turf/open/space))
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
		grab(owner, L, supdam)
		if(L.stat == CONSCIOUS && L.resting == FALSE)
			animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
		if(isanimal(L) && L.stat == DEAD)
			L.visible_message(span_warning("[L] explodes into gore on impact!"))
			L.gib()
		sleep(0.2 SECONDS)
		if(L.stat == CONSCIOUS && L.resting == FALSE)
			animate(L, transform = null, time = 0.2 SECONDS, loop = 0)


/datum/action/cooldown/buster/megabuster
	name = "Mega Buster"
	desc = "Put the buster arm through its paces to gain extreme power for five seconds. Connecting the blow will devastate the target and send them flying. Flying targets will have\
	a snowball effect on hitting other unanchored people or objects collided with. Punching a mangled limb will instead send it flying and momentarily stun	its owner. Once the five\
	seconds are up or a strong wall or person or exosuit is hit, the arm won't be able to do that again for 20 seconds."
	button_icon_state = "ponch"
	cooldown_time = 20 SECONDS

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

/obj/item/buster/megabuster/ignition_effect(atom/A, mob/user)
	playsound(user,'sound/misc/fingersnap1.ogg', 20, 1)
	playsound(user,'sound/effects/sparks4.ogg', 20, 1)
	do_sparks(5, TRUE, src)
	. = span_rose("With a single snap, [user] sets [A] alight with sparks from [user.p_their()] metal fingers.")

/obj/item/buster/megabuster/afterattack(atom/target, mob/living/user, proximity)
	var/direction = user.dir
	var/list/knockedback = list()
	var/mob/living/L = target
	if(!proximity)
		return
	if(target == user)
		return
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
	if(isopenturf(target))
		return
	playsound(L, 'sound/effects/gravhit.ogg', 60, 1)
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		if(istype(W, /turf/closed/wall/r_wall))
			W.dismantle_wall(1)
			qdel(src)
		else
			W.dismantle_wall(1)
		user.visible_message(span_warning("[user] demolishes [W]!"))
		return
	if(ismecha(target))
		var/obj/mecha/A = target
		A.take_damage(mechdam)
		user.visible_message(span_warning("[user] crushes [target]!"))
		qdel(src)
	if(isstructure(target) || ismachinery(target))
		user.visible_message(span_warning("[user] strikes [target]!"))
		var/obj/I = target
		if(I.anchored == TRUE)
			I.take_damage(objdam)
			return
		I.take_damage(50)
		knockedback |= I
		if(QDELETED(I))
			return
	if(isliving(L))
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(user.zone_selected)
		var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		qdel(src, force = TRUE)
		shake_camera(L, 4, 3)
		L.apply_damage(punchdam, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
		if(!limb_to_hit)
			limb_to_hit = L.get_bodypart(BODY_ZONE_CHEST)
		if(iscarbon(L))
			if(limb_to_hit.brute_dam == limb_to_hit.max_damage)
				if(istype(limb_to_hit, /obj/item/bodypart/chest))
					knockedback |= L
				else
					var/atom/throw_target = get_edge_target_turf(L, direction)
					to_chat(L, span_userdanger("[user] blows [limb_to_hit] off with inhuman force!"))
					user.visible_message(span_warning("[user] punches [L]'s [limb_to_hit] clean off!"))
					limb_to_hit.drop_limb()
					limb_to_hit.throw_at(throw_target, 8, 4, user, 3)
					L.Paralyze(3 SECONDS)
					return
		L.SpinAnimation(0.5 SECONDS, 2)
		to_chat(L, span_userdanger("[user] hits you with a blast of energy and sends you flying!"))
		user.visible_message(span_warning("[user] blasts [L] with a surge of energy and sends [L.p_them()] flying!"))
		knockedback |= L
	for(var/mob/M in view(7, user))
		shake_camera(M, 2, 3)
	var/turf/P = get_turf(user)
	for(var/i = 2 to flightdist)
		var/turf/T = get_ranged_target_turf(P, direction, i)
		if(T.density)
			var/turf/closed/wall/W = T
			for(var/obj/J in knockedback)
				J.take_damage(objcolldam)
			for(var/mob/living/S in knockedback)
				hit(user, S, colldam)
				if(isanimal(S) && S.stat == DEAD)
					S.gib()
			if(!istype(W, /turf/closed/wall/r_wall))
				playsound(L,'sound/effects/meteorimpact.ogg', 50, 1)
				W.dismantle_wall(1)
			else
				return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				for(var/obj/J in knockedback)
					J.take_damage(objcolldam)
				for(var/mob/living/S in knockedback)
					hit(user, S, hitobjdam)
				if(D.anchored == FALSE)
					knockedback |= D
					D.take_damage(50)
				if(D.anchored == TRUE)
					D.take_damage(objdam)
					if(D.density == TRUE)
						return
					for(var/mob/living/S in knockedback)
						hit(user, S, colldam)
						if(isanimal(S) && S.stat == DEAD)
							S.gib()		
		for(var/mob/living/M in T.contents)
			hit(user, M, colldam)
			for(var/mob/living/S in knockedback)
				hit(user, S, colldam)
			knockedback |= M
		if(T)
			for(var/atom/movable/K in knockedback)
				K.SpinAnimation(0.2 SECONDS, 1)
				sleep(0.001 SECONDS)
				K.forceMove(T)
				if(istype(T, /turf/open/space))
					var/atom/throw_target = get_edge_target_turf(K, direction)
					K.throw_at(throw_target, 6, 4, user, 3)
					return

/obj/item/buster/megabuster/Initialize(mob/living/user)
	. = ..()
	animate(src, alpha = 50, time = 5 SECONDS)
	QDEL_IN(src, 5 SECONDS)

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
			if(!do_after(M, 2 SECONDS, src))
				if(M && M.buckled)
					to_chat(M, span_warning("You fail to free yourself!"))
				return
			if(!M.buckled)
				return
			unbuckle_mob(M)
			add_fingerprint(user)

/datum/action/cooldown/buster/grap/r
	name = "Grapple"
	desc = "Prepare your right hand for grabbing. Throw your target and inflict more damage if they hit a solid object. If the targeted limb is horribly bruised, you'll tear it off\
	when throwing the victim."
	button_icon_state = "lariat"
	cooldown_time = 3 SECONDS

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


/datum/action/cooldown/buster/wire_snatch/r/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/obj/item/gun/magic/wire/T = new()
	for(var/obj/item/gun/magic/wire/J in owner)
		qdel(J)
		to_chat(owner, span_notice("The wire returns into your wrist."))
		return
	if(!owner.put_in_l_hand(T))
		to_chat(owner, span_warning("You can't do this with your right hand full!"))
	else
		if(owner.active_hand_index % 2 == 0)
			owner.swap_hand(0) //making the grappling hook hand (right) the active one so using it is streamlined

//buster Arm

/obj/item/bodypart/l_arm/robot/buster
	name = "left buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "left_buster_arm"
	max_damage = 60
	aux_layer = 12
	var/obj/item/bodypart/r_arm/robot/buster/opphand
	var/datum/action/cooldown/buster/mop/l/C = new/datum/action/cooldown/buster/mop/l()
	var/datum/action/cooldown/buster/slam/l/V = new/datum/action/cooldown/buster/slam/l()
	var/datum/action/cooldown/buster/megabuster/l/I = new/datum/action/cooldown/buster/megabuster/l()
	var/datum/action/cooldown/buster/wire_snatch/l/D =new/datum/action/cooldown/buster/wire_snatch/l()
	var/datum/action/cooldown/buster/grap/l/M = new/datum/action/cooldown/buster/grap/l()

/obj/item/bodypart/l_arm/robot/buster/attach_limb(mob/living/carbon/N, special)
	. = ..()
	var/datum/species/S = N.dna?.species
	S.add_no_equip_slot(N, SLOT_GLOVES)
	D.Grant(N)
	M.Grant(N)
	C.Grant(N)
	V.Grant(N)
	I.Grant(N)

/obj/item/bodypart/l_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/N = owner
	var/datum/species/S = N.dna?.species
	S.remove_no_equip_slot(N, SLOT_GLOVES)
	D.Remove(N)
	M.Remove(N)
	C.Remove(N)
	V.Remove(N)
	I.Remove(N)
	..()

/obj/item/bodypart/l_arm/robot/buster/attack(mob/living/L, proximity)
	if(!proximity)
		return
	if(!ishuman(L))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your left arm!"))
	replace_limb(L)


/obj/item/bodypart/l_arm/robot/buster/attack_self(mob/user)
	. = ..()
	opphand = new /obj/item/bodypart/r_arm/robot/buster(get_turf(src))
	opphand.brute_dam = src.brute_dam
	opphand.burn_dam = src.burn_dam 
	to_chat(user, span_notice("You modify [src] to be installed on the right arm."))
	qdel(src)

/obj/item/bodypart/r_arm/robot/buster
	name = "right buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "right_buster_arm"
	max_damage = 60
	aux_layer = 12
	var/obj/item/bodypart/l_arm/robot/buster/opphand
	var/datum/action/cooldown/buster/mop/r/C = new/datum/action/cooldown/buster/mop/r()
	var/datum/action/cooldown/buster/slam/r/V = new/datum/action/cooldown/buster/slam/r()
	var/datum/action/cooldown/buster/megabuster/r/I = new/datum/action/cooldown/buster/megabuster/r()
	var/datum/action/cooldown/buster/wire_snatch/r/D = new/datum/action/cooldown/buster/wire_snatch/r()
	var/datum/action/cooldown/buster/grap/r/M = new/datum/action/cooldown/buster/grap/r()

/obj/item/bodypart/r_arm/robot/buster/attack(mob/living/L, proximity)
	if(!proximity)
		return
	if(!ishuman(L))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your right arm!"))
	replace_limb(L)

/obj/item/bodypart/r_arm/robot/buster/attack_self(mob/user)
	. = ..()
	opphand = new /obj/item/bodypart/l_arm/robot/buster(get_turf(src))
	opphand.brute_dam = src.brute_dam
	opphand.burn_dam = src.burn_dam 
	to_chat(user, span_notice("You modify [src] to be installed on the left arm."))
	qdel(src)

/obj/item/bodypart/r_arm/robot/buster/attach_limb(mob/living/carbon/N, special)
	. = ..()
	var/datum/species/S = N.dna?.species
	S.add_no_equip_slot(N, SLOT_GLOVES)
	D.Grant(N)
	M.Grant(N)
	C.Grant(N)
	V.Grant(N)
	I.Grant(N)

/obj/item/bodypart/r_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/N = owner
	var/datum/species/S = N.dna?.species
	S.remove_no_equip_slot(N, SLOT_GLOVES)
	D.Remove(N)
	M.Remove(N)
	C.Remove(N)
	V.Remove(N)
	I.Remove(N)
	..()
