//variables for fun balance tweaks
#define COOLDOWN_STOMP 15 SECONDS
#define STOMP_RADIUS 6 //the base radius for the charged stomp
#define STOMP_DAMAGERADIUS 3
#define COOLDOWN_LEAP 1.5 SECONDS
#define LEAP_RADIUS 1
#define STAGGER_DURATION 3 SECONDS
#define WARNING_RANGE 10 //extra range to certain sound effects
#define PLATE_INTERVAL 30 SECONDS //how often a plate grows
#define PLATE_REDUCTION 10 //how much DR per plate
#define MAX_PLATES 7 //maximum number of plates that factor into damage reduction (speed decrease scales infinitely)
#define PLATE_CAP 14 //hard cap of plates to prevent station wide fuckery

/datum/martial_art/worldshaker
	name = "Worldshaker"
	id = MARTIALART_WORLDSHAKER
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/worldshaker_help
	block_chance = 100 //validhunters cry
	var/list/thrown = list()
	// COOLDOWN_DECLARE(next_stomp)
	COOLDOWN_DECLARE(next_leap)
	var/datum/action/cooldown/worldstomp/linked_stomp
	var/leaping = FALSE
	var/plates = 0
	var/plate_timer = null
	var/heavy = FALSE //

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
	if(H.a_intent == INTENT_HELP && (H==target))
		rip_plate(H)
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
	if(HAS_TRAIT(victim, TRAIT_STUNIMMUNE))
		return
	victim.set_resting(TRUE)//basically a trip
	victim.add_movespeed_modifier(id, update=TRUE, priority=101, multiplicative_slowdown = 0.5)
	addtimer(CALLBACK(src, PROC_REF(stagger_end), victim), STAGGER_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/martial_art/worldshaker/proc/stagger_end(mob/living/victim)
	victim.remove_movespeed_modifier(id)

/datum/martial_art/worldshaker/proc/push_away(mob/living/user, mob/living/victim, distance = 1)
	var/throwdirection = get_dir(user, victim)
	var/atom/throw_target = get_edge_target_turf(victim, throwdirection)
	var/throwspeed = heavy ? 3 : 2
	victim.throw_at(throw_target, distance, throwspeed, user)
/*-----------------------------
	end of helpers section
-----------------------------*/
/*---------------------------------------------------------------
	start of plates section 
---------------------------------------------------------------*/
/datum/martial_art/worldshaker/proc/grow_plate(mob/living/carbon/human/user)
	if(plates >= PLATE_CAP)//no quaking the entire station
		return
	user.balloon_alert(user, span_notice("Your plates grow thicker!"))
	plates++
	if(plates <= MAX_PLATES)
		user.physiology.damage_resistance += PLATE_REDUCTION
	update_platespeed(user)

/datum/martial_art/worldshaker/proc/rip_plate(mob/living/carbon/human/user)
	if(plates <= 0)
		user.balloon_alert(user, span_warning("Your plates are too thin to tear off a piece of!"))
		return
	if(user.get_active_held_item())
		user.balloon_alert(user, span_warning("You need an empty hand to tear off some of your plate!"))
		return
	user.balloon_alert(user, span_notice("You tear off a loose plate!"))

	if(plates <= MAX_PLATES)
		user.physiology.damage_resistance -= PLATE_REDUCTION
	plates--
	update_platespeed(user)
	var/obj/item/worldplate/plate = new()
	plate.linked_martial = src
	user.put_in_active_hand(plate)
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living/carbon, throw_mode_on))//so the plate isn't instantly thrown

/datum/martial_art/worldshaker/proc/update_platespeed(mob/living/carbon/human/user)//slowdown scales infinitely (damage reduction doesn't)
	heavy = plates > MAX_PLATES
	var/platespeed = (plates * 0.2) - 0.5 //faster than normal if either no or few plates
	user.remove_movespeed_modifier(type)
	user.add_movespeed_modifier(type, update=TRUE, priority=101, multiplicative_slowdown = platespeed, blacklisted_movetypes=(FLOATING))

/obj/item/worldplate
	name = "worldshaker plate"
	desc = "A sizeable plasteel plate, you can barely imagine the strength it would take to throw this."
	icon = 'yogstation/icons/obj/stack_objects.dmi'
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	materials = list(/datum/material/iron=2000, /datum/material/plasma=2000)
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	force = 5
	throwforce = 5 //more of a ranged CC than a ranged weapon
	throw_speed = 4
	throw_range = 7
	var/datum/martial_art/worldshaker/linked_martial

/obj/item/worldplate/equipped(mob/user, slot, initial)//difficult for regular people to throw
	. = ..()
	var/worldshaker = (user.mind?.martial_art && istype(user.mind.martial_art, /datum/martial_art/worldshaker))
	throw_speed = worldshaker ? 4 : 1
	throw_range = worldshaker ? 7 : 4

/obj/item/worldplate/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!linked_martial)
		return
	if(isliving(hit_atom) && throwingdatum)
		var/mob/living/L = hit_atom
		linked_martial.stagger(L)
		linked_martial.push_away(throwingdatum.thrower, L)
	
/*---------------------------------------------------------------
	end of plates section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of stomp section 
---------------------------------------------------------------*/
/datum/action/cooldown/worldstomp
	name = "Quake"
	desc = "Put all your weight and strength into a singular stomp."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "lizard_tackle"
	background_icon_state = "bg_default"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	var/datum/martial_art/worldshaker/linked_martial
	cooldown_time = COOLDOWN_STOMP
	var/charging = FALSE

/datum/action/cooldown/worldstomp/IsAvailable()
	if(!linked_martial || !linked_martial.can_use(owner))
		return FALSE
	return ..()

/datum/action/cooldown/worldstomp/Trigger()
	if(!IsAvailable() || charging)
		return
	charging = TRUE
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(owner.loc, owner)
	animate(D, alpha = 128, color = "#000000", transform = matrix()*2, time = 1 SECONDS)
	if(!do_after(owner, 1 SECONDS, owner) || !IsAvailable())
		charging = FALSE
		qdel(D)
		return
	charging = FALSE
	StartCooldown()
	animate(D, color = "#000000", transform = matrix()*0, time = 2)
	QDEL_IN(D, 3)

	var/plates = linked_martial.plates
	for(var/mob/living/L in range(STOMP_RADIUS + plates, owner))
		if(L == owner)
			continue
		linked_martial.stagger(L)
		var/damage = 5
		var/throwdistance = 1
		if(L in range(STOMP_DAMAGERADIUS + (plates/2), owner))//more damage and CC if closer
			damage = 30
			throwdistance = 3
			L.Knockdown(30)
		if(L.loc == owner.loc)//if the are standing directly ontop of you, you're fucked
			damage = 40
			L.adjustStaminaLoss(70)
		L.apply_damage(damage, BRUTE, wound_bonus = 10, bare_wound_bonus = 20)
		linked_martial.push_away(owner, L, throwdistance)
	for(var/obj/item/I in range(STOMP_RADIUS + plates, owner))
		var/throwdirection = get_dir(owner, I)
		var/atom/throw_target = get_edge_target_turf(I, throwdirection)
		I.throw_at(throw_target, 3, 2, owner)
	for(var/obj/structure/S in range(STOMP_DAMAGERADIUS + (plates/2), owner))
		S.take_damage(25)

	//flavour stuff
	playsound(owner, get_sfx("explosion_creaking"), 100, TRUE, STOMP_RADIUS)
	playsound(owner, 'sound/effects/explosion_distant.ogg', 200, FALSE, STOMP_RADIUS + WARNING_RANGE)
	var/atom/movable/gravity_lens/shockwave = new(get_turf(owner))
	shockwave.transform *= 0.1 //basically invisible
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	animate(shockwave, alpha = 0, transform = matrix().Scale(1 + (plates/4)), time = (3 SECONDS + plates))
	QDEL_IN(shockwave, 3.1 SECONDS + plates)

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
	COOLDOWN_START(src, next_leap, COOLDOWN_LEAP + plates)//longer cooldown the more plates you have

	leaping = TRUE
	var/jumpspeed = heavy ? 1 : 3
	user.throw_at(target, 15, jumpspeed, user, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(leap_end), user))
	user.Immobilize(1 SECONDS, ignore_canstun = TRUE) //to prevent cancelling the leap

	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(user.loc,user)
	animate(D, alpha = 0, color = "#000000", transform = matrix()*2, time = 0.3 SECONDS)
	animate(user, time = 0.2 SECONDS, pixel_y = 20)//we up in the air
	playsound(user, 'sound/effects/gravhit.ogg', 20)
	playsound(user, 'sound/effects/dodge.ogg', 15, TRUE)

/datum/martial_art/worldshaker/proc/leap_end(mob/living/carbon/human/user)
	user.SetImmobilized(0 SECONDS, ignore_canstun = TRUE)
	leaping = FALSE

	for(var/mob/living/L in range(LEAP_RADIUS,user))
		if(L == user)
			continue
		stagger(L)
		var/damage = heavy ? 30 : 15 //chunky boy does more damage

		if(L.loc == user.loc)
			damage *= 2//for the love of god, don't get landed on
			L.adjustStaminaLoss(damage)

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
	stagger(target)
	var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
	var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
	target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
	
/datum/martial_art/worldshaker/proc/drop(mob/living/target)//proc for clearing the thrown list, mostly so the lob proc doesnt get triggered when it shouldn't
	for(var/atom/movable/K in thrown)
		thrown.Remove(K)

/datum/martial_art/worldshaker/proc/grapple(mob/living/user, atom/target) //proc for picking something up to toss
	var/turf/Z = get_turf(user)
	target.add_fingerprint(user, FALSE)

	if(isliving(target) && target != user)
		playsound(user, 'sound/effects/servostep.ogg', 60, FALSE, -1) //play sound here incase some ungrabbable object was clicked
		var/mob/living/L = target
		var/obj/structure/bed/grip/F = new(Z, user) // Buckles them to an invisible bed
		L.density = FALSE
		L.visible_message(span_warning("[user] grabs [L] and lifts [L.p_them()] off the ground!"))
		L.Stun(1 SECONDS) //so the user has time to aim their throw
		to_chat(L, span_userdanger("[user] grapples you and lifts you up into the air! Resist [user.p_their()] grip!"))
		L.forceMove(Z)
		F.buckle_mob(target)
		walk_towards(F, user, 0, 0)
		if(get_dist(L, user) > 1)
			L.density = initial(L.density)
			return
		thrown |= L // Marks the mob to throw
		return

/datum/martial_art/worldshaker/proc/lob(mob/living/user, atom/target) //proc for throwing something you picked up with grapple
	var/slamdam = heavy ? 10 : 5
	var/objdam = heavy ? 400 : 200 //really good at breaking terrain, reduces as the damage is dealt
	var/throwdam = heavy ? 20 : 10
	var/target_dist = get_dist(user, target)
	var/turf/D = get_turf(target)	
	var/atom/tossed = thrown[1]
	walk(tossed,0)
	tossed.density = initial(tossed.density)
	user.stop_pulling()
	if(get_dist(tossed, user) > 1)//cant reach the thing i was supposed to be throwing anymore
		drop()
		return 
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
		if(QDELETED(tossed) || objdam <= 0)//if the thrown item broke, or total damage has run out, end the throw
			return
		var/dir_to_target = get_dir(get_turf(tossed), D) //vars that let the thing be thrown while moving similar to things thrown normally
		var/turf/T = get_step(get_turf(tossed), dir_to_target)
		if(T.density) // crash into a wall and damage everything flying towards it before stopping 
			for(var/mob/living/S in thrown)
				grab(user, S, slamdam) 
				S.Knockdown(1.5 SECONDS)
				S.Immobilize(1.5 SECONDS)
				if(isanimal(S) && S.stat == DEAD)
					S.gib()	
			drop()
			return
		for(var/obj/Z in T.contents) // crash into something solid and damage it along with thrown objects that hit it
			if(Z.density) // If the thing is solid and anchored like a window or grille or table it hurts people thrown that crash into it too
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
				var/reduction = Z.obj_integrity
				Z.take_damage(objdam)
				objdam -= reduction
				if(Z.density)
					playsound(Z, 'sound/effects/gravhit.ogg', 40, TRUE, 5)
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
		if(T) // if the next tile wont stop the thrown mass from continuing
			for(var/mob/living/S in thrown)
				S.Knockdown(1.5 SECONDS)
				S.Immobilize(1.5 SECONDS)
			for(var/atom/movable/K in thrown) // to make the mess of things that's being thrown almost look like a normal throw
				K.SpinAnimation(0.2 SECONDS, 1) 
				K.forceMove(T)
				if(isspaceturf(T)) // throw them like normal if it's into space
					var/atom/throw_target = get_edge_target_turf(K, dir_to_target)
					K.throw_at(throw_target, 6, 5, user, 3)
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
	for(var/mob/living/L in range(1, user))
		var/damage = 10
		if(L == user)
			continue
		if(L == target)
			damage = 30 //the target takes more stamina and brute damage

		if(!L.resting)//if they aren't already knocked down, throw them back one space
			if(L.anchored)
				L.anchored = FALSE
			push_away(user, L)
		stagger(L)
		L.apply_damage(damage, BRUTE, user.zone_selected, wound_bonus = 10, bare_wound_bonus = 20)
		L.adjustStaminaLoss(damage)

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
	H.physiology.heat_mod -= 1 //walk through that fire all you like, hope you don't care about your clothes
	plate_timer = addtimer(CALLBACK(src, PROC_REF(grow_plate), H), PLATE_INTERVAL, TIMER_LOOP|TIMER_UNIQUE|TIMER_STOPPABLE)//start regen
	update_platespeed(H)
	ADD_TRAIT(H, TRAIT_REDUCED_DAMAGE_SLOWDOWN, type)
	ADD_TRAIT(H, TRAIT_BOMBIMMUNE, type)//maxcap suicide bombers can go fuck themselves
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(H, TRAIT_NOLIMBDISABLE, type)
	if(!linked_stomp)
		linked_stomp = new
		linked_stomp.linked_martial = src
	linked_stomp.Grant(H)

/datum/martial_art/worldshaker/on_remove(mob/living/carbon/human/H)
	usr.click_intercept = null 
	H.physiology.heat_mod += 1
	H.physiology.damage_resistance -= PLATE_REDUCTION * min(plates, MAX_PLATES)
	H.remove_movespeed_modifier(type)
	deltimer(plate_timer)
	REMOVE_TRAIT(H, TRAIT_REDUCED_DAMAGE_SLOWDOWN, type)
	REMOVE_TRAIT(H, TRAIT_BOMBIMMUNE, type)
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
#undef STAGGER_DURATION
#undef WARNING_RANGE
