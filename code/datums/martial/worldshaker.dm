//variables for fun balance tweaks
#define COOLDOWN_STOMP 10 SECONDS
#define STOMP_RADIUS 10
#define STOMP_DAMAGERADIUS 5
#define COOLDOWN_LEAP 1.5 SECONDS
#define LEAP_RADIUS 1
#define COOLDOWN_GRAPPLE 2 SECONDS
#define STAGGER_DURATION 3 SECONDS
#define WARNING_RANGE 10

/datum/martial_art/worldshaker
	name = "Worldshaker"
	id = MARTIALART_WORLDSHAKER
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/worldshaker_help
	block_chance = 100 //validhunters cry
	var/list/thrown = list()
	// COOLDOWN_DECLARE(next_stomp)
	COOLDOWN_DECLARE(next_leap)
	COOLDOWN_DECLARE(next_grapple)
	var/datum/action/cooldown/worldstomp/linked_stomp
	var/old_density //so people grappling something arent pushed by it until it's thrown
	var/leaping = FALSE

/datum/martial_art/worldshaker/can_use(mob/living/carbon/human/H)
	return ispreternis(H)

/datum/martial_art/worldshaker/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return TRUE //you're doing enough pushing as is

/datum/martial_art/worldshaker/harm_act(mob/living/carbon/human/A, mob/living/D)
	return TRUE //no punch, just pummel

/datum/martial_art/worldshaker/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/target)
	var/list/modifiers = params2list(params)
	if(!(can_use(H)) || (modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"]))
		return
	if(H.a_intent == INTENT_DISARM)
		leap(H, target)
	if(thrown.len > 0 && H.a_intent == INTENT_GRAB)
		if(get_turf(target) != get_turf(H))
			lob(H, target)

	if(!H.Adjacent(target) || H==target)
		return
	if(H.a_intent == INTENT_HARM && isliving(target))
		pummel(H,target)
	if(H.a_intent == INTENT_GRAB)
		grapple(H,target)

	
/*-----------------------------
	start of helpers section
-----------------------------*/
/datum/martial_art/worldshaker/proc/stagger(mob/living/victim)
	victim.set_resting(TRUE)//basically a trip
	victim.add_movespeed_modifier(id, update=TRUE, priority=101, multiplicative_slowdown = 1)
	addtimer(CALLBACK(src, PROC_REF(stagger_end), victim), STAGGER_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/martial_art/worldshaker/proc/stagger_end(mob/living/victim)
	victim.remove_movespeed_modifier(id)

/datum/martial_art/worldshaker/proc/push_away(mob/living/user, mob/living/victim, distance = 1)
	var/throwdirection = get_dir(user, victim)
	var/atom/throw_target = get_edge_target_turf(victim, throwdirection)
	victim.throw_at(throw_target, distance, 2, user)

/*-----------------------------
	end of helpers section
-----------------------------*/
/*---------------------------------------------------------------
	start of stomp section 
---------------------------------------------------------------*/
/datum/action/cooldown/worldstomp
	name = "stomp"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "lizard_tackle"
	background_icon_state = "bg_default"
	desc = "hehe big stompy."
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	var/datum/martial_art/worldshaker/linked_martial
	cooldown_time = COOLDOWN_STOMP

/datum/action/cooldown/worldstomp/IsAvailable()
	if(!linked_martial.can_use(owner))
		return FALSE
	return ..()

/datum/action/cooldown/worldstomp/Trigger()
	. = ..()
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(owner.loc, owner)
	animate(D, alpha = 128, color = "#000000", transform = matrix()*2, time = 1 SECONDS)
	if(!do_after(owner, 1 SECONDS, owner) || !IsAvailable())
		qdel(D)
		return
	StartCooldown()
	animate(D, alpha = 0, color = "#000000", transform = matrix()*0, time = 1)

	for(var/mob/living/L in range(STOMP_RADIUS, owner))
		if(L == owner)
			continue
		linked_martial.stagger(L)
		var/damage = 5
		var/throwdistance = 1
		if(L in range(STOMP_DAMAGERADIUS, owner))//more damage and CC if closer
			damage = 30
			throwdistance = 3
			L.Knockdown(30)
		if(L.loc == owner.loc)//if the are standing directly ontop of you, you're fucked
			damage = 40
			L.adjustStaminaLoss(70)
		L.apply_damage(damage, BRUTE, wound_bonus = 10, bare_wound_bonus = 20)
		linked_martial.push_away(owner, L, throwdistance)
	for(var/obj/item/I in range(STOMP_RADIUS, owner))
		var/throwdirection = get_dir(owner, I)
		var/atom/throw_target = get_edge_target_turf(I, throwdirection)
		I.throw_at(throw_target, 3, 2, owner)

	//flavour stuff
	playsound(owner, get_sfx("explosion_creaking"), 100, TRUE, STOMP_RADIUS)
	playsound(owner, 'sound/effects/explosion_distant.ogg', 200, FALSE, STOMP_RADIUS + WARNING_RANGE)
	var/atom/movable/gravity_lens/shockwave = new(get_turf(owner))
	shockwave.transform *= 0.1 //basically invisible
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	animate(shockwave, alpha = 0, transform = matrix().Scale(3), time = 3 SECONDS)
	QDEL_IN(shockwave, 3.1 SECONDS)

/*---------------------------------------------------------------
	end of stomp section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of leap section
---------------------------------------------------------------*/
/datum/martial_art/worldshaker/proc/leap(mob/living/user, atom/target)
	if(!COOLDOWN_FINISHED(src, next_leap))
		user.balloon_alert(user, span_warning("You can't do that yet!"))
		return
	if(!target || leaping)
		return
	COOLDOWN_START(src, next_leap, COOLDOWN_LEAP)

	leaping = TRUE
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(user.loc,user)
	animate(D, alpha = 0, color = "#000000", transform = matrix()*2, time = 0.3 SECONDS)
	animate(user, time = 0.2 SECONDS, pixel_y = 20)//we up in the air
	playsound(user, 'sound/effects/gravhit.ogg', 20)
	playsound(user, 'sound/effects/dodge.ogg', 15, TRUE)
	user.Immobilize(1 SECONDS, ignore_canstun = TRUE) //to prevent cancelling the leap
	user.throw_at(target, 15, 3, user, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(leap_end), user))

/datum/martial_art/worldshaker/proc/leap_end(mob/living/carbon/human/user)
	user.SetImmobilized(0 SECONDS, ignore_canstun = TRUE)
	leaping = FALSE

	for(var/mob/living/L in range(LEAP_RADIUS,user))
		if(L == user)
			continue
		stagger(L)
		var/damage = 20

		if(L.loc == user.loc)
			damage = 40//for the love of god, don't get landed on
			L.adjustStaminaLoss(70)

		L.apply_damage(damage, BRUTE, wound_bonus = 10, bare_wound_bonus = 20)
		push_away(user, L)

	animate(user, time = 0.1 SECONDS, pixel_y = 0)
	playsound(user, 'sound/effects/gravhit.ogg', 20, TRUE)
	playsound(user, 'sound/effects/explosion_distant.ogg', 200, FALSE, WARNING_RANGE)
	var/atom/movable/gravity_lens/shockwave = new(get_turf(user))
	shockwave.transform *= 0.1 //basically invisible
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	animate(shockwave, alpha = 0, transform = matrix().Scale(0.3), time = 2)
	QDEL_IN(shockwave, 3)

/datum/martial_art/worldshaker/handle_throw(atom/hit_atom, mob/living/carbon/human/A)
	if(leaping)
		return TRUE
	return ..()
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
		user.balloon_alert(user, span_warning("You can't do that yet!"))
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
			user.balloon_alert(user, span_warning("You can't throw something while you're inside of it!")) //as funny as throwing lockers from the inside is i dont think i can get away with it
			return
		COOLDOWN_START(src, next_grapple, COOLDOWN_GRAPPLE)
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
	var/slamdam = 5
	var/objdam = 200 //really good at breaking terrain
	var/throwdam = 10
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
					playsound(Z, 'sound/effects/gravhit.ogg', 20, TRUE)
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
	if(user == target)
		return
	to_chat(world, "pummel")
	target.apply_damage(30, BRUTE, user.zone_selected, wound_bonus = 10, bare_wound_bonus = 20)
	target.adjustStaminaLoss(30)
	if(!target.resting)//if they aren't already knocked down, throw them back one space
		if(target.anchored)
			target.anchored = FALSE
		push_away(user, target)
	stagger(target)

	user.do_attack_animation(target)
	playsound(user, 'sound/effects/gravhit.ogg', 20, TRUE, -1)
	playsound(user, 'sound/effects/meteorimpact.ogg', 50, TRUE, -1)
	
/*---------------------------------------------------------------
	end of pummel section
---------------------------------------------------------------*/
/datum/martial_art/worldshaker/handle_counter(mob/living/carbon/human/user, mob/living/carbon/human/attacker)
	push_away(user, attacker, 20)//don't EVER come at me with that B
	
/*---------------------------------------------------------------
	training related section
---------------------------------------------------------------*/
/mob/living/carbon/human/proc/worldshaker_help()
	set name = "Worldshaker"
	set desc = "You imagine all the things you would be capable of with this power."
	set category = "Worldshaker"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You think about what stunts you can pull with the power of a buster arm.</i></b>"

	combined_msg +=  "[span_notice("Leap")]: Your disarm has been replaced with a move that sends you flying forward, damaging enemies in front of you by dragging them \
	along the ground. Ramming victims into something solid does damage to them and the object. Has a 4 second cooldown."
	
	combined_msg +=  "[span_notice("Clasp")]: Your grab has been amplified, allowing you to take a target object or being into your hand for up to 10 seconds and throw them at a \
	target destination by clicking again with grab intent. Throwing them into unanchored people and objects will knock them back and deal additional damage to existing thrown \
	targets. Mechs and vending machines can be tossed as well. If the target's limb is at its limit, tear it off. Has a 3 second cooldown"

	combined_msg +=  "[span_notice("Pummel")]: Your harm has been replaced with a slam attack that places enemies behind you and smashes them against \
	whatever person, wall, or object is there for bonus damage. Has a 0.8 second cooldown."

	combined_msg +=  "[span_notice("Worldslam")]: Charge up your buster arm to put a powerful attack in the corresponding hand. The energy only lasts 5 seconds \
	but does hefty damage to its target, even breaking walls down when hitting things into them or connecting the attack directly. Landing the attack on a reinforced wall \
	destroys it but uses up the attack. Attacking a living target uses up the attack and sends them flying and dismembers their limb if its damaged enough. Has a 15 second \
	cooldown."

	combined_msg += span_notice("<b>After landing an attack, you become resistant to damage slowdown and all incoming damage by 50% for 2 seconds.</b>")

	to_chat(usr, examine_block(combined_msg.Join("\n")))

/datum/martial_art/worldshaker/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	usr.click_intercept = src 
	H.physiology.damage_resistance += 50 //50% damage reduction
	H.physiology.heat_mod = 0
	H.add_movespeed_modifier(type, update=TRUE, priority=101, multiplicative_slowdown = 0.5)//you hella chunky
	ADD_TRAIT(H, TRAIT_REDUCED_DAMAGE_SLOWDOWN, type)
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(H, TRAIT_NOLIMBDISABLE, type)
	if(!linked_stomp)
		linked_stomp = new
		linked_stomp.linked_martial = src
	linked_stomp.Grant(H)

/datum/martial_art/worldshaker/on_remove(mob/living/carbon/human/H)
	usr.click_intercept = null 
	H.physiology.damage_resistance -= 50
	H.physiology.heat_mod = initial(H.physiology.heat_mod)
	H.remove_movespeed_modifier(type)
	REMOVE_TRAIT(H, TRAIT_REDUCED_DAMAGE_SLOWDOWN, type)
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(H, TRAIT_NOLIMBDISABLE, type)
	if(linked_stomp)
		linked_stomp.Remove(H)
	..()

#undef COOLDOWN_STOMP
#undef STOMP_RADIUS
#undef STOMP_DAMAGERADIUS
#undef COOLDOWN_LEAP
#undef LEAP_RADIUS
#undef COOLDOWN_GRAPPLE
#undef STAGGER_DURATION
#undef WARNING_RANGE
