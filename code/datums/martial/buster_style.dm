#define COOLDOWN_WIRE 5 SECONDS
#define COOLDOWN_MOP 4 SECONDS
#define COOLDOWN_GRAPPLE 3 SECONDS
#define COOLDOWN_SLAM 0.8 SECONDS



/datum/martial_art/buster_style
	name = "Buster Style"
	id = MARTIALART_BUSTERSTYLE
	no_guns = FALSE
	help_verb = /mob/living/carbon/human/proc/buster_style_help
	var/atom/movable/thrown = null
	COOLDOWN_DECLARE(next_wire)
	COOLDOWN_DECLARE(next_mop)
	COOLDOWN_DECLARE(next_grapple)
	COOLDOWN_DECLARE(next_slam)
	var/soarslamdam = 7
	var/soarobjdam = 50
	var/dashdragdam = 8
	var/dashcrashdam = 10
	var/slamsupdam = 20
	var/slamcrashdam = 10
	var/slamwalldam = 20
	var/old_density //so people grappling something arent pushed by it until it's thrown

//proc the moves will use for damage dealing
/datum/martial_art/buster_style/proc/grab(mob/living/user, mob/living/target, damage)
	var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
	var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 15)
	target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

//animation procs

//knocking them down
/datum/martial_art/buster_style/proc/footsies(mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		animate(target, transform = matrix(90, MATRIX_ROTATE), time = 0 SECONDS, loop = 0)

//standing them back up if appropriate
/datum/martial_art/buster_style/proc/wakeup(mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		animate(target, transform = null, time = 0.4 SECONDS, loop = 0)

/datum/martial_art/buster_style/can_use(mob/living/carbon/human/H)
	var/obj/item/bodypart/r_arm/robot/buster/R = H.get_bodypart(BODY_ZONE_R_ARM)
	var/obj/item/bodypart/l_arm/robot/buster/L = H.get_bodypart(BODY_ZONE_L_ARM)
	if(!isturf(H.loc)) //as funny as throwing lockers from the inside is i dont think i can get away with it
		return
	if(L)
		if(!istype(L, /obj/item/bodypart/l_arm/robot/buster))
			if(R && !istype(R, /obj/item/bodypart/r_arm/robot/buster))
				src.remove(H)
				return FALSE
		else
			if(R && !istype(R, /obj/item/bodypart/r_arm/robot/buster))
				if((L?.bodypart_disabled))
					return FALSE
	if(R)
		if(!istype(R, /obj/item/bodypart/r_arm/robot/buster))
			if(L && !istype(L, /obj/item/bodypart/l_arm/robot/buster))
				src.remove(H)
				return FALSE
		else
			if(L && !istype(L, /obj/item/bodypart/l_arm/robot/buster))
				if((R?.bodypart_disabled))
					return FALSE
	if(H.restrained() || H.get_active_held_item() || HAS_TRAIT(H, TRAIT_PACIFISM) || !(H.mobility_flags & MOBILITY_MOVE) || H.stat != CONSCIOUS)
		if(thrown)
			walk(thrown,0)
			thrown.density = old_density
			animate(thrown, time = 0 SECONDS, pixel_y = 0)
			thrown = null
		for(var/obj/structure/bed/grip/F in get_turf(H))
			F.Destroy()
		return FALSE
	if(L && R)
		if((L?.bodypart_disabled) && (R?.bodypart_disabled))
			to_chat(H, span_warning("The arms aren't in a functional state right now!"))
			return FALSE
	return ..()


/datum/martial_art/buster_style/proc/on_click(mob/living/carbon/human/H, atom/target, params)
	var/list/modifiers = params2list(params)
	if(!can_use(H) || modifiers[SHIFT_CLICK] || modifiers[ALT_CLICK] || modifiers[CTRL_CLICK])
		return NONE
	H.face_atom(target) //for the sake of moves that care about user orientation like mop and slam
	if(modifiers[RIGHT_CLICK])
		if(H == target)
			return arm_wire(H) // right click yourself for arm wire
		if(get_dist(H, target) <= 1)
			return grapple(H, target) // right click in melee to grapple
		else
			return mop(H) // right click at range to mop
	else
		if(thrown)
			return lob(H, target) // left click to throw
		else if(get_dist(H, target) <= 1)
			return slam(H, target) // left click in melee to slam

/datum/martial_art/buster_style/harm_act(mob/living/carbon/human/A, mob/living/D)
	return TRUE // no punching plus slamming please


/*---------------------------------------------------------------
	start of wire section 
---------------------------------------------------------------*/

/datum/martial_art/buster_style/proc/arm_wire(mob/living/carbon/human/user)
	for(var/obj/item/gun/magic/wire/J in user)
		qdel(J)
		to_chat(user, span_notice("The wire returns into your wrist."))
		return
	if(!COOLDOWN_FINISHED(src, next_wire))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	COOLDOWN_START(src, next_wire, COOLDOWN_WIRE)
	var/obj/item/gun/magic/wire/gun = new /obj/item/gun/magic/wire (user)
	user.put_in_hands(gun)
	return TRUE

/*---------------------------------------------------------------
	end of wire section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of grapple section
---------------------------------------------------------------*/

/datum/martial_art/buster_style/proc/grapple(mob/living/user, atom/target) //proc for picking something up to toss
	var/turf/Z = get_turf(user)
	target.add_fingerprint(user, FALSE)
	if((target == user) || (isopenturf(target)) || (iswallturf(target)) || (isitem(target)) || (iseffect(target)))
		return
	if(!user.combat_mode)
		return
	if(!COOLDOWN_FINISHED(src, next_grapple))
		to_chat(user, span_warning("You can't do that yet!"))
		return COMSIG_MOB_CANCEL_CLICKON
	playsound(user, 'sound/effects/servostep.ogg', 60, FALSE, -1)
	if(isstructure(target) || ismachinery(target) || ismecha(target))
		var/obj/I = target
		old_density = I.density
		if(ismecha(I)) 
			I.anchored = FALSE
		if(I.anchored) 
			if(istype(I, /obj/machinery/vending))
				I.anchored = FALSE
				I.visible_message(span_warning("[user] grabs [I] and tears it off the bolts securing it!"))
			else
				return
		COOLDOWN_START(src, next_grapple, COOLDOWN_GRAPPLE)
		user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
		I.visible_message(span_warning("[user] grabs [I] and lifts it above [user.p_their()] head!"))
		animate(I, time = 0.2 SECONDS, pixel_y = 20)
		I.forceMove(Z)
		I.density = FALSE 
		walk_towards(I, user, 0, 0)
		if(get_dist(I, user) > 1)
			I.density = old_density
		thrown = I 
		if(ismecha(I))
			I.anchored = TRUE
		return COMSIG_MOB_CANCEL_CLICKON
	if(isliving(target))
		var/mob/living/L = target
		var/obj/structure/bed/grip/F = new(Z, user) 
		COOLDOWN_START(src, next_grapple, COOLDOWN_GRAPPLE)
		user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
		old_density = L.density // for the sake of noncarbons not playing nice with lying down
		L.density = FALSE
		L.visible_message(span_warning("[user] grabs [L] and lifts [L.p_them()] off the ground!"))
		to_chat(L, span_userdanger("[user] grapples you and lifts you up into the air! Resist [user.p_their()] grip!"))
		L.forceMove(Z)
		F.buckle_mob(target) //makes the victim follow with an invisible bed
		walk_towards(F, user, 0, 0)
		if(get_dist(L, user) > 1)
			L.density = old_density
			return
		thrown = L 
		return COMSIG_MOB_CANCEL_CLICKON


/datum/martial_art/buster_style/proc/lob(mob/living/user, atom/target, distance = 0) //proc for throwing something you picked up with grapple
	if(!user.combat_mode)
		return
	var/throwdam = 15
	var/target_dist = get_dist(user, target)
	var/turf/D = get_turf(target)	
	var/list/flying = list()
	walk(thrown,0)
	thrown.density = old_density
	user.stop_pulling()
	if(get_dist(thrown, user) > 1)//cant reach the thing i was supposed to be throwing anymore
		thrown = null
		return 
	animate(thrown, time = 0.2 SECONDS, pixel_y = 0) //to get it back to normal since it was lifted before
	if(iscarbon(thrown)) //throwing someone by whatever limb and ripping it off if it's hurt enough
		var/mob/living/carbon/tossedliving = thrown
		var/obj/item/bodypart/limb_to_hit = tossedliving.get_bodypart(user.zone_selected)
		if(!tossedliving.buckled)
			return COMSIG_MOB_CANCEL_CLICKON
		grab(user, tossedliving, throwdam)
		for(var/obj/structure/bed/grip/F in view(2, user))
			F.Destroy()
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
	user.visible_message(span_warning("[user] throws [thrown]!"))
	flying |= thrown
	soar(user, thrown, D, target_dist, flying)






/datum/martial_art/buster_style/proc/soar(mob/living/user, atom/movable/center, turf/endzone, distance = 0, list/lobbed) //proc for throwing something you picked up with grapple
	if(distance == 0)
		thrown = null
		return COMSIG_MOB_CANCEL_CLICKON
	var/dir_to_target = get_dir(get_turf(center), endzone) //vars that let the thing be thrown while moving similar to things thrown normally
	var/turf/next = get_step(get_turf(center), dir_to_target)
	if(next.density) // crash into a wall and damage everything flying towards it before stopping 
		for(var/mob/living/S in lobbed)
			grab(user, S, soarslamdam) 
			S.Knockdown(1.0 SECONDS)
			S.Immobilize(1.0 SECONDS)
			if(isanimal(S) && S.stat == DEAD) 
				S.gib()	
		for(var/obj/O in lobbed)
			O.take_damage(soarobjdam) 
			center.visible_message(span_warning("[O] collides with [next]!"))
		thrown = null
		return COMSIG_MOB_CANCEL_CLICKON
	for(var/obj/Z in next.contents) //scooping obstacles up if theyre not nailed down, almost same as above otherwise
		for(var/atom/movable/thrown_atom in lobbed) 
			if(Z.density == TRUE) 
				if(thrown_atom.uses_integrity)
					thrown_atom.take_damage(soarobjdam)
				thrown_atom.Bump(Z)
				if(istype(thrown_atom, /obj/mecha)) //mechs are probably heavy as hell so stop flying after making contact with resistance
					lobbed -= thrown_atom
		if(Z.density == TRUE && Z.anchored == FALSE) //if the thing hit isn't anchored it starts flying too
			lobbed |= Z 
			Z.take_damage(50) 
		if(Z.density == TRUE && Z.anchored == TRUE)
			for(var/mob/living/S in lobbed)
				grab(user, S, soarslamdam) 
				S.Knockdown(1.0 SECONDS)
				S.Immobilize(1.0 SECONDS)
				if(isanimal(S) && S.stat == DEAD)
					S.gib()
				if(istype(Z, /obj/machinery/disposal/bin)) // dumpster living things tossed into the trash
					var/obj/machinery/disposal/bin/dumpster = Z
					S.forceMove(Z)
					Z.visible_message(span_warning("[S] is thrown down the trash chute!"))
					dumpster.do_flush()
					thrown = null
					return COMSIG_MOB_CANCEL_CLICKON
			Z.take_damage(soarobjdam)
			if(Z.density == TRUE && Z.anchored == TRUE)
				thrown = null
				return COMSIG_MOB_CANCEL_CLICKON // if the solid thing we hit doesnt break then the thrown thing is stopped
	for(var/mob/living/M in next.contents) // if the thrown mass hits a person then they get tossed and hurt too along with people in the thrown mass
		if(user != M)
			grab(user, M, soarslamdam) 
			M.Knockdown(1.5 SECONDS) 
			for(var/mob/living/S in lobbed)
				grab(user, S, soarslamdam) 
				S.Knockdown(1 SECONDS) 
			lobbed |= M 
		for(var/obj/O in lobbed)
			O.take_damage(soarobjdam) 
	if(next) // if the next tile wont stop the thrown mass from continuing
		for(var/mob/living/S in lobbed)
			S.Knockdown(1.0 SECONDS)
			S.Immobilize(1.0 SECONDS)
		for(var/atom/movable/K in lobbed) // to make the mess of things that's being thrown almost look like a normal throw
			K.SpinAnimation(0.2 SECONDS, 1) 
			K.forceMove(next)
			if(isspaceturf(next)) //jettison
				var/atom/throw_target = get_edge_target_turf(K, dir_to_target)
				K.throw_at(throw_target, 6, 4, user, 3)
	addtimer(CALLBACK(src, PROC_REF(soar), user, center, endzone, distance-1, lobbed), 0.01 SECONDS)
	thrown = null
	return COMSIG_MOB_CANCEL_CLICKON

/*---------------------------------------------------------------
	end of grapple section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of mop section
---------------------------------------------------------------*/

/datum/martial_art/buster_style/proc/mop(mob/living/user)
	var/jumpdistance = 5
	if(!COOLDOWN_FINISHED(src, next_mop))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	COOLDOWN_START(src, next_mop, COOLDOWN_MOP)
	user.visible_message(span_warning("[user] sprints forward with [user.p_their()] hand outstretched!"))
	user.Immobilize(0.1 SECONDS) //so they dont skip through the target
	initiate(user)
	dashattack(user, user.dir, jumpdistance)
	return COMSIG_MOB_CANCEL_CLICKON


/datum/martial_art/buster_style/proc/initiate(mob/living/user)
	var/obj/effect/temp_visual/decoy/fading/onesecond/F = new(get_turf(user), user)
	animate(F, alpha = 100, color = "#d40a0a")
	walk_towards(F, user, 0, 1.5)
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)


/datum/martial_art/buster_style/proc/dashattack(mob/living/user, dir, distance = 0)
	var/turf/front = get_step(get_turf(user), dir)
	var/turf/further = get_step(front, dir)
	if(distance == 0 || (!front) || (!further))
		return
	user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
	for(var/mob/living/target in front)
		(grab(user, target, dashdragdam))
	if(further.density)
		for(var/mob/living/target in front)
			user.visible_message(span_warning("[user] rams [target] into [further]!"))
			to_chat(target, span_userdanger("[user] rams you into [further]!"))
			target.Bump(further)
			target.Knockdown(1 SECONDS)
			grab(user, target, dashcrashdam)
		return
	for(var/mob/living/L in front.contents)
		L.add_fingerprint(user, FALSE)
		playsound(L,'sound/effects/meteorimpact.ogg', 60, 1)
		wakeup(L)
		footsies(L)
		to_chat(L, span_userdanger("[user] grinds you against the ground!"))
		to_chat(L, span_userdanger("[user] catches you with [user.p_their()] hand and drags you down!"))
		user.visible_message(span_warning("[user] hits [L] and drags them through the dirt!"))
		L.Immobilize(0.3 SECONDS)
		wakeup(L)
		if(isanimal(L))
			if(L.stat == DEAD)
				L.visible_message(span_warning("[L] is ground into paste!"))
				L.gib()
		if(isspaceturf(further))
			var/atom/throw_target = get_edge_target_turf(L, user.dir)
			wakeup(L)
			L.throw_at(throw_target, 2, 4, user, 3) 
	if(front.density || (!(front.reachableTurftestdensity(T = front))))
		return
	else
		user.forceMove(front)
	for(var/obj/object in further.contents) //seeing if the speedbump can stop the incoming trash pile
		if(object.density == TRUE)
			for(var/mob/living/shield in front.contents)
				if(shield == user)
					continue
				grab(user, shield, dashcrashdam)
				shield.Bump(object)
				shield.Knockdown(1 SECONDS)
				user.visible_message(span_warning("[user] rams [shield] into [object]!"))
				to_chat(shield, span_userdanger("[user] rams you into [object]!"))
				object.take_damage(200)
			if(object.density == TRUE)
				return COMSIG_MOB_CANCEL_CLICKON
	for(var/mob/living/incoming in front.contents)
		if(incoming == user)
			continue
		incoming.forceMove(further)
	if(front.density || (!(front.reachableTurftestdensity(T = front))))
		return
	addtimer(CALLBACK(src, PROC_REF(dashattack), user, dir, distance-1), 0.1 SECONDS)
	return COMSIG_MOB_CANCEL_CLICKON

/*---------------------------------------------------------------
	end of mop section
---------------------------------------------------------------*/

/*---------------------------------------------------------------
	start of slam section
---------------------------------------------------------------*/

/datum/martial_art/buster_style/proc/slam(mob/living/user, mob/living/target)
	if(!isliving(target) || !user.combat_mode || user == target)
		return
	var/turf/Z = get_turf(user)
	if(!COOLDOWN_FINISHED(src, next_slam))
		to_chat(user, span_warning("You can't do that yet!"))
		return COMSIG_MOB_CANCEL_CLICKON // don't do a normal punch
	COOLDOWN_START(src, next_slam, COOLDOWN_SLAM)
	user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
	var/turf/Q = get_step(get_turf(user), turn(user.dir,180)) 
	if(Q.density)
		var/turf/closed/wall/W = Q
		grab(user, target, slamwalldam) 
		footsies(target)
		if(isanimal(target) && target.stat == DEAD)
			target.visible_message(span_warning("[target] explodes into gore on impact!"))
			target.gib()
		wakeup(target)
		to_chat(user, span_warning("[user] turns around and slams [target] against [Q]!"))
		to_chat(target, span_userdanger("[user] crushes you against [Q]!"))
		playsound(target, 'sound/effects/meteorimpact.ogg', 60, 1)
		playsound(user, 'sound/effects/gravhit.ogg', 20, 1)
		if(!istype(W, /turf/closed/wall/r_wall)) //cant break rwalls
			W.dismantle_wall(1)
		else		
			grab(user, target, slamwalldam) 
			target.forceMove(Z) 
			Z.break_tile()
			return COMSIG_MOB_CANCEL_CLICKON 
	for(var/obj/D in Q.contents) //bludgeoning everything in the landing zone
		if(D.density == TRUE) 
			if(istype(D, /obj/machinery/disposal/bin)) 
				var/obj/machinery/disposal/bin/dumpster = D
				target.forceMove(D)
				dumpster.do_flush()
				to_chat(target, span_userdanger("[user] throws you down disposals!"))
				user.visible_message(span_warning("[target] is thrown down the trash chute!"))
				return COMSIG_MOB_CANCEL_CLICKON 
			user.visible_message(span_warning("[user] turns around and slams [target] against [D]!"))
			target.Bump(D)
			D.take_damage(400) 
			grab(user, target, slamcrashdam) 
			footsies(target)
			if(isanimal(target) && target.stat == DEAD)
				target.visible_message(span_warning("[target] explodes into gore on impact!"))
				target.gib()
			addtimer(CALLBACK(src, PROC_REF(wakeup), target), 0.2 SECONDS)
	for(var/mob/living/M in Q.contents) 
		grab(user, target, slamcrashdam) 
		footsies(target)
		if(isanimal(target) && target.stat == DEAD)
			target.visible_message(span_warning("[target] explodes into gore on impact!"))
			target.gib()
		addtimer(CALLBACK(src, PROC_REF(wakeup), target), 0.2 SECONDS)
		to_chat(target, span_userdanger("[user] throws you into [M]"))
		to_chat(M, span_userdanger("[user] throws [target] into you!"))
		user.visible_message(span_warning("[target] slams into [M]!"))
		grab(user, M, slamcrashdam) 
	Q.break_tile()
	target.forceMove(Q) 
	if(istype(Q, /turf/open/space)) //thrown away instead if theres no floor
		user.setDir(turn(user.dir,180))
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 2, 4, user, 3)
		user.visible_message(span_warning("[user] throws [target] behind [user.p_them()]!"))
		return COMSIG_MOB_CANCEL_CLICKON
	playsound(target,'sound/effects/meteorimpact.ogg', 60, 1)
	playsound(user, 'sound/effects/gravhit.ogg', 20, 1)
	to_chat(target, span_userdanger("[user] catches you with [user.p_their()] hand and crushes you on the ground!"))
	user.visible_message(span_warning("[user] turns around and slams [target] against the ground!"))
	user.setDir(turn(user.dir, 180))
	grab(user, target, slamsupdam) 
	footsies(target)
	if(isanimal(target) && target.stat == DEAD)
		target.visible_message(span_warning("[target] explodes into gore on impact!"))
		target.gib()
	addtimer(CALLBACK(src, PROC_REF(wakeup), target), 0.2 SECONDS)
	return COMSIG_MOB_CANCEL_CLICKON

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
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You think about what stunts you can pull with the power of a buster arm.</i></b>"

	combined_msg += "[span_notice("Wire Snatch")]:By right-clicking yourself, you equip a grappling wire which can be used to move yourself or other objects. Landing a \
	shot on a person will immobilize them for 2 seconds. Facing an immediate solid object will slam them into it, damaging both of them. Extending the wire has a 5 second cooldown."

	combined_msg +=  "[span_notice("Mop the Floor")]: Right-clicking away from you in a direction sends you flying forward, damaging enemies in front of you by dragging them \
	along the ground. Ramming victims into something solid does damage to them and the object. Has a 4 second cooldown."

	combined_msg +=  "[span_notice("Grapple")]: Right-clicking an enemy allows you to take a target object or being into your hand for up to 10 seconds and throw them at a \
	target destination with left-click. Throwing them into unanchored people and objects will knock them back and deal additional damage to existing thrown \
	targets. Mechs and vending machines can be tossed as well. If the target's limb is at its limit, tear it off. Has a 3 second cooldown."

	combined_msg +=  "[span_notice("Slam")]: Your punch has been replaced with a slam attack that places enemies behind you and smashes them against \
	whatever person, wall, or object is there for bonus damage. Has a 0.8 second cooldown."

	combined_msg +=  "[span_notice("Megabuster")]: Charge up your buster arm to put a powerful attack in the corresponding hand. The energy only lasts 5 seconds \
	but does hefty damage to its target, even breaking walls down when hitting things into them or connecting the attack directly. Landing the attack on a reinforced wall \
	destroys it but uses up the attack. Attacking a living target uses up the attack and sends them flying and dismembers their limb if its damaged enough. Has a 15 second \
	cooldown."

	combined_msg +=  span_warning("You can't perform any of the moves if you have an occupied hand. Additionally, if your buster arm should become disabled, so shall your moves.")

	combined_msg +=  span_warning("Should your moves cease to function altogether, utilize the 'Recalibrate Arm' function.")

	combined_msg += span_notice("<b>After landing an attack, you become resistant to damage slowdown and all incoming damage by 25% for 2 seconds.</b>")

	to_chat(usr, examine_block(combined_msg.Join("\n")))

/datum/martial_art/buster_style/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	var/datum/species/S = H.dna?.species
	ADD_TRAIT(H, TRAIT_SHOCKIMMUNE, type)
	S.add_no_equip_slot(H, ITEM_SLOT_GLOVES, src)
	RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	to_chat(H, span_boldannounce("You've gained the ability to use Buster Style!"))

/datum/martial_art/buster_style/on_remove(mob/living/carbon/human/H)
	var/datum/species/S = H.dna?.species
	REMOVE_TRAIT(H, TRAIT_SHOCKIMMUNE, type)
	S.remove_no_equip_slot(H, ITEM_SLOT_GLOVES, src)
	UnregisterSignal(H, COMSIG_MOB_CLICKON)
	to_chat(H, "[span_boldannounce("You've lost the ability to use Buster Style...")]")
	..()
