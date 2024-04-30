//variables for fun balance tweaks
#define BALLOON_COOLDOWN 1 SECONDS  //limit the balloon alert spam of rapid click
#define STAGGER_DURATION 3 SECONDS
#define WARNING_RANGE 10 //extra range to certain sound effects

#define COOLDOWN_STOMP 30 SECONDS
#define STOMP_WINDUP 2 SECONDS //this gets doubled if heavy
#define STOMP_RADIUS 8 //the base radius for the charged stomp, only does damage in an area half this size

#define COOLDOWN_LEAP 2 SECONDS
#define LEAP_RADIUS 1

#define COOLDOWN_PUMMEL 0.8 SECONDS //basically melee

#define PLATE_INTERVAL 15 SECONDS //how often a plate grows
#define PLATE_REDUCTION 20 //how much DR per plate
#define MAX_PLATES 5 //maximum number of plates that factor into damage reduction (speed decrease scales infinitely)
#define PLATE_CAP MAX_PLATES + 3 //hard cap of plates to prevent station wide fuckery
#define PLATE_BREAK 25 //How much damage it takes to break a plate

#define THROW_MOBDMG 5 //the damage dealt per object impacted during a throw
#define THROW_OBJDMG 500 //Total amount of structure damage that can be done
#define COOLDOWN_GRAB 1.2 SECONDS //basically just to prevent infinite stunlock spam

/datum/martial_art/worldbreaker
	name = "Worldbreaker"
	id = MARTIALART_WORLDBREAKER
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/worldbreaker_help
	var/recalibration = /mob/living/carbon/human/proc/worldbreaker_recalibration
	var/list/thrown = list()
	COOLDOWN_DECLARE(next_leap)
	COOLDOWN_DECLARE(next_grab)
	COOLDOWN_DECLARE(next_balloon)
	COOLDOWN_DECLARE(next_pummel)
	var/datum/action/cooldown/worldstomp/linked_stomp
	var/plates = 0
	var/plate_timer = null
	var/heavy = FALSE
	var/currentplate = 0 //how much damage the current plate has taken

/datum/martial_art/worldbreaker/can_use(mob/living/carbon/human/H)
	if(H.stat == DEAD || H.IsUnconscious() || H.incapacitated(TRUE, TRUE) || HAS_TRAIT(H, TRAIT_PACIFISM))//extra pacifism check because it does weird shit
		return FALSE
	return ispreternis(H)

/datum/martial_art/worldbreaker/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return TRUE //you're doing enough pushing as is

/datum/martial_art/worldbreaker/harm_act(mob/living/carbon/human/A, mob/living/D)
	return TRUE //no punch, just pummel

/datum/martial_art/worldbreaker/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/target)
	var/list/modifiers = params2list(params)
	if(!can_use(H) || (modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"]))
		return

	if(isitem(target))//don't attack if we're clicking on our inventory
		var/obj/item/thing = target
		if(thing in H.get_all_contents())
			return

	if(H.a_intent == INTENT_DISARM)
		leap(H, target)

	if(H.get_active_held_item()) //most abilities need an empty hand
		return

	if(H.a_intent == INTENT_HELP && (H==target))
		rip_plate(H)
	if(thrown.len > 0 && H.a_intent == INTENT_GRAB)
		if(get_turf(target) != get_turf(H))
			throw_start(H, target)

	if(H.a_intent == INTENT_HARM)//technically can punch yourself, but with how it works, you won't actually hurt yourself
		pummel(H,target)

	if(!H.Adjacent(target))
		return

	if(H == target)
		return

	if(H.a_intent == INTENT_GRAB && isliving(target))
		grapple(H,target)

	
/*-------------------------------------------------------------
	start of helpers section
---------------------------------------------------------*/
/datum/martial_art/worldbreaker/proc/stagger(mob/living/victim)
	if(HAS_TRAIT(victim, TRAIT_STUNIMMUNE))
		return
	victim.add_movespeed_modifier(id, update=TRUE, priority=101, multiplicative_slowdown = 0.5)
	addtimer(CALLBACK(src, PROC_REF(stagger_end), victim), STAGGER_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/martial_art/worldbreaker/proc/stagger_end(mob/living/victim)
	victim.remove_movespeed_modifier(id)

/datum/martial_art/worldbreaker/proc/push_away(mob/living/user, atom/movable/victim, distance = 1)
	if(victim.anchored)
		return
	if(get_turf(victim) == get_turf(user))
		return
	if(istype(victim, /obj/item/worldplate))
		var/obj/item/worldplate/plate = victim
		plate.worldbreaker = TRUE
	var/throwdirection = get_dir(user, victim)
	var/atom/throw_target = get_edge_target_turf(victim, throwdirection)
	var/throwspeed = 1
	if(heavy)
		throwspeed *= 2
		distance *= 2
	victim.throw_at(throw_target, distance, throwspeed, user)

/datum/martial_art/worldbreaker/proc/hurt(mob/living/user, mob/living/target, damage)//proc the moves will use for damage dealing
	stagger(target)
	var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
	var/meleearmor = target.run_armor_check(limb_to_hit, MELEE)
	var/bombarmor = target.run_armor_check(limb_to_hit, BOMB)
	var/truearmor = (meleearmor + bombarmor) / 2 //take an average of melee and bomb armour
	target.apply_damage(damage, BRUTE, blocked = truearmor)
	target.apply_damage(damage * 2, STAMINA, blocked = truearmor)//double damage for stamina
/*---------------------------------------------------------------
	end of helpers section
----------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of plates section 
---------------------------------------------------------------*/
/datum/martial_art/worldbreaker/proc/grow_plate(mob/living/carbon/human/user)
	if(plates >= PLATE_CAP || user.stat == DEAD || !can_use(user))//no quaking the entire station
		return
	user.balloon_alert(user, span_notice("your plates grow thicker!"))
	adjust_plates(user, 1)
	update_platespeed(user)

/datum/martial_art/worldbreaker/proc/rip_plate(mob/living/carbon/human/user)
	if(plates <= 0)
		to_chat(user, span_warning("Your plates are too thin to tear off a piece!"))
		return
	user.balloon_alert(user, span_notice("you tear off a loose plate!"))

	currentplate = 0
	adjust_plates(user, -1)
	update_platespeed(user)
	var/obj/item/worldplate/plate = new()
	plate.linked_martial = src
	user.put_in_active_hand(plate)
	user.changeNext_move(0.1)//entirely to prevent hitting yourself instantly
	user.throw_mode_on()

/datum/martial_art/worldbreaker/proc/lose_plate(mob/living/carbon/human/user, damage, damagetype, def_zone)
	if(plates <= 0)//no plate to lose
		return

	deltimer(plate_timer)//reset the plate timer
	plate_timer = addtimer(CALLBACK(src, PROC_REF(grow_plate), user), PLATE_INTERVAL, TIMER_LOOP|TIMER_UNIQUE|TIMER_STOPPABLE)

	if(damagetype != BRUTE && damagetype != BURN)
		damage /= 4 //brute and burn are most effective

	currentplate += damage

	if(currentplate < PLATE_BREAK)
		return

	user.visible_message(span_notice("one of [user]'s plates falls to the ground!"), span_userdanger("one of your loose plates falls off from excessive wear!"))
	while(currentplate >= PLATE_BREAK)
		currentplate -= PLATE_BREAK
		adjust_plates(user, -1)
		update_platespeed(user)
		var/obj/item/worldplate/plate = new(get_turf(user))//dropped to the ground
		plate.linked_martial = src

		if(plates <= 0)//can't lose any more plates if you have none
			currentplate = 0

/datum/martial_art/worldbreaker/proc/update_platespeed(mob/living/carbon/human/user)//slowdown scales infinitely (damage reduction doesn't)
	heavy = plates >= MAX_PLATES
	var/platespeed = (plates * 0.25) - 0.5 //faster than normal if either no or few plates
	user.remove_movespeed_modifier(type)
	user.add_movespeed_modifier(type, update=TRUE, priority=101, multiplicative_slowdown = platespeed, blacklisted_movetypes=(FLOATING))
	var/datum/species/preternis/S = user.dna.species
	if(istype(S))
		if(heavy)//sort of a sound indicator that you're in "heavy mode"
			S.special_step_sounds = list('sound/effects/gravhit.ogg')//heavy boy get stompy footsteps
			S.special_step_volume = 9 //prevent it from blowing out ears
			ADD_TRAIT(user, TRAIT_BOMBIMMUNE, type)//maxcap suicide bombers can go fuck themselves
			ADD_TRAIT(user, TRAIT_RESISTCOLD, type)
			ADD_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, type)
			ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, type)
		else
			S.special_step_sounds = list('sound/effects/footstep/catwalk1.ogg', 'sound/effects/footstep/catwalk2.ogg', 'sound/effects/footstep/catwalk3.ogg', 'sound/effects/footstep/catwalk4.ogg')
			S.special_step_volume = 50
			REMOVE_TRAIT(user, TRAIT_BOMBIMMUNE, type)
			REMOVE_TRAIT(user, TRAIT_RESISTCOLD, type)
			REMOVE_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, type)
			REMOVE_TRAIT(user, TRAIT_RESISTLOWPRESSURE, type)

/datum/martial_art/worldbreaker/proc/adjust_plates(mob/living/carbon/human/user, amount = 0)
	if(amount == 0)
		return

	var/plate_change = clamp(amount + plates, 0, MAX_PLATES) - min(plates, MAX_PLATES)
	if(plate_change)
		user.physiology.armor = user.physiology.armor.modifyAllRatings(plate_change * PLATE_REDUCTION)

	plates = clamp(plates + amount, 0, PLATE_CAP)

//the plates in question
/obj/item/worldplate
	name = "worldbreaker plate"
	desc = "A sizeable plasteel plate, you can barely imagine the strength it would take to throw this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "sharp"
	item_state = "tile-darkshuttle"
	lefthand_file = 'icons/mob/inhands/misc/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/tiles_righthand.dmi'
	materials = list(/datum/material/iron=2000, /datum/material/plasma=2000)
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	force = 5
	w_class = WEIGHT_CLASS_HUGE //no storing them
	throwforce = 10 //more of a ranged CC than a ranged weapon
	throw_speed = 3
	throw_range = 8
	var/datum/martial_art/worldbreaker/linked_martial
	var/worldbreaker = FALSE //whether or not it was thrown by the martial art user

/obj/item/worldplate/equipped(mob/user, slot, initial)//difficult for regular people to throw
	. = ..()
	throw_speed = 1
	throw_range = 3
	worldbreaker = user.mind?.has_martialart(MARTIALART_WORLDBREAKER)
	if(worldbreaker)
		throw_speed = 3
		throw_range = 10

/obj/item/worldplate/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!linked_martial)
		return
	if(worldbreaker)
		if(isliving(hit_atom) && throwingdatum)
			var/mob/living/L = hit_atom
			linked_martial.stagger(L)
			linked_martial.push_away(throwingdatum.thrower, L)
	
/*---------------------------------------------------------------
	end of plates section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of leap section
---------------------------------------------------------------*/
/datum/martial_art/worldbreaker/proc/leap(mob/living/user, atom/target)
	if(!COOLDOWN_FINISHED(src, next_leap))
		if(COOLDOWN_FINISHED(src, next_balloon))
			COOLDOWN_START(src, next_balloon, BALLOON_COOLDOWN)
			user.balloon_alert(user, span_warning("you can't do that yet!"))
		return
	if(!target)
		return
	COOLDOWN_START(src, next_leap, COOLDOWN_LEAP * 3)//should last longer than the leap, but just in case

	//telegraph ripped entirely from bubblegum charge
	if(heavy)
		var/telegraph = get_turf(target)
		if(telegraph && (telegraph in view(15, get_turf(user))))//only show the telegraph if the telegraph is actually correct, hard to get an accurate one since raycasting isn't a thing afaik
			new /obj/effect/temp_visual/dragon_swoop/bubblegum(telegraph)

	var/jumpspeed = 4 - user.cached_multiplicative_slowdown
	jumpspeed = clamp(jumpspeed, 0.75, 4)

	user.throw_at(target, 15, jumpspeed, user, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(leap_end), user))
	user.Immobilize(1 SECONDS, ignore_canstun = TRUE) //to prevent cancelling the leap

	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(user.loc,user)
	animate(D, alpha = 0, color = "#000000", transform = matrix()*2, time = 0.3 SECONDS)
	animate(user, time = (heavy ? 0.4 : 0.2)SECONDS, pixel_y = 20)//we up in the air
	addtimer(CALLBACK(src, PROC_REF(reset_pixel), user), 1.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)//in case something happens, we don't permanently float
	playsound(user, 'sound/effects/gravhit.ogg', 15)
	playsound(user, 'sound/effects/dodge.ogg', 15, TRUE)

/datum/martial_art/worldbreaker/proc/leap_end(mob/living/carbon/human/user)
	if(!COOLDOWN_FINISHED(src, next_leap))
		COOLDOWN_START(src, next_leap, COOLDOWN_LEAP + (heavy ? 1 SECONDS : 0))
	user.SetImmobilized(0 SECONDS, ignore_canstun = TRUE)
	var/range = LEAP_RADIUS
	if(heavy)//heavy gets doubled range
		range *= 2
		
	for(var/mob/living/L in range(range,user))
		if(L == user)
			continue
		var/damage = 20

		if(L.loc == user.loc)
			to_chat(L, span_userdanger("[user] lands directly ontop of you, crushing you beneath their immense weight!"))
			damage *= 2//for the love of god, don't get landed on

		hurt(user, L, damage)
		push_away(user, L)
		if(L.loc == user.loc && isanimal(L) && L.stat == DEAD)
			L.gib()
	for(var/obj/obstruction in range(range, user))
		if(isitem(obstruction))
			push_away(user, obstruction)
			continue
		if(!isstructure(obstruction) && !ismachinery(obstruction) && !ismecha(obstruction))
			continue
		var/damage = 5
		if(obstruction.loc == user.loc)
			damage *= 3
		obstruction.take_damage(damage, sound_effect = FALSE) //reduced sound from hitting LOTS of things

	animate(user, time = 0.1 SECONDS, pixel_y = 0)
	playsound(user, 'sound/effects/gravhit.ogg', 20, TRUE)
	playsound(user, 'sound/effects/explosion_distant.ogg', 200, FALSE, WARNING_RANGE)
	var/atom/movable/gravity_lens/shockwave = new(get_turf(user))
	shockwave.transform *= 0.1 //basically invisible
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	animate(shockwave, alpha = 0, transform = matrix().Scale(range/3), time = 1 + (range/10))
	QDEL_IN(shockwave, 2 + (range/10))

/datum/martial_art/worldbreaker/proc/reset_pixel(mob/living/user)//in case something happens, we don't permanently float
	animate(user, time = 0.1 SECONDS, pixel_y = 0)

/datum/martial_art/worldbreaker/handle_throw(atom/hit_atom, mob/living/carbon/human/A, datum/thrownthing/throwingdatum)//never wallsplat ever
	return TRUE
/*---------------------------------------------------------------
	end of leap section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of grapple section
---------------------------------------------------------------*/	
/datum/martial_art/worldbreaker/proc/drop()//proc for clearing the thrown list, mostly so the lob proc doesnt get triggered when it shouldn't
	for(var/atom/movable/thing in thrown)
		thrown.Remove(thing)

/datum/martial_art/worldbreaker/proc/grapple(mob/living/user, atom/target) //proc for picking something up to toss
	var/turf/Z = get_turf(user)
	target.add_fingerprint(user, FALSE)

	if(isliving(target) && target != user)
		if(!COOLDOWN_FINISHED(src, next_grab))
			return
		COOLDOWN_START(src, next_grab, COOLDOWN_GRAB)
		user.changeNext_move(COOLDOWN_GRAB + 1)

		playsound(user, 'sound/weapons/thudswoosh.ogg', 65, FALSE, -1) //play sound here incase some ungrabbable object was clicked
		var/mob/living/victim = target
		var/obj/structure/bed/grip/F = new(Z, user) // Buckles them to an invisible bed
		F.name = "worldbreaker"
		victim.density = FALSE
		victim.visible_message(span_warning("[user] grabs [victim] and lifts [victim.p_them()] off the ground!"))
		victim.Stun(1 SECONDS) //so the user has time to aim their throw
		to_chat(victim, span_userdanger("[user] grapples you and lifts you up into the air! Resist [user.p_their()] grip!"))
		victim.forceMove(Z)
		F.buckle_mob(target)
		walk_towards(F, user, 0, 0)
		if(get_dist(victim, user) > 1)
			victim.density = initial(victim.density)
			return
		thrown |= victim // Marks the mob to throw
		return

/datum/martial_art/worldbreaker/proc/throw_start(mob/living/user, atom/target)//proc for throwing something you picked up with grapple
	var/target_dist = get_dist(user, target)
	var/turf/D = get_turf(target)	
	var/atom/tossed = thrown[1]
	
	walk(tossed,0)
	tossed.density = initial(tossed.density)
	user.stop_pulling()
	if(get_dist(tossed, user) > 1)//cant reach the thing i was supposed to be throwing anymore
		drop()
		return 
	if(iscarbon(tossed))
		var/mob/living/carbon/tossedliving = thrown[1]
		if(!tossedliving.buckled)
			return
		for(var/obj/structure/bed/grip/holder in view(1, user))
			holder.Destroy()
	user.visible_message(span_warning("[user] throws [tossed]!"))

	throw_process(user, target_dist, 1, tossed, D, THROW_OBJDMG)

/datum/martial_art/worldbreaker/proc/throw_process(mob/living/user, target_dist, current_dist, atom/tossed, turf/target, remaining_damage)//each call of the throw loop
	if(!target_dist || !current_dist || !tossed || current_dist > target_dist)
		drop()
		return
	if(remaining_damage <= 0)// or total damage has run out, end the throw
		drop()
		playsound(get_turf(tossed), 'sound/effects/gravhit.ogg', 60, TRUE, 5)
		playsound(get_turf(tossed), 'sound/effects/meteorimpact.ogg', 50, TRUE, 5)
		return

	var/dir_to_target = get_dir(get_turf(tossed), target) //vars that let the thing be thrown while moving similar to things thrown normally
	var/turf/T = get_step(get_turf(tossed), dir_to_target)
	if(T?.density) // crash into a wall and damage everything flying towards it before stopping 
		for(var/mob/living/victim in thrown)
			hurt(user, victim, THROW_MOBDMG) 
			victim.Knockdown(1 SECONDS)
			victim.Immobilize(0.5 SECONDS)
			if(isanimal(victim) && victim.stat == DEAD)
				victim.gib()	
		playsound(T, 'sound/effects/gravhit.ogg', 60, TRUE, 5)
		playsound(T, 'sound/effects/meteorimpact.ogg', 50, TRUE, 5)
		drop()
		return
	for(var/obj/thing in T.contents) // crash into something solid and damage it along with thrown objects that hit it
		if(thing.density) // If the thing is solid and anchored like a window or grille or table it hurts people thrown that crash into it too
			for(var/mob/living/victim in thrown) 
				hurt(user, victim, THROW_MOBDMG) 
				victim.Knockdown(1 SECONDS)
				victim.Immobilize(0.5 SECONDS)
				if(isanimal(victim) && victim.stat == DEAD)
					victim.gib()
				if(istype(thing, /obj/machinery/disposal/bin)) // dumpster living things tossed into the trash
					var/obj/machinery/disposal/bin/dumpster = thing
					victim.forceMove(thing)
					thing.visible_message(span_warning("[victim] is thrown down the trash chute!"))
					dumpster.do_flush()
					drop()
					return
			var/reduction = thing.get_integrity()
			thing.take_damage(remaining_damage)
			remaining_damage -= reduction
			if(thing.density)
				throw_process(user, target_dist, current_dist, tossed, target, remaining_damage)//keep damaging until the damage dealt is run out
				return
	for(var/mob/living/hit in T.contents) // if the thrown mass hits a person then they get tossed and hurt too along with people in the thrown mass
		if(user != hit)
			hurt(user, hit, THROW_MOBDMG) 
			hit.Knockdown(1 SECONDS) 
			for(var/mob/living/victim in thrown)
				hurt(user, victim, THROW_MOBDMG) 
				victim.Knockdown(1 SECONDS) 
			thrown |= hit
	if(T) // if the next tile wont stop the thrown mass from continuing
		for(var/atom/movable/thing in thrown) // to make the mess of things that's being thrown almost look like a normal throw
			if(isliving(thing))
				var/mob/living/victim = thing
				victim.Knockdown(1 SECONDS)
				victim.Immobilize(0.5 SECONDS)
			thing.SpinAnimation(0.2 SECONDS, 1) 
			thing.forceMove(T)
			if(isspaceturf(T)) // throw them like normal if it's into space
				var/atom/throw_target = get_edge_target_turf(thing, dir_to_target)
				thing.throw_at(throw_target, 6, 10, user, 3)//lol bye
				thrown.Remove(thing)
		addtimer(CALLBACK(src, PROC_REF(throw_process), user, target_dist, current_dist + 1, tossed, target, remaining_damage), 0.1)

/*---------------------------------------------------------------
	end of grapple section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of pummel section
---------------------------------------------------------------*/
/datum/martial_art/worldbreaker/proc/pummel(mob/living/user, atom/target)
	if(user == target)
		return
	if(!COOLDOWN_FINISHED(src, next_pummel))
		return
	COOLDOWN_START(src, next_pummel, COOLDOWN_PUMMEL)
	user.changeNext_move(COOLDOWN_PUMMEL + 1)//so things don't work weirdly when spamming on windows or whatever

	var/center = get_step_towards(user, target)

	user.do_attack_animation(center, ATTACK_EFFECT_SMASH)
	playsound(get_turf(center), 'sound/effects/gravhit.ogg', 20, TRUE, -1)
	playsound(get_turf(center), 'sound/effects/meteorimpact.ogg', 50, TRUE, -1)
	var/atom/movable/gravity_lens/shockwave = new(get_turf(center))
	shockwave.transform *= 0.1 //basically invisible
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	shockwave.alpha = 100 //slightly weaker looking
	animate(shockwave, alpha = 0, transform = matrix().Scale(0.24), time = 3)//the scale of this is VERY finely tuned to range
	QDEL_IN(shockwave, 4)

	for(var/mob/living/L in range(1, get_turf(center)))
		if(L == user)
			continue
		var/damage = 5
		if(get_turf(L) == get_turf(center))
			damage *= 4 //anyone in the center takes more

		if(L.anchored)
			L.anchored = FALSE
		push_away(user, L)
		hurt(user, L, damage)
	for(var/obj/obstruction in range(1, get_turf(center)))
		if(isitem(obstruction))
			push_away(user, obstruction)
			continue
		if(!isstructure(obstruction) && !ismachinery(obstruction) && !ismecha(obstruction))
			continue
		var/damage = 10
		if(isstructure(obstruction) || ismecha(obstruction))
			damage += 5
		if(get_turf(obstruction) == get_turf(center))
			damage *= 3
		obstruction.take_damage(damage, sound_effect = FALSE) //reduced sound from hitting LOTS of things

/*---------------------------------------------------------------
	end of pummel section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of stomp section 
---------------------------------------------------------------*/
/datum/action/cooldown/worldstomp
	name = "Worldstomp"
	desc = "Put all your weight and strength into a singular stomp."
	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	button_icon_state = "lightning"
	background_icon_state = "bg_default"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	var/datum/martial_art/worldbreaker/linked_martial
	cooldown_time = COOLDOWN_STOMP
	var/charging = FALSE

/datum/action/cooldown/worldstomp/IsAvailable(feedback = FALSE)
	if(!linked_martial || !linked_martial.can_use(owner))
		return FALSE
	return ..()

/datum/action/cooldown/worldstomp/Trigger()
	if(!IsAvailable() || charging)
		return
	var/plates = linked_martial.plates
	var/heavy = linked_martial.heavy

	charging = TRUE
	owner.visible_message(span_danger("[owner] prepares to stomp the ground with all their might!"), span_notice("you build up power in your legs, preparing to stomp with all you have!"))
	var/obj/effect/temp_visual/decoy/tensecond/D = new /obj/effect/temp_visual/decoy/tensecond(owner.loc, owner)
	animate(D, alpha = 128, color = "#000000", transform = matrix()*2, time = (heavy ? STOMP_WINDUP * 2 : STOMP_WINDUP))
	if(!do_after(owner, (heavy ? STOMP_WINDUP * 2 : STOMP_WINDUP), owner) || !IsAvailable())
		charging = FALSE
		qdel(D)
		return
	charging = FALSE
	StartCooldown()
	animate(D, color = "#000000", transform = matrix()*0, time = 2)
	QDEL_IN(D, 3)

	var/actual_range = STOMP_RADIUS + plates
	for(var/mob/living/L in range(actual_range, owner))
		if(L == owner)
			shake_camera(L, 1 SECONDS, 0.5)
			continue
		var/damage = 0
		var/throwdistance = 1
		var/shake_duration = 1 SECONDS
		var/distance = get_dist(get_turf(L), owner)
		var/shake_strength = clamp(sqrt(actual_range - distance) * 0.5, 0, 5)

		if(L in range(actual_range/2, owner))//damage and CC if closer
			shake_duration += 1 SECONDS
			damage = 15
			throwdistance = 2
			L.Knockdown(30)

		if(L.loc == owner.loc)//if they are standing directly ontop of you, you're probably fucked
			shake_duration += 1 SECONDS
			to_chat(L, span_userdanger("[owner] slams you into the ground with so much force that you're certain your ribs have been collapsed!"))
			damage *= 4
			L.Stun(5 SECONDS)

		linked_martial.hurt(owner, L, damage)
		linked_martial.push_away(owner, L, throwdistance)
		shake_camera(L, shake_duration, shake_strength)
		if(L.loc == owner.loc && isanimal(L) && L.stat == DEAD)//gib any animals you are standing on
			L.gib()
	for(var/obj/item/I in range(actual_range, owner))
		linked_martial.push_away(owner, I, 2)
	for(var/obj/obstruction in range(actual_range/2, owner))
		if(!isstructure(obstruction) && !ismachinery(obstruction) && !ismecha(obstruction))
			continue
		var/damage = 10
		if(isstructure(obstruction) || ismecha(obstruction)) //less damage to machinery because machinery is actually important, and if it was 20 or higher it would 100% break all lights within range
			damage += 15 + (plates * 3)
		obstruction.take_damage(damage) //we WANT this one to be loud

	if(get_turf(owner))//fuck that tile up
		var/turf/open/floor/target = get_turf(owner)
		if(istype(target))
			target.break_tile()

	//flavour stuff
	if(heavy)
		flicker_all_lights()
		playsound(owner, get_sfx(SFX_EXPLOSION_CREAKING), 100, TRUE, STOMP_RADIUS + (WARNING_RANGE * 2))
	playsound(owner, 'sound/effects/explosion_distant.ogg', 200, FALSE, STOMP_RADIUS + WARNING_RANGE)
	var/atom/movable/gravity_lens/shockwave = new(get_turf(owner))
	shockwave.transform *= 0.1 //basically invisible
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	animate(shockwave, alpha = 0, transform = matrix().Scale(1 + (plates/6)), time = (2 SECONDS + plates))
	QDEL_IN(shockwave, 2.1 SECONDS + plates)

/*---------------------------------------------------------------
	end of stomp section
---------------------------------------------------------------*/
/*---------------------------------------------------------------
	training related section
---------------------------------------------------------------*/
/mob/living/carbon/human/proc/worldbreaker_help()
	set name = "Worldbreaker"
	set desc = "Imagine all the things you would be capable of with this power."
	set category = "Worldbreaker"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You imagine all the things you would be capable of with this power.</i></b>"

	combined_msg += span_notice("<b>All attacks apply stagger. Stagger applies a brief slow.</b>")
	combined_msg += span_notice("<b>All physical damage does twice as much in stamina damage.</b>")

	combined_msg +=  "[span_notice("Plates")]: You will progressively grow plates every [PLATE_INTERVAL/10] seconds. \
	Each plate provides [PLATE_REDUCTION] armour but also slows you down. The armour caps at [PLATE_REDUCTION * MAX_PLATES] but the slowdown can continue scaling. \
	While at maximum armour you are considered \"heavy\" and most of your attacks will be slower, but do more damage in a larger area. \
	Taking brute or burn damage will wear away at your plates until they fall off on their own."

	combined_msg +=  "[span_notice("Rip Plate")]: Help intent yourself to rip off a plate. The plate can be thrown at people to stagger them and knock them back. \
	The plate is heavy enough that others will find it difficult to throw."

	combined_msg +=  "[span_notice("Leap")]: \
	Your disarm is instead a leap that deals damage, staggers, and knocks everything back within a radius. \
	Landing on someone will do extra damage. The cooldown is longer if heavy and only starts when you land."
	
	combined_msg +=  "[span_notice("Clasp")]: Your grab is far stronger. \
	Instead of grabbing someone, you will pick them up and be able to throw them."

	combined_msg +=  "[span_notice("Pummel")]: Your harm intent pummels a small area dealing damage, knocking back, and staggering. \
	The targets in the middle take notably more damage."

	combined_msg +=  "[span_notice("Worldstomp")]: After a delay, create a giant shockwave that deals damage to all mobs within a radius. \
	The shockwave will knock back and stagger all mobs in a larger radius. Objects and structures within the extended radius will be thrown or damaged respectively. \
	The radius and knockback scale with number of plates."

	combined_msg += span_notice("Being in this state causes you to burn energy significantly faster.")
	combined_msg += span_notice("Your considerably increased weight will prevent you from using most conventional vehicles.")
	combined_msg += span_notice("Should your strength fail you, an attempt to regain strength can be made with the 'Flush Circuits' function.")

	to_chat(usr, examine_block(combined_msg.Join("\n")))

/mob/living/carbon/human/proc/worldbreaker_recalibration()
	set name = "Flush Circuits"
	set desc = "Flush 'clogged' circuits in order to regain lost strength."
	set category = "Worldbreaker"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You flush your circuits with excess power to reduce built up strain on your limbs.</i></b>"
	to_chat(usr, examine_block(combined_msg.Join("\n")))

	usr.click_intercept = usr.mind.martial_art

/datum/martial_art/worldbreaker/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	H.physiology.hunger_mod *= 10 //burn bright my friend
	var/datum/species/preternis/S = H.dna.species
	if(istype(S))
		S.add_no_equip_slot(H, ITEM_SLOT_OCLOTHING, src)
	usr.click_intercept = src 
	add_verb(H, recalibration)
	plate_timer = addtimer(CALLBACK(src, PROC_REF(grow_plate), H), PLATE_INTERVAL, TIMER_LOOP|TIMER_UNIQUE|TIMER_STOPPABLE)//start regen
	update_platespeed(H)
	ADD_TRAIT(H, TRAIT_RESISTHEAT, type) //walk through that fire all you like, hope you don't care about your clothes
	ADD_TRAIT(H, TRAIT_NOSOFTCRIT, type)
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(H, TRAIT_NOVEHICLE, type)
	ADD_TRAIT(H, TRAIT_BOTTOMLESS_STOMACH, type) //they hongry
	RegisterSignal(H, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(lose_plate))
	if(!linked_stomp)
		linked_stomp = new
		linked_stomp.linked_martial = src
	linked_stomp.Grant(H)

/datum/martial_art/worldbreaker/on_remove(mob/living/carbon/human/H)
	H.physiology.hunger_mod /= 10 //but not that bright
	var/datum/species/preternis/S = H.dna.species
	if(istype(S))
		S.remove_no_equip_slot(H, ITEM_SLOT_OCLOTHING, src)
	usr.click_intercept = null 
	remove_verb(H, recalibration)
	deltimer(plate_timer)
	plates = 0
	update_platespeed(H)
	REMOVE_TRAIT(H, TRAIT_RESISTHEAT, type)
	REMOVE_TRAIT(H, TRAIT_NOSOFTCRIT, type)
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(H, TRAIT_NOVEHICLE, type)
	REMOVE_TRAIT(H, TRAIT_BOTTOMLESS_STOMACH, type)
	UnregisterSignal(H, COMSIG_MOB_APPLY_DAMAGE)
	if(linked_stomp)
		linked_stomp.Remove(H)
	return ..()


#undef BALLOON_COOLDOWN
#undef STAGGER_DURATION
#undef WARNING_RANGE

#undef COOLDOWN_STOMP
#undef STOMP_WINDUP
#undef STOMP_RADIUS

#undef COOLDOWN_LEAP
#undef LEAP_RADIUS

#undef COOLDOWN_PUMMEL

#undef PLATE_INTERVAL
#undef PLATE_REDUCTION
#undef MAX_PLATES
#undef PLATE_CAP
#undef PLATE_BREAK

#undef THROW_MOBDMG
#undef THROW_OBJDMG
#undef COOLDOWN_GRAB
