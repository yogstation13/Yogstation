/* Formatting for these files, from top to bottom:
	* Action
	* Trigger()
	* IsAvailable(feedback = FALSE)
	* Items
	In regards to actions or items with left and right subtypes, list the base, then left, then right.
*/

/obj/item/megabuster
	item_flags = DROPDEL
	w_class = 5
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'

/obj/item/megabuster/Initialize(mapload, mob/living/user)
	. = ..()
	ADD_TRAIT(src, HAND_REPLACEMENT_TRAIT, NOBLUDGEON)

/// Item counterpart to the action's grab(), applies damage
/obj/item/megabuster/proc/hit(mob/living/user, mob/living/target, damage)
		var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
		var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

//knocking them down
/datum/action/cooldown/buster/proc/footsies(mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		animate(target, transform = matrix(90, MATRIX_ROTATE), time = 0 SECONDS, loop = 0)

//standing them back up if appropriate
/datum/action/cooldown/buster/proc/wakeup(mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		animate(target, transform = null, time = 0.4 SECONDS, loop = 0)


/datum/action/cooldown/buster
	check_flags = AB_CHECK_HANDS_BLOCKED| AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	transparent_when_unavailable = TRUE
	button_icon = 'icons/mob/actions/actions_arm.dmi'


/datum/action/cooldown/buster/IsAvailable(feedback = FALSE)
	. = ..()
	if(!isliving(owner))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_PACIFISM))
		return FALSE


/datum/action/cooldown/buster/megabuster
	name = "Mega Buster"
	desc = "Put the buster arm through its paces to gain extreme power for five seconds. Connecting the blow will devastate the target and send them flying, taking others with \
	them and sending them through walls."
	button_icon_state = "ponch"
	cooldown_time = 20 SECONDS

///left hand
/datum/action/cooldown/buster/megabuster/l/Activate()
	var/obj/item/megabuster/B = new()
	owner.visible_message(span_userdanger("[owner]'s left arm begins crackling loudly!"))
	playsound(owner,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	if(do_after(owner, 2 SECONDS, owner, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		if(!owner.put_in_l_hand(B))
			to_chat(owner, span_warning("You can't do this with your left hand full!"))
		else
			owner.visible_message(span_danger("[owner]'s arm begins shaking violently!"))
			if(owner.active_hand_index % 2 == 0)
				owner.swap_hand(0)
			StartCooldown()

///right hand
/datum/action/cooldown/buster/megabuster/r/Activate()
	var/obj/item/megabuster/B = new()
	owner.visible_message(span_userdanger("[owner]'s right arm begins crackling loudly!"))
	playsound(owner,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	if(do_after(owner, 2 SECONDS, owner, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		if(!owner.put_in_r_hand(B))
			to_chat(owner, span_warning("You can't do this with your right hand full!"))
		else
			owner.visible_message(span_danger("[owner]'s arm begins shaking violently!"))
			if(owner.active_hand_index % 2 == 1)
				owner.swap_hand(0)
			StartCooldown()

/datum/action/cooldown/buster/megabuster/l/IsAvailable(feedback = FALSE)
	var/mob/living/O = owner
	var/obj/item/bodypart/l_arm/L = O.get_bodypart(BODY_ZONE_L_ARM)
	if(L?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	return ..()

/datum/action/cooldown/buster/megabuster/r/IsAvailable(feedback = FALSE)
	var/mob/living/O = owner
	var/obj/item/bodypart/r_arm/R = O.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(owner, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	return ..()


/obj/item/megabuster
	name = "supercharged fist"
	desc = "The result of all the prosthetic's power building up. It's fading fast."
	icon = 'icons/obj/weapons/hand.dmi'
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
	var/anchoredthingdam = 50
	var/list/snowballcontents = list()


/obj/item/megabuster/ignition_effect(atom/A, mob/user)
	playsound(user,'sound/misc/fingersnap1.ogg', 20, 1)
	playsound(user,'sound/effects/sparks4.ogg', 20, 1)
	do_sparks(5, TRUE, src)
	. = span_rose("With a snap, [user] sets [A] alight with sparks from [user.p_their()] metal fingers.")


/obj/item/megabuster/Initialize(mapload, mob/living/user)
	. = ..()
	animate(src, alpha = 50, time = 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(store), user), 5 SECONDS)

/obj/item/megabuster/proc/store(mob/living/user)
	src.forceMove(user) //putting it back in ur pocket for later to avoid addtimer runtimes
	QDEL_IN(src, 2 SECONDS)


/obj/item/megabuster/afterattack(atom/target, mob/living/user, proximity)
	if(isopenturf(target) || iseffect(target) || !proximity || (target == user))
		return
	snowballcontents |= target
	user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
	playsound(target, 'sound/effects/gravhit.ogg', 60, 1)
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		if(istype(W, /turf/closed/wall/r_wall))
			W.dismantle_wall(1)
			store(user) // no breaking more than one rwall
		else
			W.dismantle_wall(1)
		user.visible_message(span_warning("[user] demolishes [W]!"))
		return
	if(ismecha(target)) 
		var/obj/mecha/A = target
		A.take_damage(mechdam) 
		user.visible_message(span_warning("[user] crushes [target]!"))
		store(user) // no instant durand obliteration i fear
	if(isstructure(target) || ismachinery(target))
		user.visible_message(span_warning("[user] strikes [target]!"))
		var/obj/I = target
		if(I.anchored == TRUE)
			I.take_damage(objdam)
			return
		I.take_damage(50)
	if(isitem(target))
		var/obj/I = target
		if(!isturf(I.loc))
			if(!istype(I, /obj/item/clothing/mask/cigarette))
				to_chat(user, span_warning("You probably shouldn't attack something on your person."))
			return
		if(!istype(I, /obj/item/organ/brain) && !istype(I, /obj/item/clothing/mask/cigarette))
			user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
			I.take_damage(objdam)
			user.visible_message(span_warning("[user] pulverizes [I]!"))
		return
	if(ismovable(target))
		for(var/mob/M in view(7, user))
			shake_camera(M, 2, 3)
		if(isobj(target))
			var/obj/snowball = target
			snowball.SpinAnimation(0.5 SECONDS, 2)
			addtimer(CALLBACK(src, PROC_REF(fly), user, snowball, user.dir, flightdist))
			return
		if(isliving(target))
			var/mob/living/L = target
			to_chat(L, span_userdanger("[user] hits you with a blast of energy and sends you flying!"))
			if(prob(5))
				if(prob(50))
					user.say("FUCK YOU!!")
				else
					user.say("JACKPOT!!")
			var/obj/item/bodypart/limb_to_hit = L.get_bodypart(user.zone_selected)
			var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
			store(user) 
			L.apply_damage(punchdam, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND) 
			if(!limb_to_hit)
				limb_to_hit = L.get_bodypart(BODY_ZONE_CHEST)
			if(iscarbon(L))
				if(limb_to_hit.brute_dam == limb_to_hit.max_damage) 
					if(istype(limb_to_hit, /obj/item/bodypart/chest))
						to_chat(L, span_userdanger("[user] hits you with a blast of energy and sends you flying!"))
						if(!istype(limb_to_hit, /obj/item/bodypart/head))
							user.visible_message(span_warning("[user] blasts [L] with a surge of energy and sends [L.p_them()] flying!"))
						else
							user.visible_message(span_warning("[user] smashes [user.p_their()] fist upwards into [L]'s jaw, sending [L.p_them()] flying!"))//slicer's request
					else 
						var/atom/throw_target = get_edge_target_turf(L, user.dir)
						to_chat(L, span_userdanger("[user] blows [limb_to_hit] off with inhuman force!"))
						user.visible_message(span_warning("[user] punches [limb_to_hit] clean off!"))
						limb_to_hit.drop_limb()
						limb_to_hit.throw_at(throw_target, 8, 4, user, 3)
						L.Paralyze(3 SECONDS)
						return 
			L.SpinAnimation(0.5 SECONDS, 2)
			addtimer(CALLBACK(src, PROC_REF(fly), user, L, user.dir, flightdist))


/obj/item/megabuster/proc/fly(mob/living/user, atom/movable/ball, dir, triplength = 0)
	if(triplength == 0)
		for(var/atom/movable/I in snowballcontents)
			snowballcontents.Remove(I)
		return
	var/turf/Q = get_step(get_turf(ball), dir)
	var/turf/current = (get_turf(ball))
	for(var/atom/speedbump in Q.contents)
		if(isitem(speedbump) || !ismovable(speedbump) || !(speedbump.density))
			continue
		var/atom/movable/H = speedbump
		if(isobj(H) && H.density)
			var/obj/O = H
			O.take_damage(objcolldam)
			if(O.anchored == TRUE)
				O.take_damage(anchoredthingdam) // bonus damage for being a stubborn stupid door
				continue
			snowballcontents |= O
		if(isliving(H))
			hit(user, H, colldam)
			snowballcontents |= H
		for(var/atom/movable/T in current.contents)
			if(isliving(T))
				hit(user, T, hitobjdam)
			if(isobj(T))
				T.take_damage(objcolldam)
		H.forceMove(current) // so the speedbump joins the snowball instead of working as intended
	if(Q.density) 
		var/turf/closed/wall/W = Q
		for(var/obj/J in current)
			J.take_damage(objcolldam)
		for(var/mob/living/S in current)
			hit(user, S, colldam)
			S.Knockdown(1.5 SECONDS)
			S.Immobilize(1.5 SECONDS)
			if(isanimal(S) && S.stat == DEAD)
				S.gib()
		if(!istype(W, /turf/closed/wall/r_wall))
			playsound(W,'sound/effects/meteorimpact.ogg', 50, 1)
			W.dismantle_wall(1)
	for(var/atom/movable/I in snowballcontents)
		I.forceMove(current)
	if(Q.density)
		for(var/atom/movable/I in snowballcontents)
			snowballcontents.Remove(I)
		return
	for(var/atom/movable/T in snowballcontents)
		T.SpinAnimation(0.2 SECONDS, 1)
		if((!(Q.reachableTurftestdensity(T = Q))))
			for(var/atom/movable/I in snowballcontents)
				snowballcontents.Remove(I)
			return  
		T.forceMove(Q)
	addtimer(CALLBACK(src, PROC_REF(fly), user, ball, dir, triplength-1), 0.01 SECONDS)	

















