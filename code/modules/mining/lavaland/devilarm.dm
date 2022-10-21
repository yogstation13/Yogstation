/obj/effect/proc_holder/spell/targeted/lariat
	name = "Lariat"
	desc = "Dash forward, catching whatever animal you hit with the crux of your elbow and knocking them over."
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	clothes_req = FALSE
	include_user = TRUE
	range = -1
	charge_max = 70
	cooldown_min = 50
	var/jumpdistance = 4

/obj/effect/proc_holder/spell/targeted/lariat/cast(atom/target,mob/living/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return
	user.visible_message(span_warning("[user] sprints forward with [user.p_their()] arm outstretched!"))
	new /obj/effect/temp_visual/decoy/fading(loc, user)
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)
	for(var/i = 0 to jumpdistance)
		if(T.density)
			return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				return
		for(var/turf/open/chasm/C in T.contents)
			return
		for(var/turf/closed/indestructible/I in T.contents)
			return
		for(var/turf/open/lava/V in T.contents)
			return
		for(var/obj/machinery/door/window/E in Z.contents)
			if(E.density == TRUE)
				return 
		if(T)
			sleep(0.1 SECONDS)
			user.forceMove(T)
			for(var/mob/living/L in T.contents)
				if(L != user)
					user.forceMove(get_turf(L))
					to_chat(L, span_userdanger("[user] catches you with [user.p_their()] arm and clotheslines you!"))
					user.visible_message(span_warning("[user] hits [L] with a lariat!"))
					L.SpinAnimation(0.5 SECONDS, 1)
					if(isanimal(L))
						L.adjustBruteLoss(50)
					if(iscarbon(L))
						L.adjustBruteLoss(10)
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(user,user.dir)

/obj/effect/proc_holder/spell/targeted/mop
	name = "Mop the Floor"
	desc = "Dash forward, catching whatever animal you hit with your hellish hand, grinding them against the ground. The power of this move increases with closeness to the target upon using it."
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	clothes_req = FALSE
	include_user = TRUE
	range = -1
	charge_max = 70
	cooldown_min = 50
	var/jumpdistance = 4

/obj/effect/proc_holder/spell/targeted/mop/cast(atom/target,mob/living/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return
	user.visible_message(span_warning("[user] sprints forward with [user.p_their()] hand outstretched!"))
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)
	for(var/i = 0 to jumpdistance)
		if(T.density)
			return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				return
		for (var/turf/open/chasm/C in T.contents)
			return
		for (var/turf/closed/indestructible/I in T.contents)
			return
		for(var/obj/machinery/door/window/E in Z.contents)
			if(E.density == TRUE)
				return 
		if(T)
			sleep(0.1 SECONDS)
			user.forceMove(T)
			for(var/mob/living/L in T.contents)
				if(L != user)
					var/turf/Q = get_step(get_turf(user), user.dir)
					var/mob/living/U = user
					animate(L, transform = matrix(90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = 0)
					if(ismineralturf(Q))
						var/turf/closed/mineral/M = Q
						M.attempt_drill()
						L.adjustBruteLoss(5)
					if(Q.density)
						return
					for(var/obj/D in Q.contents)
						if(D.density == TRUE)
							return
					U.forceMove(get_turf(L))
					to_chat(L, span_userdanger("[U] catches you with [U.p_their()] hand and drags you down!"))
					U.visible_message(span_warning("[U] hits [L] and drags them through the dirt!"))
					L.forceMove(Q)
					if(isanimal(L))
						U.apply_status_effect(STATUS_EFFECT_BLOODDRUNK)//guaranteed extended contact with a fauna so i have to make it not a death sentence
						L.adjustBruteLoss(20)
					if(iscarbon(L))
						L.adjustBruteLoss(5)
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
					animate(L, transform = null, time = 0.2 SECONDS, loop = 0)
			T = get_step(user,user.dir)

/obj/effect/proc_holder/spell/targeted/slam
	name = "Slam"
	desc = "Grab the target in front of you and toss them back onto the ground."
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	clothes_req = FALSE
	include_user = TRUE
	range = -1
	charge_max = 10
	cooldown_min = 50


/obj/effect/proc_holder/spell/targeted/slam/cast(atom/target,mob/living/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return
	user.visible_message(span_warning("[user] outstretches [user.p_their()] arm and goes for a grab!"))
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)
	for(var/mob/living/L in T.contents)
		var/turf/Q = get_step(get_turf(user), turn(user.dir,180))
		if(ismineralturf(Q))
			var/turf/closed/mineral/M = Q
			M.attempt_drill()
			L.adjustBruteLoss(5)
		if(Q.density)
			return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				return
		for (var/turf/open/chasm/C in Q.contents)
			return
		for (var/turf/open/lava/V in Q.contents)
			return
		for(var/obj/machinery/door/window/E in Z.contents)
			if(E.density == TRUE)
				return 
		for(var/mob/living/simple_animal/M in Q.contents)
			if(isanimal(L))
				M.adjustBruteLoss(20)
			if(iscarbon(L))
				M.adjustBruteLoss(10)		
			user.visible_message(span_warning("[L] slams into [M]!"))
		L.forceMove(Q)
		playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
		to_chat(L, span_userdanger("[user] catches you with [user.p_their()] hand and crushes you on the ground!"))
		user.visible_message(span_warning("[user] turns around and slams [L] against the ground!"))
		user.setDir(turn(user.dir,180))
		if(isanimal(L))
			L.adjustBruteLoss(20)
		if(iscarbon(L))
			L.adjustBruteLoss(10)
		
/obj/effect/proc_holder/spell/targeted/righthook
	name = "Right Hook"
	desc = "Put the arm through its paces, cranking the outputs located at the front and back of the hand to full capacity for a powerful blow. This attack can only be readied for a few seconds and connecting with it will temporarily overwhelm the entire arm."
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	clothes_req = FALSE
	include_user = TRUE
	range = -1
	charge_max = 30
	cooldown_min = 50
	recharging = TRUE
	clothes_req = FALSE

/obj/effect/proc_holder/spell/targeted/righthook/cast(list/targets, mob/living/user)
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return
	playsound(user,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	do_after(user, 2 SECONDS, user, TRUE, stayStill = FALSE)
	user.put_in_r_hand(new /obj/item/overcharged_emitter)
	user.visible_message(span_warning("[user]'s arm begins crackling loudly!"))

/obj/item/overcharged_emitter
	name = "dark bead"
	desc = "The result of all the prosthetic's power building up in its palm. It's fading fast."
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "dark_bead"
	item_state = "disintegrate"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE 
	item_flags = DROPDEL
	w_class = 5
	light_color = "#21007F"
	light_power = 0.3
	light_range = 2

/obj/item/overcharged_emitter/afterattack(mob/living/L, mob/living/user, proximity)
	var/flightdist = 8
	var/direction = user.dir
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
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
	if(iscarbon(L))
		L.adjustBruteLoss(15)
	if(isanimal(L))
		L.adjustBruteLoss(100)
	for(var/i = 2 to flightdist)
		var/turf/T = get_ranged_target_turf(user, direction, i)
		if(ismineralturf(T))
			var/turf/closed/mineral/M = T
			M.attempt_drill()
			L.adjustBruteLoss(5)
		if(T.density)
			return
		for(var/obj/D in T.contents)
			if(D.density == TRUE)
				return
		if(T)
			L.forceMove(T)
			sleep(0.1 SECONDS)
	sleep(15 SECONDS)
	(R?.set_disabled(FALSE))
	to_chat(user, span_warning("The arm has finished recalibrating itself!"))

/obj/item/overcharged_emitter/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	animate(src, alpha = 50, time = 5 SECONDS)
	QDEL_IN(src, 5 SECONDS)

//Demon Arm
/obj/item/bodypart/r_arm/robot/devil
	name = "pulsar right arm"
	desc = "A robotic arm adorned with subwoofers capable of emitting shockwaves to create a facsimile of strength."
	max_damage = 60

/obj/item/bodypart/r_arm/robot/devil/attach_limb(mob/living/carbon/C, special)
	. = ..()
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/lariat)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/mop)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/slam)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/righthook)

/obj/item/bodypart/r_arm/robot/devil/drop_limb(special)
	var/mob/living/carbon/C = owner
	..()
