/datum/action/cooldown/spell/pointed/seismic
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/pointed/seismic/can_cast_spell(feedback = TRUE)
	if(!isliving(owner))
		return FALSE
	var/mob/living/user = owner
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	if(user.IsParalyzed() || user.IsStun() || user.restrained())
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/seismic/proc/check_turf(turf/turf_to_check)
	if(turf_to_check.density)
		return FALSE
	if(ischasm(turf_to_check))
		return FALSE
	if(isindestructiblewall(turf_to_check))
		return FALSE
	if(islava(turf_to_check))
		return FALSE
	for(var/obj/object in turf_to_check.contents)
		if(object.density)
			return FALSE
	return TRUE

#define LARIAT_JUMP_DISTANCE 4

/datum/action/cooldown/spell/pointed/seismic/lariat
	name = "Lariat"
	desc = "Dash forward, catching whatever animal you hit with your arm and knocking them over."
	button_icon = 'icons/mob/actions/actions_arm.dmi'
	button_icon_state = "lariat"

	cooldown_time = 7 SECONDS

/datum/action/cooldown/spell/pointed/seismic/lariat/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/turf/turf_ahead = get_step(get_turf(user), user.dir)
	var/obj/effect/temp_visual/decoy/fading/threesecond/followup_effect = new(get_turf(user), user)
	user.visible_message(span_warning("[user] sprints forward with [user.p_their()] arm outstretched!"))
	playsound(user,'sound/effects/gravhit.ogg', 20, TRUE)
	for(var/i = 0 to LARIAT_JUMP_DISTANCE)
		if(!check_turf(turf_ahead))
			return TRUE //TRUE as in: start cooldown
		user.forceMove(turf_ahead)
		walk_towards(followup_effect, user, 0, 1.5)
		animate(followup_effect, alpha = 0, color = "#00d9ff", time = 0.3 SECONDS)
		for(var/mob/living/assaulted in turf_ahead.contents)
			if(assaulted != user)
				user.forceMove(get_turf(assaulted))
				to_chat(assaulted, span_userdanger("[user] catches you with [user.p_their()] arm and clotheslines you!"))
				user.visible_message(span_warning("[user] hits [assaulted] with a lariat!"))
				assaulted.SpinAnimation(0.5 SECONDS, 1)
				if(isanimal(assaulted))
					assaulted.adjustBruteLoss(50)
				if(iscarbon(assaulted))
					assaulted.adjustBruteLoss(10)
				if(issilicon(assaulted))
					assaulted.adjustBruteLoss(12)
			playsound(assaulted,'sound/effects/meteorimpact.ogg', 60, 1)
		turf_ahead = get_step(turf_ahead, user.dir)
	
	return TRUE
			
#undef LARIAT_JUMP_DISTANCE

#define MOP_JUMP_DISTANCE 4

/datum/action/cooldown/spell/pointed/seismic/mop
	name = "Mop the Floor"
	desc = "Launch forward and drag whoever's in front of you on the ground. The power of this move increases with closeness to the target upon using it."
	button_icon = 'icons/mob/actions/actions_arm.dmi'
	button_icon_state = "mop"
	
	cooldown_time = 7 SECONDS

/datum/action/cooldown/spell/pointed/seismic/mop/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/turf/turf_ahead = get_step(get_turf(user), user.dir)
	var/obj/effect/temp_visual/decoy/fading/threesecond/followup_effect = new(get_turf(user), user)
	user.visible_message(span_warning("[user] sprints forward with [user.p_their()] hand outstretched!"))
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)
	for(var/i = 0 to MOP_JUMP_DISTANCE)
		if(!check_turf(turf_ahead))
			return TRUE
		user.forceMove(turf_ahead)
		walk_towards(followup_effect, user, 0, 1.5)
		animate(followup_effect, alpha = 0, color = "#00d9ff", time = 0.3 SECONDS)
		var/list/mopped = list()
		for(var/mob/living/L in turf_ahead.contents)
			if(L != user)
				mopped |= L
				var/turf/Q = get_step(get_turf(user), user.dir)
				animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
				if(ismineralturf(Q))
					var/turf/closed/mineral/M = Q
					M.attempt_drill()
					L.adjustBruteLoss(5)
				if(Q.density)
					return FALSE
				for(var/obj/D in Q.contents)
					if(D.density)
						return FALSE
				user.forceMove(get_turf(L))
				to_chat(L, span_userdanger("[user] catches you with [user.p_their()] hand and drags you down!"))
				user.visible_message(span_warning("[user] hits [L] and drags them through the dirt!"))
				L.forceMove(Q)
				if(isanimal(L))
					user.apply_status_effect(STATUS_EFFECT_BLOODDRUNK)//guaranteed extended contact with a fauna so i have to make it not a death sentence
					L.adjustBruteLoss(20)
					if(L.stat == DEAD)
						L.visible_message(span_warning("[L] is ground into paste!"))
						L.gib()
				if(iscarbon(L))
					L.adjustBruteLoss(4)
				if(issilicon(L))
					L.adjustBruteLoss(5)
				playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
		turf_ahead = get_step(turf_ahead, user.dir)
		for(var/mob/living/C in mopped)
			if(C.stat == CONSCIOUS && C.resting == FALSE)
				animate(C, transform = null, time = 0.5 SECONDS, loop = 0)

	return TRUE

#undef MOP_JUMP_DISTANCE

/datum/action/cooldown/spell/pointed/seismic/suplex
	name = "Suplex"
	desc = "Grab the target in front of you and slam them back onto the ground."
	button_icon = 'icons/mob/actions/actions_arm.dmi'	
	button_icon_state = "suplex"

	cooldown_time = 1 SECONDS

/datum/action/cooldown/spell/pointed/seismic/suplex/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	user.visible_message(span_warning("[user] outstretches [user.p_their()] arm and goes for a grab!"))
	for(var/mob/living/L in T.contents)
		var/turf/Q = get_step(get_turf(user), turn(user.dir,180))
		if(ismineralturf(Q))
			var/turf/closed/mineral/M = Q
			M.attempt_drill()
			L.adjustBruteLoss(5)
		if(Q.density)
			to_chat(user, span_warning("There's no room to do this!"))
			return
		for(var/obj/D in Q.contents)
			if(D.density == TRUE)
				to_chat(user, span_warning("There's no room to do this!"))
				return
		for(var/obj/machinery/door/window/E in Z.contents)
			if(E.density == TRUE)
				return 
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
			L.adjustBruteLoss(6)
		if(issilicon(L))
			L.adjustBruteLoss(8)
		addtimer(CALLBACK(src, PROC_REF(fix_target_anim), L), 0.5 SECONDS)
		
	return TRUE

/datum/action/cooldown/spell/pointed/seismic/suplex/proc/fix_target_anim(mob/living/target)
	if(target.stat == CONSCIOUS && target.resting == FALSE)
		animate(target, transform = null, time = 0.1 SECONDS, loop = 0)

/datum/action/cooldown/spell/touch/righthook
	name = "Right Hook"
	desc = "Put the arm through its paces, cranking the outputs located at the front and back of the hand to full capacity for a powerful blow. This attack can only be readied for five seconds and connecting with it will temporarily overwhelm the entire arm for fifteen."
	button_icon = 'icons/mob/actions/actions_arm.dmi'
	button_icon_state = "ponch"

	cooldown_time = 3 SECONDS

	sound = 'sound/effects/gravhit.ogg'
	draw_message = span_notice("Your arm begins crackling loudly!")
	drop_message = span_notice("You dissipate the power in your hand.")

	spell_requirements = SPELL_REQUIRES_HUMAN

	hand_path = /obj/item/melee/touch_attack/overcharged_emitter

/datum/action/cooldown/spell/touch/righthook/can_cast_spell(feedback = TRUE)
	if(!isliving(owner))
		return FALSE
	var/mob/living/user = owner
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	if(user.IsParalyzed() || user.IsStun() || user.restrained())
		return FALSE
	return TRUE

/obj/item/melee/touch_attack/overcharged_emitter
	name = "supercharged emitter"
	desc = "The result of all the prosthetic's power building up in its palm. It's fading fast."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "flagellation"
	item_state = "hivehand"
	color = "#04b8ff"
	item_flags = DROPDEL
	w_class = 5
	var/flightdist = 8

/obj/item/melee/touch_attack/overcharged_emitter/afterattack(mob/living/L, mob/living/user, proximity)
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
		R?.set_disabled(TRUE)
		to_chat(user, span_warning("The huge impact takes the arm out of commission!"))
		shake_camera(L, 4, 3)
		shake_camera(user, 2, 3)
		addtimer(CALLBACK(R, TYPE_PROC_REF(/obj/item/bodypart/r_arm, set_disabled)), 15 SECONDS, TRUE)
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
	var/turf/P = get_turf(user)
	for(var/i = 2 to flightdist)
		var/turf/T = get_ranged_target_turf(P, direction, i)
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
				for(var/mob/living/simple_animal/S in knockedback)
					if(S.stat == DEAD)
						S.visible_message(span_warning("[S] crashes and explodes!"))
						S.gib()
				return
		if(T)
			for(var/mob/living/M in T.contents)
				knockedback |= M	
				if(iscarbon(M))
					M.adjustBruteLoss(10)
				if(isanimal(M))
					M.adjustBruteLoss(30)
				if(issilicon(M))
					M.adjustBruteLoss(11)
			for(var/mob/living/S in knockedback)
				S.forceMove(T)
				S.SpinAnimation(0.2 SECONDS, 1)

/obj/item/melee/touch_attack/overcharged_emitter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	animate(src, alpha = 50, time = 5 SECONDS)
	QDEL_IN(src, 5 SECONDS)

/obj/item/melee/touch_attack/overcharged_emitter/Destroy()
	var/datum/action/cooldown/spell/our_spell = spell_which_made_us?.resolve()
	if(our_spell)
		our_spell.build_all_button_icons()
	return ..()

//Seismic Arm
/obj/item/bodypart/r_arm/robot/seismic
	name = "seismic right arm"
	desc = "A robotic arm adorned with subwoofers capable of emitting shockwaves to imitate strength."
	icon = 'icons/mob/augmentation/augments_seismic.dmi'
	icon_state = "seismic_r_arm"
	max_damage = 60
	var/list/seismic_arm_moves = list(
		/datum/action/cooldown/spell/pointed/seismic/lariat,
		/datum/action/cooldown/spell/pointed/seismic/mop,
		/datum/action/cooldown/spell/pointed/seismic/suplex,
		/datum/action/cooldown/spell/touch/righthook,
	)

/obj/item/bodypart/r_arm/robot/seismic/attach_limb(mob/living/carbon/C, special)
	. = ..()
	for(var/datum/action/cooldown/spell/moves as anything in seismic_arm_moves)
		moves = new moves(C)
		moves.Grant(C)

/obj/item/bodypart/r_arm/robot/seismic/drop_limb(special)
	var/mob/living/carbon/C = owner
	for(var/datum/action/cooldown/spell/moves in C.actions)
		if(LAZYFIND(seismic_arm_moves, moves))
			moves.Remove(C)
	return ..()
