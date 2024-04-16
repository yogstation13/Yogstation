
/obj/item/bodypart/r_arm/robot/seismic
	name = "seismic right arm"
	desc = "A prototype arm adorned with woofers capable of emitting shockwaves to excavate basalt."
	icon = 'icons/mob/augmentation/augments_seismic.dmi'
	icon_state = "seismic_r_arm"
	max_damage = 60
	var/datum/martial_art/reverberating_palm/reverberating_palm = new
	var/datum/action/cooldown/seismic_recalibrate/recalibration = new/datum/action/cooldown/seismic_recalibrate()
	var/datum/action/cooldown/seismic_deactivate/deactivation = new/datum/action/cooldown/seismic_deactivate()

/obj/item/bodypart/r_arm/robot/seismic/attach_limb(mob/living/carbon/C, special)
	. = ..()
	reverberating_palm.teach(C)
	recalibration.Grant(C)
	deactivation.Grant(C)
	to_chat(owner, span_boldannounce("You've gained the ability to use Reverberating Palm!"))

/obj/item/bodypart/r_arm/robot/seismic/drop_limb(special)
	reverberating_palm.remove(owner)
	owner.click_intercept = null
	recalibration.Remove(owner)
	deactivation.Remove(owner)
	to_chat(owner, "[span_boldannounce("You've lost the ability to use Reverberating Palm...")]")
	..()



/obj/item/melee/overcharged_emitter
	name = "supercharged emitter"
	desc = "The result of all the prosthetic's power building up in its palm. It's fading fast."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "flagellation"
	item_state = "hivehand"
	color = "#04b8ff"
	item_flags = DROPDEL
	w_class = 5
	var/carbondam = 15
	var/animaldam = 100
	var/borgdam = 18 
	var/objdam = 40
	var/flightdist = 8
	var/objcrash = 30
	var/carboncrash = 10
	var/borgcrash = 11
	var/animalcrash = 30

/obj/item/melee/overcharged_emitter/afterattack(atom/target, mob/living/user, proximity)
	var/obj/item/bodypart/r_arm/R = user.get_bodypart(BODY_ZONE_R_ARM)
	if(isturf(target) || iseffect(target) || isitem(target) || !proximity || (target == user))
		return
	qdel(src, force = TRUE)
	target.SpinAnimation(0.5 SECONDS, 2)
	playsound(target,'sound/effects/gravhit.ogg', 60, 1)
	shake_camera(target, 4, 3)
	shake_camera(user, 2, 3)
	to_chat(target, span_userdanger("[user] hits you with a blast of energy and sends you flying!"))
	user.visible_message(span_warning("[user] blasts [target] with a surge of energy and sends [target.p_them()] flying!"))
	R?.set_disabled(TRUE)
	addtimer(CALLBACK(R, TYPE_PROC_REF(/obj/item/bodypart/r_arm, set_disabled)), 15 SECONDS, TRUE)
	if(isliving(target))
		var/mob/living/L = target
		L.Immobilize(0.5 SECONDS)
		if(iscarbon(L))
			L.adjustBruteLoss(carbondam)
		if(isanimal(L))
			if(istype(L, /mob/living/simple_animal/hostile/guardian))
				L.adjustBruteLoss(40)
			else
				L.adjustBruteLoss(animaldam)
		if(issilicon(L))
			L.adjustBruteLoss(borgdam)
	if(isobj(target))
		var/obj/I = target
		I.take_damage(objdam)
		if(I.anchored == TRUE)
			return
	if(ismovable(target))
		addtimer(CALLBACK(src, PROC_REF(fly), target, user.dir, flightdist))	

/obj/item/melee/overcharged_emitter/proc/fly(atom/movable/ball, dir, triplength = 0)
	if(triplength == 0)
		return
	var/turf/Q = get_step(get_turf(ball), dir)
	var/turf/current = (get_turf(ball))
	for(var/atom/speedbump in Q.contents)
		if(isitem(speedbump) || !ismovable(speedbump))
			continue
		var/atom/movable/H = speedbump
		if(isobj(H) && H.density)
			var/obj/O = H
			O.take_damage(30)
			if(O.anchored == TRUE)
				continue
		H.forceMove(current)
		if(isliving(H))
			var/mob/living/L = H
			if(iscarbon(L))
				L.adjustBruteLoss(carboncrash)
			if(isanimal(L))
				L.adjustBruteLoss(animalcrash)
			if(issilicon(L))
				L.adjustBruteLoss(borgcrash)
	for(var/atom/movable/T in current.contents)
		if(isitem(T) || !ismovable(T) || !(T.density))
			continue
		T.SpinAnimation(0.2 SECONDS, 1)
		if(Q.density || (!(Q.reachableTurftestdensity(T = Q))))
			if(isliving(T))
				var/mob/living/target = T
				target.adjustBruteLoss(5)
				if(isanimal(target))
					if(target.stat == DEAD)
						target.visible_message(span_warning("[target] crashes and explodes!"))
						target.gib()
			if(isobj(T))
				var/obj/O = T
				O.take_damage(20)
				if(O.anchored == TRUE)
					continue
			if(ismineralturf(Q))
				var/turf/closed/mineral/M = Q
				M.attempt_drill()
		if(Q.density || (!(Q.reachableTurftestdensity(T = Q))))
			return  
		T.forceMove(Q)
	addtimer(CALLBACK(src, PROC_REF(fly), ball, dir, triplength-1), 0.1 SECONDS)			
		

/obj/item/melee/overcharged_emitter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	animate(src, alpha = 50, time = 5 SECONDS)
	QDEL_IN(src, 5 SECONDS)

