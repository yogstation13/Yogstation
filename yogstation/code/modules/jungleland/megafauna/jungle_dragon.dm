////////////////////////////////////////////////////////////////////////////////////
//----------------------------Player controlled stuff-----------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/action/innate/megafauna_attack/vine_cone
	name = "Vine Cone"
	button_icon = 'icons/obj/wizard.dmi'
	button_icon_state = "fireball"
	chosen_message = span_colossus("You are now shooting vines at your target.")
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/vine_cone_meteors
	name = "Vine Cone With Meteors"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = span_colossus("You are now shooting vines at your target and raining bulbs around you.")
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/mass_vine
	name = "Mass Vine Attack"
	button_icon = 'icons/effects/fire.dmi'
	button_icon_state = "1"
	chosen_message = span_colossus("You are now shooting mass vines at your target.")
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/vine_swoop
	name = "Vine Swoop"
	button_icon = 'icons/effects/spacevines.dmi'
	button_icon_state = "flower_bud"
	chosen_message = span_colossus("You are now swooping and raining bulbs at your target.")
	chosen_attack_num = 4

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------The dragon in question-----------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/megafauna/dragon/jungle
	name = "jungle dragon"
	desc = "Guardians of the jungle, they seem to wander the lands in search of something."
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	gps_name = "Verdant Signal"
	deathmessage = "collapses to the ground, its strength long since exhausted."
	
	melee_damage_lower = 20
	melee_damage_upper = 20
	ranged_cooldown_time = 2.5 SECONDS //uses ranged attacks faster
	minimum_distance = 5 //tries to keep it's range rather than rushing down the target
	retreat_distance = 2

	small_sprite_type = /datum/action/small_sprite/megafauna/drake
	music_component = /datum/component/music_player/battle
	music_path = /datum/music/sourced/battle/ash_drake

	crusher_loot = list(/obj/structure/closet/crate/necropolis/jungle_dragon/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/jungle_dragon)

	butcher_results = list(
		/obj/item/stack/ore/diamond = 5, 
		/obj/item/stack/sheet/sinew = 5, 
		/obj/item/stack/sheet/bone = 30
		)
	guaranteed_butcher_results = list(
		/obj/item/stack/sheet/animalhide/ashdrake = 10
		)

	attack_action_types = list(
		/datum/action/innate/megafauna_attack/vine_cone,
		/datum/action/innate/megafauna_attack/vine_cone_meteors,
		/datum/action/innate/megafauna_attack/mass_vine,
		/datum/action/innate/megafauna_attack/vine_swoop
		)
	fire_sound = 'sound/magic/tail_swing.ogg'
	/**
	 * both of these are placeholders and need to be swapped out at some point
	 */
	music_path = /datum/music/sourced/battle/ash_drake
	small_sprite_type = /datum/action/small_sprite/megafauna/drake
	/// used for the silly yharon reference


/mob/living/simple_animal/hostile/megafauna/dragon/jungle/Initialize(mapload)
	if(prob(1))
		name = "Yharon"
		desc = "This is my message to my master."
		deathmessage = "lets out a final dying roar."
		music_path = /datum/music/sourced/battle/jungledragon/meme
		crusher_loot += loot //only get the crusher trophy once
		loot += loot //double the loot for a harder fight
		guaranteed_butcher_results += guaranteed_butcher_results
		ranged_cooldown_time = 2 SECONDS //even faster
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Standard ai activity------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/megafauna/dragon/jungle/shoot_fire_attack()
	anger_modifier = ((maxHealth - health)/maxHealth) * 100

	if(prob(anger_modifier)) //100% chance for mass fire as they get close to death
		mass_fire()
	else if(prob(anger_modifier)) //pretty likely to lava swoop as they get closer to death
		lava_swoop()
	else //just regular cones to start out
		fire_cone()

/mob/living/simple_animal/hostile/megafauna/dragon/jungle/mass_fire(spiral_count = 12, range = 15, times = 6)
	SLEEP_CHECK_DEATH(0)
	if(prob(50))
		INVOKE_ASYNC(src, PROC_REF(fire_rain))
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Basic blast attacks-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/megafauna/dragon/jungle/fire_line(list/turfs)
	SLEEP_CHECK_DEATH(0)
	dragon_jungle_line(src, turfs)

//fire line keeps going even if dragon is deleted
/proc/dragon_jungle_line(source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break
		var/obj/effect/temp_visual/vineball/noextras = locate() in T
		if(!noextras)
			new /obj/effect/temp_visual/vineball(T)
			for(var/mob/living/L in T.contents)
				if(L in hit_list || L == source)
					continue
				hit_list += L
				L.apply_damage(30, BRUTE, blocked = L.run_armor_check())
				to_chat(L, span_userdanger("You're lacerated by [source]'s vines!"))

			// deals damage to mechs
			for(var/obj/mecha/M in T.contents)
				if(M in hit_list)
					continue
				hit_list += M
				M.take_damage(45, BRUTE, MELEE, 1)
		sleep(0.15 SECONDS)

/obj/effect/temp_visual/vineball
	name = "barbed vines"
	desc = "Not the kind you want to brush up against, move!"
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light"
	duration = 5

/obj/effect/temp_visual/vineball/Initialize(mapload)
	. = ..()
	icon_state = "[icon_state][rand(1,3)]"

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Lava arena-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/megafauna/dragon/jungle/lava_arena()
	if(!target)
		return
	target.visible_message(span_boldwarning("[src] encases you in an arena of brambles!"))
	var/amount = 3
	var/turf/center = get_turf(target)
	var/list/walled = RANGE_TURFS(3, center) - RANGE_TURFS(2, center)
	var/list/drakewalls = list()
	for(var/turf/T in walled)
		drakewalls += new /obj/effect/temp_visual/drakewall/jungle(T) // no people with lava immunity can just run away from the attack for free
	var/list/indestructible_turfs = list()
	for(var/turf/T in RANGE_TURFS(2, center))
		if(istype(T, /turf/open/indestructible))
			continue
		if(!istype(T, /turf/closed/indestructible))
			T.ChangeTurf(/turf/open/floor/plating/dirt/jungleland/jungle, flags = CHANGETURF_INHERIT_AIR)
		else
			indestructible_turfs += T
	SLEEP_CHECK_DEATH(10) // give them a bit of time to realize what attack is actually happening

	var/list/turfs = RANGE_TURFS(2, center)
	while(amount > 0)
		var/list/empty = indestructible_turfs.Copy() // can't place safe turfs on turfs that weren't changed to be open
		var/any_attack = 0
		for(var/turf/T in turfs)
			for(var/mob/living/L in T.contents)
				if(L.client)
					empty += pick(((RANGE_TURFS(2, L) - RANGE_TURFS(1, L)) & turfs) - empty) // picks a turf within 2 of the creature not outside or in the shield
					any_attack = 1
			for(var/obj/mecha/M in T.contents)
				empty += pick(((RANGE_TURFS(2, M) - RANGE_TURFS(1, M)) & turfs) - empty)
				any_attack = 1
		if(!any_attack)
			for(var/obj/effect/temp_visual/drakewall/D in drakewalls)
				qdel(D)
			return 0 // nothing to attack in the arena time for enraged attack if we still have a target
		for(var/turf/T in turfs)
			if(!(T in empty))
				new /obj/effect/temp_visual/lava_warning/jungle(T)
			else if(!istype(T, /turf/closed/indestructible))
				new /obj/effect/temp_visual/lava_safe(T)
		amount--
		SLEEP_CHECK_DEATH(24)
	return 1 // attack finished completely

/**
 * Smaller individual lava pools
 */
/mob/living/simple_animal/hostile/megafauna/dragon/jungle/lava_pools(amount, delay = 0.8)
	if(!target)
		return
	target.visible_message(span_boldwarning("Toxic water starts to pool up around you!"))
	while(amount > 0)
		if(QDELETED(target))
			break
		var/turf/T = pick(RANGE_TURFS(1, target))
		new /obj/effect/temp_visual/lava_warning/jungle(T, 60) // longer reset time for the lava
		amount--
		SLEEP_CHECK_DEATH(delay)
/**
 * Warning for where not to stand and damage handler
 */
/obj/effect/temp_visual/lava_warning/jungle
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	color = "#00c167"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 1.3 SECONDS

/obj/effect/temp_visual/lava_warning/jungle/fall(reset_time)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, 1)
	sleep(duration)
	playsound(T,'sound/effects/splosh.ogg', 150, 1)

	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/simple_animal/hostile/megafauna/dragon))
			continue
		to_chat(L, span_userdanger("You fall directly into the pool of acid!"))
		L.apply_damage(20, BURN)
		L.acid_act(30, 10)

	// deals damage to mechs
	for(var/obj/mecha/M in T.contents)
		M.take_damage(45, BURN, MELEE, 1)

	// changes turf to toxic water temporarily
	if(!istype(T, /turf/closed) && !istype(T, /turf/open/water/smooth/toxic_pit/deep))
		var/lava_turf = /turf/open/water/smooth/toxic_pit/deep
		var/reset_turf = T.type
		T.ChangeTurf(lava_turf, flags = CHANGETURF_INHERIT_AIR)
		sleep(reset_time)
		T.ChangeTurf(reset_turf, flags = CHANGETURF_INHERIT_AIR)

/obj/effect/temp_visual/drakewall/jungle
	name = "dense vines"
	desc = "So thick you can barely move through it!"
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Hvy"

/obj/effect/temp_visual/drakewall/jungle/Initialize(mapload)
	. = ..()
	icon_state = "[icon_state][rand(1,3)]"
////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Fire rain-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/megafauna/dragon/jungle/fire_rain()
	if(!target)
		return
	target.visible_message(span_boldwarning("Light rains down from the sky!"))
	for(var/turf/turf in range(10,get_turf(target)))
		if(prob(15))
			new /obj/effect/temp_visual/target/jungle(turf)

/**
 * Handler for effect and damage
 */

/obj/effect/temp_visual/target/jungle/fall(list/flame_hit)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, 1)
	new /obj/effect/temp_visual/fireball/jungle(T)
	sleep(duration)
	if(ismineralturf(T))
		var/turf/closed/mineral/M = T
		M.attempt_drill()
	playsound(T,'sound/effects/curseattack.ogg', 80, 1)
	var/hit = FALSE
	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/simple_animal/hostile/megafauna/dragon))
			continue
		L.apply_status_effect(/datum/status_effect/holy_fire/weak)
		to_chat(L, span_userdanger("You're seared by the light of the sun!"))
		hit = TRUE
	if(!hit)
		T.ignite_turf(20, "#fffca5")

/**
 * Visual target for where it's gonna land
 */
/obj/effect/temp_visual/fireball/jungle
	name = "godray"
	desc = "Get out of the way!"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "seedling"

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Swooping attack----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/megafauna/dragon/jungle/swoop_attack(lava_arena = FALSE, atom/movable/manual_target, swoop_cooldown = 30)
	if(stat || swooping)
		return
	if(manual_target)
		target = manual_target
	if(!target)
		return
	stop_automated_movement = TRUE
	swooping |= SWOOP_DAMAGEABLE
	density = FALSE
	icon_state = "shadow"
	visible_message(span_boldwarning("[src] swoops up high!"))

	var/negative
	var/initial_x = x
	if(target.x < initial_x) //if the target's x is lower than ours, swoop to the left
		negative = TRUE
	else if(target.x > initial_x)
		negative = FALSE
	else if(target.x == initial_x) //if their x is the same, pick a direction
		negative = prob(50)
	var/obj/effect/temp_visual/dragon_flight/jungle/F = new /obj/effect/temp_visual/dragon_flight/jungle(loc, negative)

	negative = !negative //invert it for the swoop down later

	var/oldtransform = transform
	alpha = 255
	animate(src, alpha = 204, transform = matrix()*0.9, time = 0.3 SECONDS, easing = BOUNCE_EASING)
	for(var/i in 1 to 3)
		sleep(0.1 SECONDS)
		if(QDELETED(src) || stat == DEAD) //we got hit and died, rip us
			qdel(F)
			if(stat == DEAD)
				swooping &= ~SWOOP_DAMAGEABLE
				animate(src, alpha = 255, transform = oldtransform, time = 0 SECONDS, flags = ANIMATION_END_NOW) //reset immediately
			return
	animate(src, alpha = 100, transform = matrix()*0.7, time = 0.7 SECONDS)
	swooping |= SWOOP_INVULNERABLE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	SLEEP_CHECK_DEATH(7)

	while(target && loc != get_turf(target))
		forceMove(get_step(src, get_dir(src, target)))
		SLEEP_CHECK_DEATH(0.5)

	// Ash drake flies onto its target and rains fire down upon them
	var/descentTime = 1 SECONDS
	var/lava_success = TRUE
	if(lava_arena)
		lava_success = lava_arena()


	//ensure swoop direction continuity.
	if(negative)
		if(ISINRANGE(x, initial_x + 1, initial_x + DRAKE_SWOOP_DIRECTION_CHANGE_RANGE))
			negative = FALSE
	else
		if(ISINRANGE(x, initial_x - DRAKE_SWOOP_DIRECTION_CHANGE_RANGE, initial_x - 1))
			negative = TRUE
	new /obj/effect/temp_visual/dragon_flight/end/jungle(loc, negative)
	new /obj/effect/temp_visual/dragon_swoop(loc)
	animate(src, alpha = 255, transform = oldtransform, descentTime)
	SLEEP_CHECK_DEATH(descentTime)
	swooping &= ~SWOOP_INVULNERABLE
	mouse_opacity = initial(mouse_opacity)
	icon_state = "dragon"
	playsound(loc, 'sound/effects/meteorimpact.ogg', 200, 1)
	for(var/mob/living/L in orange(1, src))
		if(L.stat)
			visible_message(span_warning("[src] slams down on [L], crushing [L.p_them()]!"))
			L.gib()
		else
			L.adjustBruteLoss(75)
			if(L && !QDELETED(L)) // Some mobs are deleted on death
				var/throw_dir = get_dir(src, L)
				if(L.loc == loc)
					throw_dir = pick(GLOB.alldirs)
				var/throwtarget = get_edge_target_turf(src, throw_dir)
				L.throw_at(throwtarget, 3)
				visible_message(span_warning("[L] is thrown clear of [src]!"))
	for(var/obj/mecha/M in orange(1, src))
		M.take_damage(75, BRUTE, MELEE, 1)

	for(var/mob/M in range(7, src))
		shake_camera(M, 15, 1)

	density = TRUE
	SLEEP_CHECK_DEATH(1)
	swooping &= ~SWOOP_DAMAGEABLE
	SetRecoveryTime(swoop_cooldown)
	if(!lava_success)
		arena_escape_enrage()

/**
 * Flight and landing visuals
 */
/obj/effect/temp_visual/dragon_swoop
	name = "certain death"
	desc = "Don't just stand there, move!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "landing"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	color = "#FF0000"
	duration = 1 SECONDS

/obj/effect/temp_visual/dragon_flight/jungle
	icon = 'yogstation/icons/mob/jungle64x64.dmi'

/obj/effect/temp_visual/dragon_flight/end/jungle
	icon = 'yogstation/icons/mob/jungle64x64.dmi'

////////////////////////////////////////////////////////////////////////////////////
//------------------------------------Loot----------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/structure/closet/crate/necropolis/jungle_dragon
	name = "dragon chest"

/obj/structure/closet/crate/necropolis/jungle_dragon/PopulateContents()
	new /obj/item/gem/amber(src)
	var/loot = rand(1,4)
	switch(loot)
		if(1)
			new /obj/item/melee/ghost_sword(src)
		if(2)
			new /obj/item/lava_staff(src)
			new /obj/item/book/granter/action/spell/sacredflame(src)
		if(3)
			new /obj/item/jungle_dragon_egg(src)
		if(4)
			if(prob(25))	//Still same chance but now you know if you're turning into a lizard (ew)
				new /obj/item/dragons_blood/refined(src)
			else
				new /obj/item/dragons_blood(src)

/obj/structure/closet/crate/necropolis/jungle_dragon/crusher
	name = "overgrown dragon chest"

/obj/structure/closet/crate/necropolis/jungle_dragon/crusher/PopulateContents()
	..()
	new /obj/item/crusher_trophy/tail_spike(src)
	new /obj/item/gem/amber(src)

/obj/item/jungle_dragon_egg
	name = "dragon's egg"
	desc = "A large egg-shaped rock. It seems dry and brittle..."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	color = "#422600"

/obj/item/jungle_dragon_egg/acid_melt()
	visible_message(span_boldwarning("[src] suddenly begins to glow green and starts violently shaking!"))
	name = "rehydrated dragon's egg" //why are we hydrating an egg? idfk
	desc = "A large egg seemingly made out of rock. It's slick with moisture and seems to be shaking!"
	color = "#008f11"
	resistance_flags = UNACIDABLE | ACID_PROOF
	addtimer(CALLBACK(src, PROC_REF(hatch)), 20 SECONDS)

/obj/item/jungle_dragon_egg/proc/hatch()
	visible_message(span_boldwarning("[src] suddenly cracks apart, revealing a tiny jungle dragon!"))
	new /mob/living/simple_animal/hostile/drakeling/jungle(get_turf(src))
	qdel(src)
