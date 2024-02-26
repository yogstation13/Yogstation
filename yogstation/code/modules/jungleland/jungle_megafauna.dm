#define SLASH_ATTACK "slash"
#define IMPALE_ATTACK "implae"
#define RUNE_ATTACK "rune"
#define TAR_ATTACK "tar"
#define TELEPORT_ATTACK "teleport"
#define SPAWN_ATTACK "spawn"

#define DIRECTION_MATRIX list("NORTH" = 0 , "EAST" = 0, "SOUTH" = 0, "WEST" = 0, "NORTHEAST" = 0 , "SOUTHEAST" = 0 , "SOUTHWEST" = 0, "NORTHWEST" = 0)
#define ATTACK_MATRIX list(SLASH_ATTACK = DIRECTION_MATRIX, RUNE_ATTACK = DIRECTION_MATRIX, IMPALE_ATTACK = DIRECTION_MATRIX)

/mob/living/simple_animal/hostile/megafauna/tar_king 
	name = "king of tar"
	desc = "A hunking mass of tar resembling a human, a shining gem glows from within. It yearns for the end of its agony..."
	health = 2000
	maxHealth = 2000
	icon_state = "tar_king"
	icon_living = "tar_king"
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	health_doll_icon = "tar_king"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	light_color = "#dd35d5"
	a_intent = INTENT_HARM
	melee_damage_lower = 25
	melee_damage_upper = 50
	movement_type = GROUND
	ranged = TRUE 
	faction = list("tar", "boss")
	speak_emote = list("roars")
	speed = 2
	move_to_delay = 2
	pixel_x = -16
	pixel_y = -16
	del_on_death = TRUE
	deathmessage = "falls to the ground, decaying into a puddle of tar."
	deathsound = "bodyfall"
	do_footstep = TRUE
	ranged_cooldown_time = 10 SECONDS
	armour_penetration = 50
	dodge_prob = 0
	loot = list(/obj/item/clothing/head/yogs/tar_king_crown = 1, /obj/item/gem/tarstone = 1, /obj/item/demon_core = 1)
	crusher_loot = list(/obj/item/crusher_trophy/jungleland/aspect_of_tar = 1,/obj/item/clothing/head/yogs/tar_king_crown = 1, /obj/item/gem/tarstone = 1, /obj/item/demon_core = 1)
	var/list/attack_adjustments = list()
	var/last_done_attack = 0
	var/list/attack_stack = list()
	var/stage = 0

	var/list/orbitals = list(0,120,240,60,180,300)
	var/orbital_theta_per_tick = 15
	var/orbital_range = 4

/mob/living/simple_animal/hostile/megafauna/tar_king/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess,src)

/mob/living/simple_animal/hostile/megafauna/tar_king/Life(seconds_per_tick, times_fired)
	. = ..()
	if(stat == DEAD)
		return 

	if(prob(25) && target)
		spawn_tar_shrine()


/mob/living/simple_animal/hostile/megafauna/tar_king/process()
	if(stat == DEAD)
		STOP_PROCESSING(SSfastprocess, src)
		return
	process_orbitals()

/mob/living/simple_animal/hostile/megafauna/tar_king/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(iscarbon(hit_atom))
		sword_hit(list(get_turf(hit_atom)))
		return

	if(isstructure(hit_atom))
		qdel(hit_atom)
		return

	if(isclosedturf(hit_atom))
		SSexplosions.medturf += get_turf(hit_atom)
		return

/mob/living/simple_animal/hostile/megafauna/tar_king/Goto(target, delay, minimum_distance)
	if(!attack_stack.len)
		return ..()
	else 
		walk(src,0)
	
/mob/living/simple_animal/hostile/megafauna/tar_king/proc/add_mob_profile(mob/living/L)
	attack_adjustments[L.real_name] = ATTACK_MATRIX
	RegisterSignal(L,COMSIG_MOVABLE_MOVED,PROC_REF(react_after_move))

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/react_after_move(mob/living/L, old_loc, target_dir, forced)
	if(!last_done_attack || last_done_attack == TAR_ATTACK ||last_done_attack == TELEPORT_ATTACK)
		return
	var/angle_dir_target = dir2angle(target_dir)
	angle_dir_target = angle_dir_target == 0 ? 360 : angle_dir_target
	var/chosen_dir = angle2dir(angle_dir_target -  dir2angle(get_dir(src,L)))
	attack_adjustments[L.real_name][last_done_attack][uppertext(dir2text(chosen_dir))] += 1
	last_done_attack = 0 

/mob/living/simple_animal/hostile/megafauna/tar_king/Shoot()
	if (stage == 0 && health < 1500)
		SetRecoveryTime(20 SECONDS)
		stage++
		stage_transition()
		return
	else if (stage == 1 && health < 1000)	
		SetRecoveryTime(20 SECONDS,0)
		stage++
		stage_transition()
		return 
	else if (stage == 2 && health < 500)	
		SetRecoveryTime(20 SECONDS,0)
		stage++
		stage_transition()
		return
	if(attack_stack.len)
		return 
	var/list/combo = forge_combo()
	SetRecoveryTime( 1 SECONDS + ((health/maxHealth) * 1 SECONDS),0) 
	
	for(var/move as anything in combo)	
		attack_stack += move
		walk(src,0)
		switch(move)
			if(SLASH_ATTACK)
				slash_attack_chain()
			if(IMPALE_ATTACK)
				impale_attack_chain()
			if(RUNE_ATTACK)
				rune_attack_chain()
			if(TELEPORT_ATTACK)
				teleport_attack_chain()
			if(SPAWN_ATTACK)
				spawn_attack_chain()
		attack_stack -= move
		Goto(target,move_to_delay,minimum_distance)
		SLEEP_CHECK_DEATH(1 SECONDS)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/spawn_tar_shrine()
	var/list/pickable_turfs = list()
	for(var/turf/open/T in oview(3,target))
		pickable_turfs += T
	
	for(var/i = 0 ; i < rand(1,3); i++)
		var/turf/spawning = pick_n_take(pickable_turfs)				
		new /obj/effect/timed_attack/tar_king/spawn_shrine(spawning)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/react(move)
	last_done_attack = move
	
	if(!isliving(target))
		return
	
	var/mob/living/L = target
	var/adjustment_amount = 0
	switch(maxHealth - health)
		if(0 to 500)
			adjustment_amount += 1
		if(500 to 1000)
			adjustment_amount += 2
		if(1000 to 1500)
			adjustment_amount += 3
		if(1500 to 2000)
			adjustment_amount += 4

	var/dist = get_dist(src,L)
	if(dist > 3)
		visible_message(span_colossus("Coward!"))		
		var/step_dir = pick(GLOB.alldirs)
		var/turf/new_loc = get_step(L,step_dir)
		Move(new_loc,get_dir(src,new_loc))

	var/adjusted_dir = get_dir(src,L)

	if(isnull(attack_adjustments[L.real_name]))
		add_mob_profile(L)
	for(var/i = 0; i < adjustment_amount; i++)
		var/direction = pickweightAllowZero(attack_adjustments[L.real_name][move])
		var/actual_direction 
		actual_direction = turn(text2dir(direction),dir2angle(get_dir(src,L)))
		if(!actual_direction || prob(35))
			actual_direction = get_dir(src,L)

		Move(get_step(src,actual_direction),actual_direction)
		setDir(adjusted_dir)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/forge_combo()
	var/list/combo = list()
	var/list/possible_moves = list(SLASH_ATTACK,IMPALE_ATTACK,RUNE_ATTACK,TELEPORT_ATTACK,SPAWN_ATTACK)
	for(var/i = 0 ; i < 3; i++)
		combo += pick_n_take(possible_moves)
	return combo

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/slash_attack_chain()
	slash_attack_telegraph()
	SLEEP_CHECK_DEATH(0.25 SECONDS)
	react(SLASH_ATTACK)
	SLEEP_CHECK_DEATH(0.25 SECONDS)
	slash_attack_finish()	
	
/mob/living/simple_animal/hostile/megafauna/tar_king/proc/slash_attack_telegraph()
	visible_message(span_colossus("En-Ghar!"))
	animate(src,0.25 SECONDS,transform = turn(matrix(),30))

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/slash_attack_finish()
	animate(src,0.25 SECONDS,transform = initial(transform))
	new /obj/effect/tar_king/slash(get_turf(src),src,dir)
	SLEEP_CHECK_DEATH(4)
	var/affected_turfs = list() 
	affected_turfs += get_step(src,turn(dir,-45))
	affected_turfs += get_step(src,dir)
	affected_turfs += get_step(src,turn(dir,45))
	sword_hit(affected_turfs)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/impale_attack_chain()
	impale_attack_telegraph()
	SLEEP_CHECK_DEATH(0.25 SECONDS)
	react(IMPALE_ATTACK)
	SLEEP_CHECK_DEATH(0.25 SECONDS)
	impale_attack_finish()	
	
/mob/living/simple_animal/hostile/megafauna/tar_king/proc/impale_attack_telegraph()
	visible_message(span_colossus("Et-Tyr!"))
	switch(dir)
		if(NORTH)
			animate(src,0.25 SECONDS,pixel_y = initial(pixel_y) - 10)
		if(SOUTH)
			animate(src,0.25 SECONDS,pixel_y = initial(pixel_y) + 10)
		if(EAST)
			animate(src,0.25 SECONDS,pixel_x = initial(pixel_y) - 10)
		if(WEST)
			animate(src,0.25 SECONDS,pixel_x = initial(pixel_y) + 10)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/impale_attack_finish()
	new /obj/effect/tar_king/impale(get_turf(src),src,dir)
	SLEEP_CHECK_DEATH(4)
	var/affected_turfs = list() 
	affected_turfs += get_turf(src)
	affected_turfs += get_step(src,dir)
	affected_turfs += get_step(get_step(src,dir),dir)
	sword_hit(affected_turfs)
	animate(src,0.25 SECONDS,pixel_x = initial(pixel_x),pixel_y = initial(pixel_y))

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/rune_attack_chain()
	rune_attack_telegraph()
	SLEEP_CHECK_DEATH(0.25 SECONDS)
	react(RUNE_ATTACK)
	SLEEP_CHECK_DEATH(0.25 SECONDS)
	rune_attack_finish()	
	
/mob/living/simple_animal/hostile/megafauna/tar_king/proc/rune_attack_telegraph()
	visible_message(span_colossus("Atu'Rakhtar!"))
	animate(src,0.5 SECONDS, color = "#ff002f")
	new /obj/effect/tar_king/rune_attack(get_turf(src),src,get_dir(src,target))

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/rune_attack_finish()
	animate(src,0.5 SECONDS, color = initial(color))
	SLEEP_CHECK_DEATH(8)
	for(var/mob/living/carbon/C in (range(2,src) - range(1,src)))
		var/limb_to_hit = C.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		C.apply_damage(45, BURN, limb_to_hit, C.run_armor_check(limb_to_hit, MAGIC, null, null, armour_penetration), wound_bonus = CANT_WOUND)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/teleport_attack_chain()
	new /obj/effect/tar_king/orb_in(get_turf(src),src,dir)
	var/obj/closest
	var/cached_dist = INFINITY

	if(GLOB.tar_pits.len > 1) 
		for(var/obj/structure/tar_pit/TP as anything in GLOB.tar_pits)
			var/dist = get_dist(target,TP) 
			if(dist < cached_dist)
				cached_dist = dist 
				closest = TP
	else 
		if(!GLOB.tar_pits.len)
			return
		closest = GLOB.tar_pits[1]
	
	if(!closest || cached_dist > 7)
		return

	visible_message(span_colossus("Ishakt-Tarim!"))			
	SLEEP_CHECK_DEATH(0.5 SECONDS)
	Move(get_turf(closest))
	visible_message(span_colossus("Atyr!"))	
	throw_at(target,get_dist(target,src),4, spin = FALSE)		

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/spawn_attack_chain()
	if(!GLOB.tar_pits.len)
		return
	visible_message(span_colossus("At-Karan!"))
	var/list/spawnable = list(/mob/living/simple_animal/hostile/asteroid/hivelordbrood/tar)
	for(var/TP in GLOB.tar_pits)
		if(prob(50))
			continue
		var/obj/structure/tar_pit/pit = TP 
		var/picked = pick(spawnable)
		var/mob/living/simple_animal/hostile/H = new picked(pit.loc)
		H.GiveTarget(target)
		H.friends = friends
		H.faction = faction.Copy()

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/process_orbitals()
	var/orbitals_shown = 3
	switch(maxHealth - health)
		if(500 to 1000)
			orbitals_shown += 1
		if(1000 to 1500)
			orbitals_shown += 2
		if(1500 to 2000)
			orbitals_shown += 3
	
	for(var/i in 1 to 5)
		orbitals[i] += orbital_theta_per_tick

	for(var/i in 1 to orbitals_shown)
		var/xcoord = loc.x + orbital_range * cos(orbitals[i])
		var/ycoord = loc.y + orbital_range * sin(orbitals[i])
		var/turf/located = locate(xcoord,ycoord,loc.z)
		var/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/T = new(located, src)
		T.damage = 25

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/sword_hit(list/turfs)
	for(var/turf/T as anything in turfs)
		for(var/mob/living/carbon/C in T.contents)
			var/limb_to_hit = C.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			C.apply_damage(35, BRUTE, limb_to_hit, C.run_armor_check(limb_to_hit, MELEE, null, null, armour_penetration), wound_bonus = CANT_WOUND)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/stage_transition()
	walk(src,0)
	icon_state = "tar_king_chaser"
	for(var/i in 0 to stage)
		new /obj/effect/temp_visual/tar_king_chaser(loc, src, target, 1)
	attack_stack += "STAGE_TRANSITION"
	SLEEP_CHECK_DEATH(15 SECONDS)
	icon_state = "tar_king"
	attack_stack -= "STAGE_TRANSITION"

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale
	duration = 9
	icon = 'yogstation/icons/effects/32x48.dmi'
	animated_icon_state = "tar_king_special"
	name = "incoming doom"
	desc = "Run while you still can!"
	var/damage
	var/mob/living/caster
	var/bursting 

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/Initialize(mapload, new_caster)
	. = ..()
	caster = new_caster
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	INVOKE_ASYNC(src, PROC_REF(blast))

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/proc/blast()
	var/turf/T = get_turf(src)
	if(!T)
		return
	playsound(T,pick('sound/weapons/sword3.ogg','sound/weapons/sword4.ogg','sound/weapons/sword5.ogg'), 125, 1, -5) //make a sound
	sleep(0.45 SECONDS) 
	bursting = TRUE
	do_damage(T) 
	sleep(0.1 SECONDS) 
	bursting = FALSE 

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/proc/on_entered(datum/source, atom/movable/AM, ...)
	if(bursting)
		do_damage(get_turf(src))

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/proc/do_damage(turf/T)
	if(!damage)
		return
	for(var/mob/living/L in T.contents) //find and damage mobs...
		if((caster && caster.faction_check_mob(L)) || L.stat == DEAD || L == caster)
			continue
		playsound(L,pick('sound/weapons/sword1.ogg','sound/weapons/sword2.ogg'), 50, 1, -4)
		to_chat(L, span_userdanger("You're struck by a [name]!"))
		var/limb_to_hit = L.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		var/armor = L.run_armor_check(limb_to_hit, MELEE, "Your armor absorbs [src]!", "Your armor blocks part of [src]!", 50, "Your armor was penetrated by [src]!")
		L.apply_damage(damage, BRUTE, limb_to_hit, armor)
		if(caster)
			log_combat(caster, L, "struck with a [name]")

	for(var/obj/mecha/M in T.contents) //also damage mechs.
		if(M.occupant)
			if(caster && caster != M && caster.faction_check_mob(M.occupant))
				continue
			to_chat(M.occupant, span_userdanger("Your [M.name] is struck by a [name]!"))
		playsound(M,'sound/weapons/sword2.ogg', 50, 1, -4)
		M.take_damage(damage, BRUTE, 0, 0)

/obj/effect/temp_visual/tar_king_chaser
	duration = 15 SECONDS
	var/mob/living/target //what it's following
	var/turf/targetturf //what turf the target is actually on
	var/moving_dir //what dir it's moving in
	var/previous_moving_dir //what dir it was moving in before that
	var/more_previouser_moving_dir //what dir it was moving in before THAT
	var/moving = 0 //how many steps to move before recalculating
	var/standard_moving_before_recalc = 4 //how many times we step before recalculating normally
	var/tiles_per_step = 1 //how many tiles we move each step
	var/speed = 3 //how many deciseconds between each step
	var/currently_seeking = FALSE
	var/monster_damage_boost = TRUE
	var/damage = 25
	var/caster

/obj/effect/temp_visual/tar_king_chaser/Initialize(mapload, new_caster, new_target, new_speed)
	. = ..()
	target = new_target
	if(new_speed)
		speed = new_speed
	caster = new_caster
	addtimer(CALLBACK(src, PROC_REF(seek_target)), 1)

/obj/effect/temp_visual/tar_king_chaser/proc/get_target_dir()
	. = get_cardinal_dir(src, targetturf)
	if((. != previous_moving_dir && . == more_previouser_moving_dir) || . == 0) //we're alternating, recalculate
		var/list/cardinal_copy = GLOB.cardinals.Copy()
		cardinal_copy -= more_previouser_moving_dir
		. = pick(cardinal_copy)

/obj/effect/temp_visual/tar_king_chaser/proc/seek_target()
	if(!currently_seeking)
		currently_seeking = TRUE
		targetturf = get_turf(target)
		while(target && src && !QDELETED(src) && currently_seeking && x && y && targetturf) //can this target actually be sook out
			if(!moving) //we're out of tiles to move, find more and where the target is!
				more_previouser_moving_dir = previous_moving_dir
				previous_moving_dir = moving_dir
				moving_dir = get_target_dir()
				var/standard_target_dir = get_cardinal_dir(src, targetturf)
				if((standard_target_dir != previous_moving_dir && standard_target_dir == more_previouser_moving_dir) || standard_target_dir == 0)
					moving = 1 //we would be repeating, only move a tile before checking
				else
					moving = standard_moving_before_recalc
			if(moving) //move in the dir we're moving in right now
				var/turf/T = get_turf(src)
				for(var/i in 1 to tiles_per_step)
					var/maybe_new_turf = get_step(T, moving_dir)
					if(maybe_new_turf)
						T = maybe_new_turf
					else
						break
				forceMove(T)
				make_blast() //make a blast, too
				moving--
				sleep(speed)
			targetturf = get_turf(target)

/obj/effect/temp_visual/tar_king_chaser/proc/make_blast()
	var/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/T = new(loc, caster)
	T.damage = damage

