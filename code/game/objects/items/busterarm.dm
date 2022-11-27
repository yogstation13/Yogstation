/obj/effect/proc_holder/spell/targeted/buster
	clothes_req = FALSE
	include_user = TRUE
	range = -1

/obj/effect/proc_holder/spell/targeted/buster/can_cast(mob/living/user)
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	if(user.IsParalyzed() || user.IsStun() || user.restrained())
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/targeted/buster/wire_snatch
	name = "Wire Snatch"
	desc = "Extend a wire from the right arm to reel in foes from a distance. Anchored targets that are hit will pull you towards them instead."
	invocation_type = "none"
	include_user = TRUE
	range = -1
	charge_max = 1
	clothes_req = FALSE
	cooldown_min = 10
	action_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	action_icon_state = "bolt_action"
	var/summon_path = /obj/item/gun/magic/wire

/obj/effect/proc_holder/spell/targeted/buster/wire_snatch/cast(list/targets, mob/user)
	for(var/obj/item/gun/magic/wire/T in user)
		qdel(T)
		to_chat(user, span_notice("The wire returns into your shoulder."))
		return
	for(var/mob/living/carbon/C in targets)
		var/GUN = new summon_path
		C.put_in_hands(GUN)

/obj/item/gun/magic/wire/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, NOBLUDGEON)
	if(ismob(loc))
		loc.visible_message(span_warning("A long cable comes out from [loc.name]'s arm!"), span_warning("You extend the breaker's wire from your arm."))

/obj/item/gun/magic/wire
	name = "grappling wire"
	desc = "A combat-ready cable usable for closing the distance, bringing you to walls and heavy enemies you hit or bringing lighter ones to you."
	ammo_type = /obj/item/ammo_casing/magic/wire
	icon_state = "hook"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
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
	user.throw_at(get_step_towards(target,user), 8, 4)

/obj/item/projectile/wire/on_hit(atom/target)
	var/mob/living/carbon/human/H = firer
	if(isobj(target))
		var/obj/item/I = target
		if(!I?.anchored)
			I.throw_at(get_step_towards(H,I), 8, 2)
			H.put_in_hands(I)
			I.visible_message(span_danger("[I] is pulled by [H]'s wire!"))
			return
		zip(H, target)
	if(isliving(target))
		var/mob/L = target
		if(!L.anchored)
			if(istype(H))
				L.visible_message(span_danger("[L] is pulled by [H]'s wire!"),span_userdanger("A wire grabs you and pulls you towards [H]!"))
				L.throw_at(get_step_towards(H,L), 8, 4)
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


/obj/effect/proc_holder/spell/targeted/buster/grap
	name = "Grapple"
	desc = "Prepare the claws for grabbing ."
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "lariat"
	charge_max = 70
	var/jumpdistance = 4

/obj/effect/proc_holder/spell/targeted/buster/grap/cast(list/targets, mob/living/user)
	playsound(user,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	do_after(user, 2 SECONDS, user, TRUE, stayStill = FALSE)
	user.put_in_r_hand(new /obj/item/graphand)
	user.visible_message(span_warning("[user]'s arm begins crackling loudly!"))

/obj/item/graphand
	name = "supercharged emitter"
	desc = "The result of all the prosthetic's power building up in its palm. It's fading fast."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "flagellation"
	item_state = "hivehand"
	color = "#04b8ff"
	item_flags = DROPDEL
	w_class = 5

/obj/item/graphand/afterattack(mob/living/L, mob/living/user, proximity)
	var/turf/Z = get_turf(user)
	var/obj/structure/bed/F = new(Z, user)
	walk_towards(F,user,0, 2)
	L.buckle_mob(F)

/obj/item/graphand/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	animate(src, alpha = 50, time = 5 SECONDS)
	QDEL_IN(src, 5 SECONDS)
			
/obj/effect/proc_holder/spell/targeted/buster/mop
	name = "Mop the Floor"
	desc = "Launch forward and drag whoever's in front of you on the ground. The power of this move increases with closeness to the target upon using it."
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "mop"
	charge_max = 70	
	var/jumpdistance = 4

/obj/effect/proc_holder/spell/targeted/buster/mop/cast(atom/target,mob/living/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	var/obj/effect/temp_visual/decoy/fading/threesecond/F = new(Z, user)
	var/list/mopped = list()
	user.visible_message(span_warning("[user] sprints forward with [user.p_their()] hand outstretched!"))
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)
	for(var/i = 0 to jumpdistance)
		if(T.density)
			return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				return
		if(T)
			sleep(0.1 SECONDS)
			user.forceMove(T)
			walk_towards(F,user,0, 1.5)
			animate(F, alpha = 0, color = "#d40a0a", time = 0.3 SECONDS)
			for(var/mob/living/L in T.contents)
				if(L != user)
					mopped |= L
					var/turf/Q = get_step(get_turf(user), user.dir)
					var/mob/living/U = user
					animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
					if(Q.density)
						return
					for(var/obj/D in Q.contents)
						if(D.density == TRUE)
							D.take_damage(400)
					U.forceMove(get_turf(L))
					to_chat(L, span_userdanger("[U] catches you with [U.p_their()] hand and drags you down!"))
					U.visible_message(span_warning("[U] hits [L] and drags them through the dirt!"))
					L.forceMove(Q)
					if(iscarbon(L))
						L.apply_damage(6, BRUTE, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST), wound_bonus = CANT_WOUND)	
					if(issilicon(L))
						L.adjustBruteLoss(7)
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(user,user.dir)
	for(var/mob/living/C in mopped)
		if(C.stat == CONSCIOUS && C.resting == FALSE)
			animate(C, transform = null, time = 0.5 SECONDS, loop = 0)

/obj/effect/proc_holder/spell/targeted/buster/suplex
	name = "Suplex"
	desc = "Grab the target in front of you and slam them back onto the ground."
	action_icon = 'icons/mob/actions/actions_arm.dmi'	
	action_icon_state = "suplex"
	charge_max = 5

/obj/effect/proc_holder/spell/targeted/buster/suplex/cast(atom/target,mob/living/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	user.visible_message(span_warning("[user] outstretches [user.p_their()] arm and goes for a grab!"))
	for(var/mob/living/L in T.contents)
		var/turf/Q = get_step(get_turf(user), turn(user.dir,180))
		if(Q.density)
			to_chat(user, span_warning("[user] turns around and slams [L] against [Q]!"))
			L.apply_damage(10, BRUTE, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST), wound_bonus = CANT_WOUND)
			L.forceMove(Z)
			return
		for(var/obj/D in Q.contents)
			if(D.density == TRUE)
				user.visible_message(span_warning("[user] turns around and slams [L] against [D]!"))
				L.apply_damage(8, BRUTE, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST), wound_bonus = CANT_WOUND)
				D.take_damage(400)
		for(var/mob/living/M in Q.contents)
			if(isanimal(L))
				M.adjustBruteLoss(20)
			if(iscarbon(L))
				M.adjustBruteLoss(10)		
			user.visible_message(span_warning("[L] slams into [M]!"))
		L.forceMove(Q)
		playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
		playsound(user,'sound/effects/gravhit.ogg', 20, 1)
		to_chat(L, span_userdanger("[user] catches you with [user.p_their()] hand and crushes you on the ground!"))
		user.visible_message(span_warning("[user] turns around and slams [L] against the ground!"))
		user.setDir(turn(user.dir,180))
		animate(L, transform = matrix(179, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
		if(isanimal(L))
			L.adjustBruteLoss(20)
			if(L.stat == DEAD)
				L.visible_message(span_warning("[L] explodes into gore on impact!"))
				L.gib()
		if(iscarbon(L))
			L.adjustBruteLoss(15)
		if(issilicon(L))
			L.adjustBruteLoss(20)
		sleep(0.5 SECONDS)
		if(L.stat == CONSCIOUS && L.resting == FALSE)
			animate(L, transform = null, time = 0.1 SECONDS, loop = 0)
		
/obj/effect/proc_holder/spell/targeted/buster/chargedfist
	name = "Right Hook"
	desc = "Put the arm through its paces, cranking the outputs located at the front and back of the hand to full capacity for a powerful blow. This attack can only be readied for five seconds and connecting with it will temporarily overwhelm the entire arm for fifteen."
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "ponch"
	charge_max = 30

/obj/effect/proc_holder/spell/targeted/buster/chargedfist/cast(list/targets, mob/living/user)
	playsound(user,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	do_after(user, 2 SECONDS, user, TRUE, stayStill = FALSE)
	user.put_in_r_hand(new /obj/item/bigpunch)
	user.visible_message(span_warning("[user]'s arm begins crackling loudly!"))

/obj/item/bigpunch
	name = "supercharged emitter"
	desc = "The result of all the prosthetic's power building up in its palm. It's fading fast."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "flagellation"
	item_state = "hivehand"
	color = "#04b8ff"
	item_flags = DROPDEL
	w_class = 5
	var/flightdist = 8

/obj/item/bigpunch/afterattack(mob/living/L, mob/living/user, proximity)
	var/direction = user.dir
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	var/list/knockedback = list()
	if(!proximity)
		return
	if(!isliving(L))
		return
	if(L == user)
		return
	if(isliving(L))
		qdel(src, force = TRUE)
		L.SpinAnimation(0.5 SECONDS, 2)
		playsound(L,'sound/effects/gravhit.ogg', 60, 1)
		(R?.set_disabled(TRUE))
		to_chat(user, span_warning("The huge impact takes the arm out of commission!"))
		shake_camera(L, 4, 3)
		shake_camera(user, 2, 3)
		addtimer(CALLBACK(R, /obj/item/bodypart/r_arm/.proc/set_disabled), 15 SECONDS, TRUE)
		to_chat(L, span_userdanger("[user] hits you with a blast of energy and sends you flying!"))
		user.visible_message(span_warning("[user] blasts [L] with a surge of energy and sends [L.p_them()] flying!"))
		knockedback |= L
	if(iscarbon(L))
		L.adjustBruteLoss(15)
	if(isanimal(L))
		if(istype(L, /mob/living/simple_animal/hostile/guardian))
			L.adjustBruteLoss(40)
		else
			L.adjustBruteLoss(100)
	if(issilicon(L))
		L.adjustBruteLoss(18)
	for(var/i = 2 to flightdist)
		var/turf/T = get_ranged_target_turf(user, direction, i)
		if(ismineralturf(T))
			var/turf/closed/mineral/M = T
			M.attempt_drill()
			L.adjustBruteLoss(5)
		if(T.density)
			for(var/mob/living/simple_animal/S in knockedback)
				if(S.stat == DEAD)
					S.gib()
			return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				D.take_damage(400)
				for(var/mob/living/S in knockedback)
					S.apply_damage(15, BRUTE, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST), wound_bonus = CANT_WOUND)
					if(S.stat == DEAD && !ishuman(S))
						S.visible_message(span_warning("[L] crashes and explodes!"))
						S.gib()
		if(T)
			for(var/mob/living/M in T.contents)
				knockedback |= M	
				if(iscarbon(M))
					M.adjustBruteLoss(15)
				if(isanimal(M))
					M.adjustBruteLoss(30)
				if(issilicon(M))
					M.adjustBruteLoss(20)
			for(var/mob/living/S in knockedback)
				S.forceMove(T)
				S.SpinAnimation(0.2 SECONDS, 1)
				sleep(0.001 SECONDS)

/obj/item/bigpunch/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	animate(src, alpha = 50, time = 5 SECONDS)
	QDEL_IN(src, 5 SECONDS)

//buster Arm
/obj/item/bodypart/r_arm/robot/buster
	name = "buster right arm"
	desc = "A robotic arm adorned with subwoofers capable of emitting shockwaves to imitate strength."
	icon = 'icons/mob/augmentation/augments_seismic.dmi'
	icon_state = "seismic_r_arm"
	max_damage = 60

/obj/item/bodypart/r_arm/robot/buster/attach_limb(mob/living/carbon/C, special)
	. = ..()
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/wire_snatch)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/grap)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/mop)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/suplex)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/buster/chargedfist)

/obj/item/bodypart/r_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/C = owner
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/wire_snatch)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/grap)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/mop)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/suplex)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/buster/chargedfist)
	..()

/obj/item/bodypart/r_arm/robot/buster/attack(mob/living/L, proximity)
	if(!proximity)
		return
	if(!ishuman(L))
		return
	attach_limb(L)
