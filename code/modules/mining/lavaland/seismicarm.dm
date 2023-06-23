/datum/action/cooldown/seismic
	check_flags = AB_CHECK_HANDS_BLOCKED| AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	transparent_when_unavailable = TRUE
	button_icon = 'icons/mob/actions/actions_arm.dmi'

/datum/action/cooldown/seismic/lariat
	name = "Lariat"
	desc = "Dash forward, catching whatever animal you hit with your arm and knocking them over."
	button_icon = 'icons/mob/actions/actions_arm.dmi'
	button_icon_state = "lariat"
	cooldown_time = 7 SECONDS
	var/jumpdistance = 4

/datum/action/cooldown/seismic/lariat/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/turf/T = get_step(get_turf(owner), owner.dir)
	var/turf/Z = get_turf(owner)
	var/obj/effect/temp_visual/decoy/fading/threesecond/F = new(Z, owner)
	owner.visible_message(span_warning("[owner] sprints forward with [owner.p_their()] arm outstretched!"))
	playsound(owner,'sound/effects/gravhit.ogg', 20, 1)
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
			owner.forceMove(T)
			walk_towards(F,owner,0, 1.5)
			animate(F, alpha = 0, color = "#00d9ff", time = 0.3 SECONDS)
			for(var/mob/living/L in T.contents)
				if(L != owner)
					owner.forceMove(get_turf(L))
					to_chat(L, span_userdanger("[owner] catches you with [owner.p_their()] arm and clotheslines you!"))
					owner.visible_message(span_warning("[owner] hits [L] with a lariat!"))
					L.SpinAnimation(0.5 SECONDS, 1)
					if(isanimal(L))
						L.adjustBruteLoss(50)
					if(iscarbon(L))
						L.adjustBruteLoss(10)
					if(issilicon(L))
						L.adjustBruteLoss(12)
					playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
			T = get_step(owner,owner.dir)
	return TRUE
			
/datum/action/cooldown/seismic/mop
	name = "Mop the Floor"
	desc = "Launch forward and drag whoever's in front of you on the ground. The power of this move increases with closeness to the target upon using it."
	button_icon = 'icons/mob/actions/actions_arm.dmi'
	button_icon_state = "mop"
	cooldown_time = 7 SECONDS
	var/jumpdistance = 4

/datum/action/cooldown/seismic/mop/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/turf/T = get_step(get_turf(owner), owner.dir)
	var/turf/Z = get_turf(owner)
	var/obj/effect/temp_visual/decoy/fading/threesecond/F = new(Z, owner)
	var/list/mopped = list()
	owner.visible_message(span_warning("[owner] sprints forward with [owner.p_their()] hand outstretched!"))
	playsound(owner,'sound/effects/gravhit.ogg', 20, 1)
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
			owner.forceMove(T)
			walk_towards(F,owner,0, 1.5)
			animate(F, alpha = 0, color = "#00d9ff", time = 0.3 SECONDS)
			for(var/mob/living/L in T.contents)
				if(L != owner)
					mopped |= L
					var/turf/Q = get_step(get_turf(owner), owner.dir)
					var/mob/living/U = owner
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
			T = get_step(owner,owner.dir)
	for(var/mob/living/C in mopped)
		if(C.stat == CONSCIOUS && C.resting == FALSE)
			animate(C, transform = null, time = 0.5 SECONDS, loop = 0)

	return TRUE

/datum/action/cooldown/seismic/suplex
	name = "Suplex"
	desc = "Grab the target in front of you and slam them back onto the ground."
	button_icon = 'icons/mob/actions/actions_arm.dmi'	
	button_icon_state = "suplex"
	cooldown_time = 1 SECONDS

/datum/action/cooldown/seismic/suplex/Trigger()
	if(!..())
		return FALSE
	StartCooldown()
	var/turf/T = get_step(get_turf(owner), owner.dir)
	var/turf/Z = get_turf(owner)
	owner.visible_message(span_warning("[owner] outstretches [owner.p_their()] arm and goes for a grab!"))
	for(var/mob/living/L in T.contents)
		var/turf/Q = get_step(get_turf(owner), turn(owner.dir,180))
		if(ismineralturf(Q))
			var/turf/closed/mineral/M = Q
			M.attempt_drill()
			L.adjustBruteLoss(5)
		if(Q.density)
			to_chat(owner, span_warning("There's no room to do this!"))
			return
		for(var/obj/D in Q.contents)
			if(D.density == TRUE)
				to_chat(owner, span_warning("There's no room to do this!"))
				return
		for(var/obj/machinery/door/window/E in Z.contents)
			if(E.density == TRUE)
				return 
		for(var/mob/living/M in Q.contents)
			if(isanimal(L))
				M.adjustBruteLoss(20)
			if(iscarbon(L))
				M.adjustBruteLoss(10)		
			owner.visible_message(span_warning("[L] slams into [M]!"))
		L.forceMove(Q)
		playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
		playsound(owner,'sound/effects/gravhit.ogg', 20, 1)
		to_chat(L, span_userdanger("[owner] catches you with [owner.p_their()] hand and crushes you on the ground!"))
		owner.visible_message(span_warning("[owner] turns around and slams [L] against the ground!"))
		owner.setDir(turn(owner.dir,180))
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
		
/datum/action/cooldown/seismic/righthook
	name = "Right Hook"
	desc = "Put the arm through its paces, cranking the outputs located at the front and back of the hand to full capacity for a powerful blow. This attack can only be readied for five seconds and connecting with it will temporarily overwhelm the entire arm for fifteen."
	button_icon = 'icons/mob/actions/actions_arm.dmi'
	button_icon_state = "ponch"
	cooldown_time = 3 SECONDS

/datum/action/cooldown/seismic/righthook/Trigger()
	. = ..()
	if(!.)
		return FALSE
	playsound(owner,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	do_after(owner, 2 SECONDS, owner, TRUE, stayStill = FALSE)
	owner.put_in_r_hand(new /obj/item/melee/overcharged_emitter)
	owner.visible_message(span_warning("[owner]'s right arm begins crackling loudly!"))
	return TRUE

/datum/action/cooldown/seismic/lefthook
	name = "Left Hook"
	desc = "Put the arm through its paces, cranking the outputs located at the front and back of the hand to full capacity for a powerful blow. This attack can only be readied for five seconds and connecting with it will temporarily overwhelm the entire arm for fifteen."
	button_icon = 'icons/mob/actions/actions_arm.dmi'
	button_icon_state = "ponch"
	cooldown_time = 3 SECONDS

/datum/action/cooldown/seismic/righthook/Trigger()
	. = ..()
	if(!.)
		return FALSE
	playsound(owner,'sound/effects/beepskyspinsabre.ogg', 60, 1)
	do_after(owner, 2 SECONDS, owner, TRUE, stayStill = FALSE)
	owner.put_in_l_hand(new /obj/item/melee/overcharged_emitter)
	owner.visible_message(span_warning("[owner]'s left arm begins crackling loudly!"))
	return TRUE

/obj/item/melee/overcharged_emitter
	name = "supercharged emitter"
	desc = "The result of all the prosthetic's power building up in its palm. It's fading fast."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "flagellation"
	item_state = "hivehand"
	color = "#04b8ff"
	item_flags = DROPDEL
	w_class = 5
	var/flightdist = 8

/obj/item/melee/overcharged_emitter/afterattack(mob/living/L, mob/living/user, proximity)
	var/direction = user.dir
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
		shake_camera(L, 4, 3)
		shake_camera(user, 2, 3)
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

/obj/item/melee/overcharged_emitter/Initialize(mapload)
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
	var/datum/action/cooldown/seismic/lariat/lariat = new/datum/action/cooldown/seismic/lariat()
	var/datum/action/cooldown/seismic/mop/mop = new/datum/action/cooldown/seismic/mop()
	var/datum/action/cooldown/seismic/suplex/suplex = new/datum/action/cooldown/seismic/suplex()
	var/datum/action/cooldown/seismic/righthook/righthook = new/datum/action/cooldown/seismic/righthook()

/obj/item/bodypart/r_arm/robot/seismic/attack(mob/living/L, proximity)
	if(!ishuman(L))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your right arm!"))
	replace_limb(L)

/obj/item/bodypart/r_arm/robot/seismic/attach_limb(mob/living/carbon/C, special)
	. = ..()
	lariat.Grant(C)
	mop.Grant(C)
	suplex.Grant(C)
	righthook.Grant(C)

/obj/item/bodypart/r_arm/robot/seismic/drop_limb(special)
	var/mob/living/carbon/C = owner
	lariat.Remove(C)
	mop.Remove(C)
	suplex.Remove(C)
	righthook.Remove(C)
	return ..()
