#define COOLDOWN_STOMP 5 SECONDS
#define COOLDOWN_GRAPPLE 3 SECONDS

/datum/martial_art/worldshaker
	name = "Worldshaker"
	id = MARTIALART_WORLDSHAKER
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/worldshaker_help
	var/list/thrown = list()
	COOLDOWN_DECLARE(next_stomp)
	COOLDOWN_DECLARE(next_grapple)
	var/old_density //so people grappling something arent pushed by it until it's thrown
	var/leaping = FALSE

/datum/martial_art/worldshaker/can_use(mob/living/carbon/human/H)
	return ispreternis(H)

/datum/martial_art/worldshaker/harm_act(mob/living/carbon/human/A, mob/living/D)
	pummel(A, D)
	return TRUE //no punch, just pummel

/datum/martial_art/worldshaker/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/target)
	var/list/modifiers = params2list(params)
	if(!(can_use(H)) || (modifiers["shift"] || modifiers["alt"]))
		return
	H.face_atom(target) //for the sake of moves that care about user orientation like mop and slam
	if(H.a_intent == INTENT_DISARM)
		leap(H, target)
	if(H.a_intent == INTENT_HELP)
		stomp(H)
	if(thrown.len > 0 && H.a_intent == INTENT_GRAB)
		if(get_turf(target) != get_turf(H))
			lob(H, target)

	if(!H.Adjacent(target) || H==target)
		return
	if(H.a_intent == INTENT_GRAB)
		grapple(H,target)

/*---------------------------------------------------------------
	start of stomp section 
---------------------------------------------------------------*/
/datum/martial_art/worldshaker/proc/stomp(mob/living/carbon/human/user)
	var/atom/movable/gravity_lens/shockwave = new(get_turf(user))
	shockwave.transform *= 0.01 //basically invisible
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	animate(shockwave, transform = matrix().Scale(1), time = 2 SECONDS)
	QDEL_IN(shockwave, 2 SECONDS)

/*---------------------------------------------------------------
	end of stomp section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of leap section
---------------------------------------------------------------*/
/datum/martial_art/worldshaker/proc/leap(mob/living/user, atom/target)
	if(!target || leaping)
		return
	var/chargeturf = get_turf(target)
	if(!chargeturf)
		return
	var/dir = get_dir(user, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir)
	if(!T)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(T)
	leaping = TRUE
	user.movement_type &= FLYING
	walk(user, 0)
	user.setDir(dir)
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(user.loc, user)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 0.3 SECONDS)
	var/movespeed = 0.7
	walk_towards(user, T, movespeed)
	sleep(get_dist(user, T) * movespeed)
	walk(user, 0) // cancel the movement
	user.movement_type &= ~FLYING
	leaping = FALSE
/*---------------------------------------------------------------
	end of leap section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of grapple section
---------------------------------------------------------------*/
/datum/martial_art/worldshaker/proc/grab(mob/living/user, mob/living/target, damage)//proc the moves will use for damage dealing
	var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
	var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
	target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
	
/datum/martial_art/worldshaker/proc/drop(mob/living/target)//proc for clearing the thrown list, mostly so the lob proc doesnt get triggered when it shouldn't
	for(var/atom/movable/K in thrown)
		thrown.Remove(K)

/datum/martial_art/worldshaker/proc/grapple(mob/living/user, atom/target) //proc for picking something up to toss
	var/turf/Z = get_turf(user)
	target.add_fingerprint(user, FALSE)
	if(!COOLDOWN_FINISHED(src, next_grapple))
		to_chat(user, span_warning("You can't do that yet!"))
		return
	if((target == user) || (isopenturf(target)) || (iswallturf(target)) || (isitem(target)) || (iseffect(target)))
		return
	playsound(user, 'sound/effects/servostep.ogg', 60, FALSE, -1)
	if(isstructure(target) || ismachinery(target) || ismecha(target))
		var/obj/I = target
		old_density = I.density
		if(ismecha(I)) // Can pick up mechs
			I.anchored = FALSE
		if(I.anchored == TRUE) // Cannot pick up anchored structures
			if(istype(I, /obj/machinery/vending)) // Can pick up vending machines, even if anchored
				I.anchored = FALSE
				I.visible_message(span_warning("[user] grabs [I] and tears it off the bolts securing it!"))
			else
				return
		if(user in I.contents)
			to_chat(user, span_warning("You can't throw something while you're inside of it!")) //as funny as throwing lockers from the inside is i dont think i can get away with it
			return
		COOLDOWN_START(src, next_grapple, COOLDOWN_GRAPPLE)
		user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)	
		I.visible_message(span_warning("[user] grabs [I] and lifts it above [user.p_their()] head!"))
		animate(I, time = 0.2 SECONDS, pixel_y = 20)
		I.forceMove(Z)
		I.density = FALSE 
		walk_towards(I, user, 0, 0)
		// Reset the item to its original state
		if(get_dist(I, user) > 1)
			I.density = old_density
		thrown |= I // Mark the item for throwing
		if(ismecha(I))
			I.anchored = TRUE
	if(isliving(target))
		var/mob/living/L = target
		var/obj/structure/bed/grip/F = new(Z, user) // Buckles them to an invisible bed
		COOLDOWN_START(src, next_grapple, COOLDOWN_GRAPPLE)
		user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
		old_density = L.density // for the sake of noncarbons not playing nice with lying down
		L.density = FALSE
		L.visible_message(span_warning("[user] grabs [L] and lifts [L.p_them()] off the ground!"))
		L.Stun(1 SECONDS) //so the user has time to aim their throw
		to_chat(L, span_userdanger("[user] grapples you and lifts you up into the air! Resist [user.p_their()] grip!"))
		L.forceMove(Z)
		F.buckle_mob(target)
		walk_towards(F, user, 0, 0)
		if(get_dist(L, user) > 1)
			L.density = old_density
			return
		thrown |= L // Marks the mob to throw
		return

/datum/martial_art/worldshaker/proc/lob(mob/living/user, atom/target) //proc for throwing something you picked up with grapple
	var/slamdam = 7
	var/objdam = 50
	var/throwdam = 15
	var/target_dist = get_dist(user, target)
	var/turf/D = get_turf(target)	
	var/atom/tossed = thrown[1]
	walk(tossed,0)
	tossed.density = old_density
	user.stop_pulling()
	if(get_dist(tossed, user) > 1)//cant reach the thing i was supposed to be throwing anymore
		drop()
		return 
	for(var/obj/I in thrown)
		animate(I, time = 0.2 SECONDS, pixel_y = 0) //to get it back to normal since it was lifted before
	if(user in tossed.contents)
		to_chat(user, span_warning("You can't throw something while you're inside of it!"))
		return
	if(iscarbon(tossed)) // Logic that tears off a damaged limb or tail
		var/mob/living/carbon/tossedliving = thrown[1]
		var/obj/item/bodypart/limb_to_hit = tossedliving.get_bodypart(user.zone_selected)
		if(!tossedliving.buckled)
			return
		grab(user, tossedliving, throwdam) // Apply damage
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
	user.visible_message(span_warning("[user] throws [tossed]!"))
	for(var/i = 1 to target_dist)
		var/dir_to_target = get_dir(get_turf(tossed), D) //vars that let the thing be thrown while moving similar to things thrown normally
		var/turf/T = get_step(get_turf(tossed), dir_to_target)
		if(T.density) // crash into a wall and damage everything flying towards it before stopping 
			for(var/mob/living/S in thrown)
				grab(user, S, slamdam) 
				S.Knockdown(1.5 SECONDS)
				S.Immobilize(1.5 SECONDS)
				if(isanimal(S) && S.stat == DEAD)
					S.gib()	
			for(var/obj/O in thrown)
				O.take_damage(objdam) 
				target.visible_message(span_warning("[O] collides with [T]!"))
			drop()
			return
		for(var/obj/Z in T.contents) // crash into something solid and damage it along with thrown objects that hit it
			for(var/obj/O in thrown) 
				if(Z.density == TRUE) 
					O.take_damage(objdam) 
					if(istype(O, /obj/mecha)) // mechs are probably heavy as hell so stop flying after making contact with resistance
						thrown -= O
			if(Z.density == TRUE && Z.anchored == FALSE) // if the thing hit isn't anchored it starts flying too
				thrown |= Z 
				Z.take_damage(50) 
			if(Z.density == TRUE && Z.anchored == TRUE) // If the thing is solid and anchored like a window or grille or table it hurts people thrown that crash into it too
				for(var/mob/living/S in thrown) 
					grab(user, S, slamdam) 
					S.Knockdown(1.5 SECONDS)
					S.Immobilize(1.5 SECONDS)
					if(isanimal(S) && S.stat == DEAD)
						S.gib()
					if(istype(Z, /obj/machinery/disposal/bin)) // dumpster living things tossed into the trash
						var/obj/machinery/disposal/bin/dumpster = D
						S.forceMove(Z)
						Z.visible_message(span_warning("[S] is thrown down the trash chute!"))
						dumpster.do_flush()
						drop()
						return
				Z.take_damage(objdam)
				if(Z.density == TRUE && Z.anchored == TRUE)
					drop()
					return // if the solid thing we hit doesnt break then the thrown thing is stopped
		for(var/mob/living/M in T.contents) // if the thrown mass hits a person then they get tossed and hurt too along with people in the thrown mass
			if(user != M)
				grab(user, M, slamdam) 
				M.Knockdown(1.5 SECONDS) 
				for(var/mob/living/S in thrown)
					grab(user, S, slamdam) 
					S.Knockdown(1 SECONDS) 
				thrown |= M 
			for(var/obj/O in thrown)
				O.take_damage(objdam) // Damage all thrown objects
		if(T) // if the next tile wont stop the thrown mass from continuing
			for(var/mob/living/S in thrown)
				S.Knockdown(1.5 SECONDS)
				S.Immobilize(1.5 SECONDS)
			for(var/atom/movable/K in thrown) // to make the mess of things that's being thrown almost look like a normal throw
				K.SpinAnimation(0.2 SECONDS, 1) 
				sleep(0.001 SECONDS)
				K.forceMove(T)
				if(isspaceturf(T)) // throw them like normal if it's into space
					var/atom/throw_target = get_edge_target_turf(K, dir_to_target)
					K.throw_at(throw_target, 6, 4, user, 3)
					thrown.Remove(K)
	drop()
	return

/*---------------------------------------------------------------
	end of grapple section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of pummel section
---------------------------------------------------------------*/

/datum/martial_art/worldshaker/proc/pummel(mob/living/user, mob/living/target)
	
/*---------------------------------------------------------------
	end of pummel section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	training related section
---------------------------------------------------------------*/
/mob/living/carbon/human/proc/worldshaker_help()
	set name = "Buster Style"
	set desc = "You mentally practice the stunts you can pull with the buster arm."
	set category = "Buster Style"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You think about what stunts you can pull with the power of a buster arm.</i></b>"

	combined_msg += "[span_notice("Wire Snatch")]:By targetting yourself with help intent, you equip a grappling wire which can be used to move yourself or other objects. Landing a \
	shot on a person will immobilize them for 2 seconds. Facing an immediate solid object will slam them into it, damaging both of them. Extending the wire has a 5 second cooldown."

	combined_msg +=  "[span_notice("Mop the Floor")]: Your disarm has been replaced with a move that sends you flying forward, damaging enemies in front of you by dragging them \
	along the ground. Ramming victims into something solid does damage to them and the object. Has a 4 second cooldown."

	combined_msg +=  "[span_notice("Slam")]: Your harm has been replaced with a slam attack that places enemies behind you and smashes them against \
	whatever person, wall, or object is there for bonus damage. Has a 0.8 second cooldown."
	
	combined_msg +=  "[span_notice("Grapple")]: Your grab has been amplified, allowing you to take a target object or being into your hand for up to 10 seconds and throw them at a \
	target destination by clicking again with grab intent. Throwing them into unanchored people and objects will knock them back and deal additional damage to existing thrown \
	targets. Mechs and vending machines can be tossed as well. If the target's limb is at its limit, tear it off. Has a 3 second cooldown"

	combined_msg +=  "[span_notice("Megabuster")]: Charge up your buster arm to put a powerful attack in the corresponding hand. The energy only lasts 5 seconds \
	but does hefty damage to its target, even breaking walls down when hitting things into them or connecting the attack directly. Landing the attack on a reinforced wall \
	destroys it but uses up the attack. Attacking a living target uses up the attack and sends them flying and dismembers their limb if its damaged enough. Has a 15 second \
	cooldown."

	combined_msg +=  span_warning("You can't perform any of the moves if you have an occupied hand. Additionally, if your buster arm should become disabled, so shall\
	 your moves.")

	combined_msg += span_notice("<b>After landing an attack, you become resistant to damage slowdown and all incoming damage by 50% for 2 seconds.</b>")

	to_chat(usr, examine_block(combined_msg.Join("\n")))

/datum/martial_art/worldshaker/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	ADD_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, type)
	usr.click_intercept = src 

/datum/martial_art/worldshaker/on_remove(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, type)
	usr.click_intercept = null 
	..()
