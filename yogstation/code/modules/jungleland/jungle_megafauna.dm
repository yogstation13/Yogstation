#define SLASH_ATTACK "slash"
#define IMPALE_ATTACK "implae"
#define RUNE_ATTACK "rune"
#define TAR_ATTACK "tar"
#define TELEPORT_ATTACK "teleport"

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
	dodge_prob = 0
	var/list/attack_adjustments = list()
	var/last_done_attack = 0
	var/currently_attacking = FALSE

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
	if(!currently_attacking)
		return ..()
	
/mob/living/simple_animal/hostile/megafauna/tar_king/proc/add_mob_profile(mob/living/L)
	attack_adjustments[L.real_name] = ATTACK_MATRIX
	RegisterSignal(L,COMSIG_MOVABLE_MOVED,.proc/react_after_move)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/react_after_move(mob/living/L, old_loc, target_dir, forced)
	if(!last_done_attack || last_done_attack == TAR_ATTACK ||last_done_attack == TELEPORT_ATTACK)
		return
	var/angle_dir_target = dir2angle(target_dir)
	angle_dir_target = angle_dir_target == 0 ? 360 : angle_dir_target
	var/chosen_dir = angle2dir(angle_dir_target -  dir2angle(get_dir(src,L)))
	attack_adjustments[L.real_name][last_done_attack][uppertext(dir2text(chosen_dir))] += 1
	last_done_attack = 0 

/mob/living/simple_animal/hostile/megafauna/tar_king/OpenFire()
	var/list/combo = forge_combo()
	SetRecoveryTime( 3 SECONDS + ((health/maxHealth) * 0.5 SECONDS)) 
	
	for(var/move as anything in combo)	
		currently_attacking = TRUE
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
			if(TAR_ATTACK)
				tar_attack_chain()

		currently_attacking = FALSE
		Goto(target,move_to_delay,minimum_distance)
		SLEEP_CHECK_DEATH(1 SECONDS)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/react(move)
	last_done_attack = move
	
	if(!isliving(target))
		return
	
	var/mob/living/L = target
	var/adjustment_amount = 0
	switch(health)
		if(2000 to 1500)
			adjustment_amount += 1
		if(1500 to 1000)
			adjustment_amount += 2
		if(1000 to 500)
			adjustment_amount += 3
		if(500 to 0)
			adjustment_amount += 4

	var/dist = get_dist(src,L)
	if(dist >= 3)
		visible_message(span_colossus("Coward!"))		
		var/step_dir = pick(GLOB.alldirs)
		var/turf/new_loc = get_step(L,step_dir)
		Move(new_loc,get_dir(src,new_loc))

	var/adjusted_dir = get_dir(src,L)

	if(isnull(attack_adjustments[L.real_name]))
		add_mob_profile(L)
	for(var/i = 0; i < adjustment_amount; i++)
		var/direction = pickweightAllowZero(attack_adjustments[L.real_name][move])
		message_admins(direction)
		var/actual_direction 
		actual_direction = turn(text2dir(direction),dir2angle(get_dir(src,L)))
		if(!actual_direction || prob(35))
			actual_direction = get_dir(src,L)

		Move(get_step(src,actual_direction),actual_direction)
		setDir(adjusted_dir)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/forge_combo()
	var/list/combo = list()
	var/list/possible_moves = list(SLASH_ATTACK,IMPALE_ATTACK,RUNE_ATTACK,TELEPORT_ATTACK,TAR_ATTACK)
	for(var/i = 0 ; i < 3; i++)
		combo += pick_n_take(possible_moves)
	message_admins("Forged combo!")
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

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/tar_attack_chain()
	var/list/pickable_turfs = list()
	for(var/turf/T as anything in spiral_range_turfs(3,src))
		if(T.CanPass(src))
			pickable_turfs += T

	visible_message(span_colossus("Tar-Ishkat!"))			
	new /obj/effect/tar_king/orb_out(get_turf(src),src,dir)
	SLEEP_CHECK_DEATH(0.5 SECONDS)
	for(var/i = 0 ; i < rand(1,3); i++)
		var/turf/spawning = pick_n_take(pickable_turfs)				
		new /obj/structure/tar_pit(spawning)


/mob/living/simple_animal/hostile/megafauna/tar_king/proc/teleport_attack_chain()
	new /obj/effect/tar_king/orb_in(get_turf(src),src,dir)
	var/obj/closest

	if(GLOB.tar_pits.len > 1) 
		var/cached_dist = INFINITY
		for(var/obj/structure/tar_pit/TP as anything in GLOB.tar_pits)
			var/dist = get_dist(target,TP) 
			if(dist < cached_dist)
				cached_dist = dist 
				closest = TP
	else 
		closest = GLOB.tar_pits[0]
	
	if(!closest || closest > 7)
		return

	visible_message(span_colossus("Ishakt-Tarim!"))			
	SLEEP_CHECK_DEATH(0.5 SECONDS)
	Move(get_turf(closest))
	visible_message(span_colossus("Atyr!"))	
	throw_at(target,get_dist(target,src),4, spin = FALSE)		

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/sword_hit(list/turfs)
	for(var/turf/T as anything in turfs)
		for(var/mob/living/carbon/C in T.contents)
			var/limb_to_hit = C.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			C.apply_damage(20, BRUTE, limb_to_hit, C.run_armor_check(limb_to_hit, MELEE, null, null, armour_penetration), wound_bonus = CANT_WOUND)

