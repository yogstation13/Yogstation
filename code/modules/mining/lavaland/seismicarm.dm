/obj/effect/proc_holder/spell/targeted/seismic
	clothes_req = FALSE
	include_user = TRUE
	range = -1

/obj/effect/proc_holder/spell/targeted/seismic/can_cast(mob/living/user)
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(R?.bodypart_disabled)
		to_chat(user, span_warning("The arm isn't in a functional state right now!"))
		return FALSE
	if(user.IsParalyzed() || user.IsStun() || user.restrained())
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/targeted/seismic/lariat
	name = "Lariat"
	desc = "Dash forward, catching whatever animal you hit with your arm and knocking them over."
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "lariat"
	charge_max = 70
	var/jumpdistance = 4

/obj/effect/proc_holder/spell/targeted/seismic/lariat/cast(atom/target,mob/living/user)
	var/turf/T = get_step(get_turf(user), user.dir)
	var/turf/Z = get_turf(user)
	var/obj/effect/temp_visual/decoy/fading/threesecond/F = new(Z, user)
	user.visible_message(span_warning("[user] sprints forward with [user.p_their()] arm outstretched!"))
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
			walk_towards(F,user,0, 1.5)
			animate(F, alpha = 0, color = "#00d9ff", time = 0.3 SECONDS)
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
					if(issilicon(L))
						L.adjustBruteLoss(12)
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(user,user.dir)
			
/obj/effect/proc_holder/spell/targeted/seismic/mop
	name = "Mop the Floor"
	desc = "Launch forward and drag whoever's in front of you on the ground. The power of this move increases with closeness to the target upon using it."
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "mop"
	charge_max = 70	
	var/jumpdistance = 4

/obj/effect/proc_holder/spell/targeted/seismic/mop/cast(atom/target,mob/living/user)
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
			walk_towards(F,user,0, 1.5)
			animate(F, alpha = 0, color = "#00d9ff", time = 0.3 SECONDS)
			for(var/mob/living/L in T.contents)
				if(L != user)
					mopped |= L
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
						if(L.stat == DEAD)
							L.visible_message(span_warning("[L] is ground into paste!"))
							L.gib()
					if(iscarbon(L))
						L.adjustBruteLoss(4)
					if(issilicon(L))
						L.adjustBruteLoss(5)
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(user,user.dir)
	for(var/mob/living/C in mopped)
		if(C.stat == CONSCIOUS && C.resting == FALSE)
			animate(C, transform = null, time = 0.5 SECONDS, loop = 0)

/obj/effect/proc_holder/spell/targeted/seismic/suplex
	name = "Suplex"
	desc = "Grab the target in front of you and slam them back onto the ground."
	action_icon = 'icons/mob/actions/actions_arm.dmi'	
	action_icon_state = "suplex"
	charge_max = 10

/obj/effect/proc_holder/spell/targeted/seismic/suplex/cast(atom/target,mob/living/user)
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
		sleep(0.5 SECONDS)
		if(L.stat == CONSCIOUS && L.resting == FALSE)
			animate(L, transform = null, time = 0.1 SECONDS, loop = 0)
		
/obj/effect/proc_holder/spell/targeted/seismic/righthook
	name = "Right Hook"
	desc = "Put the arm through its paces, cranking the outputs located at the front and back of the hand to full capacity for a powerful blow. This attack can only be readied for five seconds and connecting with it will temporarily overwhelm the entire arm for fifteen."
	action_icon = 'icons/mob/actions/actions_arm.dmi'
	action_icon_state = "ponch"
	charge_max = 30

/obj/effect/proc_holder/spell/targeted/seismic/righthook/cast(list/targets, mob/living/user)
	playsound(user,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	do_after(user, 2 SECONDS, user, TRUE, stayStill = FALSE)
	user.put_in_r_hand(new /obj/item/overcharged_emitter)
	user.visible_message(span_warning("[user]'s arm begins crackling loudly!"))

/obj/item/overcharged_emitter
	name = "supercharged emitter"
	desc = "The result of all the prosthetic's power building up in its palm. It's fading fast."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "flagellation"
	item_state = "hivehand"
	color = "#04b8ff"
	item_flags = DROPDEL
	w_class = 5
	var/flightdist = 8

/obj/item/overcharged_emitter/afterattack(mob/living/L, mob/living/user, proximity)
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
				sleep(0.001 SECONDS)

/obj/item/overcharged_emitter/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	animate(src, alpha = 50, time = 5 SECONDS)
	QDEL_IN(src, 5 SECONDS)

//Seismic Arm
/obj/item/bodypart/r_arm/robot/seismic
	name = "seismic right arm"
	desc = "A robotic arm adorned with subwoofers capable of emitting shockwaves to imitate strength."
	icon = 'icons/mob/augmentation/augments_seismic.dmi'
	icon_state = "seismic_r_arm"
	max_damage = 60

/obj/item/bodypart/r_arm/robot/seismic/attach_limb(mob/living/carbon/C, special)
	. = ..()
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/seismic/lariat)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/seismic/mop)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/seismic/suplex)
	C.AddSpell (new /obj/effect/proc_holder/spell/targeted/seismic/righthook)

/obj/item/bodypart/r_arm/robot/seismic/drop_limb(special)
	var/mob/living/carbon/C = owner
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/seismic/lariat)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/seismic/mop)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/seismic/suplex)
	C.RemoveSpell (/obj/effect/proc_holder/spell/targeted/seismic/righthook)
	..()
