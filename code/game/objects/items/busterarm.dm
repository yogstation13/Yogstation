/obj/effect/proc_holder/spell/targeted/buster
	clothes_req = FALSE
	include_user = TRUE
	range = -1

/obj/effect/proc_holder/spell/targeted/buster/can_cast(mob/living/user)
	var/obj/item/bodypart/l_arm/robot/buster/L = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm/robot/buster/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled || L?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	if(user.IsParalyzed() || user.IsStun() || user.restrained())
		return FALSE
	return TRUE
	
/obj/item/buster/proc/hit(mob/living/user, mob/living/target, damage)
		var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
		var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

/obj/effect/proc_holder/spell/targeted/buster/proc/grab(mob/living/user, mob/living/target, damage)
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
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/effect/proc_holder/spell/targeted/buster/wire_snatch
	name = "Wire Snatch"
	desc = "Extend a wire to your active hand for reeling in foes from a distance. Reeled in targets will be unable to walk for 1.5 seconds. Anchored targets that are hit will\
	pull you towards them instead. It can be used 3 times before reeling back into the arm."
	invocation_type = "none"
	include_user = TRUE
	range = -1
	charge_max = 50
	clothes_req = FALSE
	cooldown_min = 10
	action_icon = 'icons/obj/guns/magic.dmi'
	action_icon_state = "hook"
	var/summon_path = /obj/item/gun/magic/wire

/obj/effect/proc_holder/spell/targeted/buster/wire_snatch/cast(list/targets, mob/user)
	for(var/obj/item/gun/magic/wire/T in user)
		qdel(T)
		to_chat(user, span_notice("The wire returns into your wrist."))
		return
	for(var/mob/living/carbon/C in targets)
		var/GUN = new summon_path
		C.put_in_r_hand(GUN)
		if(C.active_hand_index % 2 == 1)
			C.swap_hand(0) //making the grappling hook hand (right) the active one so using it is streamlined


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
	if(charges == 0)
		qdel(src)

/obj/item/projectile/wire/Destroy()
	qdel(wire)
	return ..()

/obj/effect/proc_holder/spell/targeted/touch/buster/grap
	name = "Grapple"
	desc = "Prepare your left hand for grabbing. Throw your target and inflict more damage if they hit a solid object. If the targeted limb is horribly bruised, you'll tear it off\
	when throwing the victim."
	hand_path = /obj/item/buster/graphand
	school = "transmutation"
	charge_max = 30
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "lariat"
	sound = 'sound/magic/fleshtostone.ogg'
	clothes_req = FALSE
	var/jumpdistance = 4

/obj/effect/proc_holder/spell/targeted/touch/buster/grap/cast(list/targets, mob/user = usr)
	if(!QDELETED(attached_hand))
		remove_hand(TRUE)
		to_chat(user, span_notice("[dropmessage]"))
		return
	for(var/mob/living/carbon/C in targets)
		C.visible_message(span_warning("The fingers on [C]'s left buster arm begin to tense up."))
		if(!attached_hand)
			attached_hand = new hand_path(src)
			attached_hand.attached_spell = src
			user.put_in_l_hand(attached_hand)
			recharging = FALSE
		if(C.active_hand_index % 2 == 0)
			C.swap_hand(0)
			return

/obj/item/buster/graphand
	name = "grapple"
	desc = "Your fingers occasionally curl as if they have their own urge to dig into something."
	color = "#f14b4b"
	var/obj/effect/proc_holder/spell/targeted/touch/attached_spell
	var/throwdist = 5
	var/throwdam = 15
	var/slamdam = 7
	var/objdam = 50

/obj/item/buster/graphand/afterattack(atom/target, mob/living/user, proximity)
	var/turf/Z = get_turf(user)
	var/list/thrown = list()
	var/obj/item/bodypart/l_arm/robot/buster/L = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm/robot/buster/R = user.get_bodypart(BODY_ZONE_R_ARM)
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
			if(side == LEFT_HANDS)
				(L?.set_disabled(TRUE))
				addtimer(CALLBACK(L, /obj/item/bodypart/l_arm/.proc/set_disabled), 5 SECONDS, TRUE)
			if(side == RIGHT_HANDS)
				(R?.set_disabled(TRUE))
				addtimer(CALLBACK(R, /obj/item/bodypart/r_arm/.proc/set_disabled), 5 SECONDS, TRUE)
			to_chat(user, span_userdanger("The strain of lifting [I] disables your arm for a few seconds!"))
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
				animate(K, transform = null, time = 0.5 SECONDS, loop = 0)



/obj/item/buster/graphand/Destroy()
	if(attached_spell)
		attached_spell.on_hand_destroy(src)
	return ..()

/obj/item/buster/graphand/ignition_effect(atom/A, mob/user)
	playsound(user,'sound/misc/fingersnap2.ogg', 20, 1)
	playsound(user,'sound/effects/sparks4.ogg', 20, 1)
	do_sparks(5, TRUE, src)
	. = span_rose("With a single snap, [user] sets [A] alight with sparks from [user.p_their()] metal fingers.")
			
/obj/effect/proc_holder/spell/targeted/buster/mop
	name = "Mop the Floor"
	desc = "Launch forward and drag whoever's in front of you on the ground. The power of this move increases with closeness to the target upon using it."
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "mop"
	charge_max = 40	
	var/jumpdistance = 5
	var/dragdam = 8
	var/crashdam = 10

/obj/effect/proc_holder/spell/targeted/buster/mop/cast(atom/target,mob/living/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	var/obj/effect/temp_visual/decoy/fading/threesecond/F = new(Z, user)
	var/list/mopped = list()
	user.visible_message(span_warning("[user] sprints forward with [user.p_their()] hand outstretched!"))
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)
	user.Immobilize(0.1 SECONDS) //so they dont skip through the target
	for(var/i = 1 to jumpdistance)
		if(T.density)
			return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				return
		if(T)
			sleep(0.01 SECONDS)
			user.forceMove(T)
			walk_towards(F, user, 0, 1.5)
			animate(F, alpha = 0, color = "#d40a0a", time = 0.5 SECONDS)
			for(var/mob/living/L in T.contents)
				if(L != user)
					mopped |= L
					L.add_fingerprint(user, FALSE)
					var/turf/Q = get_step(get_turf(user), user.dir)
					var/mob/living/U = user
					to_chat(L, span_userdanger("[user] grinds you against the ground!"))
					animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
					if(istype(T, /turf/open/space))
						var/atom/throw_target = get_edge_target_turf(L, user.dir)
						animate(L, transform = null, time = 0.5 SECONDS, loop = 0)
						L.throw_at(throw_target, 2, 4, user, 3)
						return
					if(Q.density)
						grab(user, L, crashdam)
						animate(L, transform = null, time = 0.5 SECONDS, loop = 0)
						U.visible_message(span_warning("[U] rams [L] into [Q]t!"))
						to_chat(L, span_userdanger("[U] rams you into a [Q]!"))
						L.Knockdown(1 SECONDS)
						L.Immobilize(1.5 SECONDS)
						return
					for(var/obj/D in Q.contents)
						if(D.density == TRUE)
							grab(user, L, crashdam)
							D.take_damage(200)
							L.Knockdown(1 SECONDS)
							L.Immobilize(1 SECONDS)
					U.forceMove(get_turf(L))
					to_chat(L, span_userdanger("[U] catches you with [U.p_their()] hand and drags you down!"))
					U.visible_message(span_warning("[U] hits [L] and drags them through the dirt!"))
					L.forceMove(Q)
					grab(user, L, dragdam)
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(user, user.dir)
	for(var/mob/living/C in mopped)
		if(C.stat == CONSCIOUS && C.resting == FALSE)
			animate(C, transform = null, time = 0.5 SECONDS, loop = 0)

/obj/effect/proc_holder/spell/targeted/buster/slam
	name = "Slam"
	desc = "Grab the target in front of you and slam them back onto the ground. \
	 If there's a solid object or wall behind you when the move is successfully performed then it will \ take substantial damage."
	action_icon = 'icons/mob/actions/actions_arm.dmi'	
	action_icon_state = "suplex"
	charge_max = 7
	var/supdam = 25
	var/crashdam = 10
	var/walldam = 30

/obj/effect/proc_holder/spell/targeted/buster/slam/cast(atom/target,mob/living/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	user.visible_message(span_warning("[user] outstretches [user.p_their()] arm and goes for a grab!"))
	for(var/mob/living/L in T.contents)
		var/turf/Q = get_step(get_turf(user), turn(user.dir,180))
		if(Q.density)
			var/turf/closed/wall/W = Q
			grab(user, L, walldam)
			to_chat(user, span_warning("[user] turns around and slams [L] against [Q]!"))
			to_chat(L, span_userdanger("[user] crushes you against [Q]!"))
			playsound(L, 'sound/effects/meteorimpact.ogg', 60, 1)
			playsound(user, 'sound/effects/gravhit.ogg', 20, 1)
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
					to_chat(L, span_userdanger("[user] throws you down disposals!"))
					target.visible_message(span_warning("[L] is thrown down the trash chute!"))
					return
				user.visible_message(span_warning("[user] turns around and slams [L] against [D]!"))
				grab(user, L, crashdam)
				D.take_damage(400)
		for(var/mob/living/M in Q.contents)
			grab(user, L, crashdam)	
			to_chat(L, span_userdanger("[user] throws you into [M]"))
			to_chat(M, span_userdanger("[user] throws [L] into you!"))
			user.visible_message(span_warning("[L] slams into [M]!"))
			grab(user, M, crashdam)
		L.forceMove(Q)
		if(istype(Q, /turf/open/space))
			user.setDir(turn(user.dir,180))
			var/atom/throw_target = get_edge_target_turf(L, user.dir)
			L.throw_at(throw_target, 2, 4, user, 3)
			user.visible_message(span_warning("[user] throws [L] behind [user.p_them()]!"))
			return
		playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
		playsound(user, 'sound/effects/gravhit.ogg', 20, 1)
		to_chat(L, span_userdanger("[user] catches you with [user.p_their()] hand and crushes you on the ground!"))
		user.visible_message(span_warning("[user] turns around and slams [L] against the ground!"))
		user.setDir(turn(user.dir, 180))
		animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
		if(isanimal(L) && L.stat == DEAD)
			L.visible_message(span_warning("[L] explodes into gore on impact!"))
			L.gib()
		grab(user, L, supdam)
		sleep(0.5 SECONDS)
		if(L.stat == CONSCIOUS && L.resting == FALSE)
			animate(L, transform = null, time = 0.5 SECONDS, loop = 0)
		else
			animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
		
/obj/effect/proc_holder/spell/targeted/buster/megabuster
	name = "Mega Buster"
	desc = "Put the buster arm through its paces to gain extreme power for five seconds. Connecting the blow will devastate the target and send them flying. Flying targets will have\
	a snowball effect on hitting other unanchored people or objects collided with. Punching a mangled limb will instead send it flying and momentarily stun	its owner. Once the five\
	seconds are up or a strong wall or person or exosuit is hit, the entire arm will be unusable for 15 seconds."
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "ponch"
	charge_max = 60

/obj/effect/proc_holder/spell/targeted/buster/megabuster/cast(list/targets, mob/living/user)
	var/obj/item/buster/megabuster/B = new()
	user.visible_message(span_userdanger("[user]'s left arm begins crackling loudly!"))
	playsound(user,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	if(do_after(user, 2 SECONDS, user, TRUE, stayStill = FALSE))
		var/result = (user.put_in_l_hand(B))
		if(!result)
			to_chat(user, span_warning("You can't do this with your left hand full!"))
		if(result)
			user.visible_message(span_danger("[user]'s arm begins shaking violently!"))
			B.fizzle(user)

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
	var/obj/item/bodypart/l_arm/R = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm/Q = user.get_bodypart(BODY_ZONE_R_ARM)
	var/list/knockedback = list()
	var/side = user.get_held_index_of_item(src)
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
			to_chat(user, span_warning("The huge impact takes the arm out of commission! It won't be ready for 15 seconds!"))
			if(side == LEFT_HANDS)
				(R?.set_disabled(TRUE))
				addtimer(CALLBACK(Q, /obj/item/bodypart/r_arm/.proc/set_disabled), 5 SECONDS, TRUE)
				return
			if(side == RIGHT_HANDS)
				(Q?.set_disabled(TRUE))
				addtimer(CALLBACK(R, /obj/item/bodypart/l_arm/.proc/set_disabled), 5 SECONDS, TRUE)
				return
		else
			W.dismantle_wall(1)
		user.visible_message(span_warning("[user] demolishes [W]!"))
		return
	if(ismecha(target))
		var/obj/mecha/A = target
		A.take_damage(mechdam)
		user.visible_message(span_warning("[user] crushes [target]!"))
		if(side == LEFT_HANDS)
			(R?.set_disabled(TRUE))
			addtimer(CALLBACK(Q, /obj/item/bodypart/r_arm/.proc/set_disabled), 5 SECONDS, TRUE)
			qdel(src)
		if(side == RIGHT_HANDS)
			(Q?.set_disabled(TRUE))
			addtimer(CALLBACK(R, /obj/item/bodypart/l_arm/.proc/set_disabled), 5 SECONDS, TRUE)
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
		to_chat(user, span_warning("The huge impact takes the arm out of commission! It won't be ready for 15 seconds!"))
		shake_camera(L, 4, 3)
		L.apply_damage(punchdam, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
		if(side == LEFT_HANDS)
			(R?.set_disabled(TRUE))
			addtimer(CALLBACK(Q, /obj/item/bodypart/r_arm/.proc/set_disabled), 5 SECONDS, TRUE)
		if(side == RIGHT_HANDS)
			(Q?.set_disabled(TRUE))
			addtimer(CALLBACK(R, /obj/item/bodypart/l_arm/.proc/set_disabled), 5 SECONDS, TRUE)
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
					animate(K, transform = null, time = 0.5 SECONDS, loop = 0)
					K.throw_at(throw_target, 6, 4, user, 3)
					return

/obj/item/buster/megabuster/Initialize(mob/living/user)
	. = ..()
	animate(src, alpha = 50, time = 5 SECONDS)
	
/obj/item/buster/megabuster/proc/fizzle(mob/living/user, right = FALSE)
	var/obj/item/bodypart/l_arm/L = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	sleep(5 SECONDS)
	qdel(src)
	if(right)
		(R?.set_disabled(TRUE))
		addtimer(CALLBACK(R, /obj/item/bodypart/r_arm/.proc/set_disabled), 15 SECONDS, TRUE)
		to_chat(user, span_warning("The energy output shorts out the buster arm! It won't be ready for 15 seconds!"))
	else
		(L?.set_disabled(TRUE))
		addtimer(CALLBACK(L, /obj/item/bodypart/l_arm/.proc/set_disabled), 15 SECONDS, TRUE)
		to_chat(user, span_warning("The energy output shorts out the buster arm! It won't be ready for 15 seconds!"))

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

/obj/effect/proc_holder/spell/targeted/touch/buster/grap/right
	desc = "Prepare your right hand for grabbing. Throw your target and inflict more damage if they hit a solid object. If the targeted limb is horribly bruised, you'll tear it off when \
	throwing the victim."

/obj/effect/proc_holder/spell/targeted/touch/buster/grap/right/cast(list/targets, mob/living/user)
	if(!QDELETED(attached_hand))
		remove_hand(TRUE)
		to_chat(user, span_notice("[dropmessage]"))
		return
	for(var/mob/living/carbon/C in targets)
		C.visible_message(span_warning("The fingers on [C]'s left buster arm begin to tense up."))
		if(!attached_hand)
			attached_hand = new hand_path(src)
			attached_hand.attached_spell = src
			user.put_in_r_hand(attached_hand)
			recharging = FALSE
			if(C.active_hand_index % 2 == 1)
				C.swap_hand(0)
			return

/obj/effect/proc_holder/spell/targeted/buster/megabuster/right

/obj/effect/proc_holder/spell/targeted/buster/megabuster/right/cast(list/targets, mob/living/user)
	var/obj/item/buster/megabuster/B = new()
	user.visible_message(span_userdanger("[user]'s right arm begins crackling loudly!"))
	playsound(user,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	if(do_after(user, 2 SECONDS, user, TRUE, stayStill = FALSE))
		var/result = (user.put_in_r_hand(B))
		if(!result)
			to_chat(user, span_warning("You can't do this with your right hand full!"))
		if(result)
			user.visible_message(span_danger("[user]'s arm begins shaking violently!"))
			B.fizzle(user, right = TRUE)

/obj/effect/proc_holder/spell/targeted/buster/wire_snatch/right/cast(list/targets, mob/user)
	for(var/obj/item/gun/magic/wire/T in user)
		qdel(T)
		to_chat(user, span_notice("The wire returns into your wrist."))
		return
	for(var/mob/living/carbon/C in targets)
		var/GUN = new summon_path
		C.put_in_l_hand(GUN)
		if(C.active_hand_index % 2 == 0)
			C.swap_hand(0) //switching to hook in left hand 

//buster Arm

/obj/item/bodypart/l_arm/robot/buster
	name = "left buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "left_buster_arm"
	max_damage = 60
	aux_layer = 12
	var/obj/item/bodypart/r_arm/robot/buster/opphand

/obj/item/bodypart/l_arm/robot/buster/attach_limb(mob/living/carbon/C, special)
	. = ..()
	var/datum/species/S = C.dna?.species
	S.add_no_equip_slot(C, SLOT_GLOVES)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/wire_snatch)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/touch/buster/grap)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/mop)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/slam)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/megabuster)

/obj/item/bodypart/l_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/C = owner
	var/datum/species/S = C.dna?.species
	S.add_no_equip_slot(C, SLOT_GLOVES)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/wire_snatch)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/touch/buster/grap)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/mop)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/slam)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/megabuster)
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

/obj/item/bodypart/r_arm/robot/buster/attach_limb(mob/living/carbon/C, special)
	. = ..()
	var/datum/species/S = C.dna?.species
	S.add_no_equip_slot(C, SLOT_GLOVES)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/wire_snatch/right)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/touch/buster/grap/right)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/mop)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/slam)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/megabuster/right)

/obj/item/bodypart/r_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/C = owner
	var/datum/species/S = C.dna?.species
	S.add_no_equip_slot(C, SLOT_GLOVES)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/wire_snatch/right)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/touch/buster/grap/right)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/mop)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/slam)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/megabuster/right)
	..()
