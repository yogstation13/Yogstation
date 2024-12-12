#define SLASH_ATTACK "slash"
#define IMPALE_ATTACK "implae"
#define RUNE_ATTACK "rune"
#define TAR_ATTACK "tar"
#define STAGE_TRANSITION "transition"

#define STAGE_MID 1
#define STAGE_END 2
#define STAGE_DEAD 3

#define ENRAGED_TRAIT "enraged"
#define ENRAGE_LIMIT 2

#define DIRECTION_MATRIX list("NORTH" = 0 , "EAST" = 0, "SOUTH" = 0, "WEST" = 0, "NORTHEAST" = 0 , "SOUTHEAST" = 0 , "SOUTHWEST" = 0, "NORTHWEST" = 0)
#define ATTACK_MATRIX list(SLASH_ATTACK = DIRECTION_MATRIX, RUNE_ATTACK = DIRECTION_MATRIX, IMPALE_ATTACK = DIRECTION_MATRIX)

/mob/living/simple_animal/hostile/megafauna/tar_king 
	name = "King of Tar"
	desc = "A hunking mass of tar resembling a human, a shining gem glows from within. It yearns for the end of its agony..."
	health = 2000
	maxHealth = 2000
	icon_state = "tar_king"
	icon_living = "tar_king"
	icon_dead = "tar_king_chaser"
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	health_doll_icon = "tar_king"
	mob_biotypes = (MOB_ORGANIC | MOB_HUMANOID)
	light_color = "#dd35d5"
	combat_mode = TRUE
	melee_damage_lower = 40
	melee_damage_upper = 40
	movement_type = GROUND
	gps_name = "Murky Signal"
	ranged = TRUE 
	faction = list("tar", "boss")
	speak_emote = list("echoes")
	speed = 3
	move_to_delay = 3
	pixel_x = -16
	pixel_y = -16
	deathmessage = "falls to the ground, decaying into a puddle of tar."
	deathsound = 'sound/hallucinations/far_noise.ogg'
	do_footstep = TRUE
	del_on_death = FALSE
	ranged_cooldown_time = 4 SECONDS
	armour_penetration = 40
	dodge_prob = 0
	loot = list(/obj/item/clothing/head/yogs/tar_king_crown = 1, /obj/item/gem/tarstone = 1, /obj/item/demon_core = 1)
	crusher_loot = list(/obj/item/crusher_trophy/jungleland/aspect_of_tar = 1,/obj/item/clothing/head/yogs/tar_king_crown = 1, /obj/item/gem/tarstone = 1, /obj/item/demon_core = 1)
	music_component = /datum/component/music_player/battle
	music_path = /datum/music/sourced/battle/tar_king

	var/list/attack_adjustments = list()
	var/last_done_attack = 0
	var/list/attack_stack = list()
	var/stage = 0
	var/enraged = 0

	var/list/orbitals = list(0,180,240) // second orbital gets set back -60 degrees to align with the others in stage 3
	var/orbital_theta_per_tick = 10
	var/orbital_range = 6

/mob/living/simple_animal/hostile/megafauna/tar_king/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess,src)
	AddComponent(/datum/component/after_image, 0.5 SECONDS, 0.5, FALSE, COLOR_TAR_PURPLE)
	say("You..!", spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)

/mob/living/simple_animal/hostile/megafauna/tar_king/Life(seconds_per_tick, times_fired)
	. = ..()
	if(stat == DEAD)
		return 

	if(prob(25) && target)
		spawn_tar_shrine()

/mob/living/simple_animal/hostile/megafauna/tar_king/death(gibbed, list/force_grant)
	if(health > 0 || stage >= STAGE_DEAD) // still alive or already died
		return
	say("You..", spans = list(SPAN_COLOSSUS), ignore_spam = TRUE) // needs to be said before the actual dying part
	. = ..()
	stage = STAGE_DEAD
	var/obj/effect/dusting_anim/dust_effect = new(loc, ref(src))
	filters += filter(type = "displace", size = 256, render_source = "*snap[ref(src)]")
	animate(src, alpha = 0, color = COLOR_TAR_PURPLE, time = 2 SECONDS, easing = (EASE_IN | SINE_EASING))
	walk(src, 0)
	QDEL_IN(dust_effect, 2 SECONDS)
	QDEL_IN(src, 2 SECONDS)

/mob/living/simple_animal/hostile/megafauna/tar_king/FindTarget(list/possible_targets, HasTargetsList)
	if(stage >= STAGE_DEAD)
		return // dead
	return ..()

/mob/living/simple_animal/hostile/megafauna/tar_king/AttackingTarget()
	if(isliving(target))
		var/mob/living/victim = target
		if(victim.stat && !HAS_TRAIT(victim, TRAIT_NODEATH))
			devour(victim)
			return
	if(attack_stack.len) // currently doing a combo
		return
	face_atom(target)
	if(stage >= STAGE_MID && prob(40)) // start doing occasional stabs in the second stage
		sword_stab(melee_damage_upper, 3 + stage)
	else
		sword_cleave(get_dir(src, target), min(90 + stage * 90, 270), melee_damage_upper, stage >= STAGE_MID) // cleave between 90 and 270 degrees based on stage

/mob/living/simple_animal/hostile/megafauna/tar_king/devour(mob/living/new_convert)
	say(pick("Useless..", "Weak.."), spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)
	if(ishuman(new_convert))
		new_convert.death()
		new_convert.visible_message(span_warning("[src] reanimates [new_convert] as a new convert!"))
		new /mob/living/simple_animal/hostile/tar/amalgamation/convert(new_convert.loc, new_convert)
	else
		new_convert.visible_message("[src] crumbles to dust!")
		new_convert.dust(drop_items = TRUE)
	target = null

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/sword_cleave(attack_dir, arc_size = 90, damage = 40, extra_range = FALSE)
	if(!target)
		CRASH("Tar King attacking null target!")
	var/turfs_count = round(arc_size / 90, 1)
	var/turf/king_turf = get_turf(src)
	if(stage == STAGE_END || !Adjacent(target)) // teleport to the target if too far away
		do_teleport(src, get_step(get_turf(target), turn(attack_dir, stage == STAGE_END ? rand(360) : 180)))
		Beam(king_turf, "purple_lightning", time = 0.5 SECONDS)
		SLEEP_CHECK_DEATH(0.1 SECONDS)
	var/turf/cleave_turf
	var/cleave_dir
	for(var/i in -min(turfs_count, 3) to min(turfs_count, 4))
		cleave_dir = turn(attack_dir, i * 45)
		cleave_turf = get_step(king_turf, cleave_dir)
		new /obj/effect/better_animated_temp_visual/tar_king_chaser_impale(cleave_turf, src, damage)
		if(extra_range && !ISDIAGONALDIR(cleave_dir) && (turfs_count == 1 || abs(i) < turfs_count))
			new /obj/effect/better_animated_temp_visual/tar_king_chaser_impale(get_step(cleave_turf, cleave_dir), src, damage)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/sword_stab(damage = 15, stab_range = 5)
	if(!target)
		CRASH("Tar King attacking null target!")
	var/turf/target_turf = get_turf(target)
	var/turf/sword_turf = get_turf(src)
	var/delta_x = target_turf.x - sword_turf.x
	var/delta_y = target_turf.y - sword_turf.y
	if(stage == STAGE_END || (delta_x && delta_y)) // if the path to the target is diagonal, teleport to a position where it has a horizontal/vertical path
		if(stage == STAGE_END)
			if(prob(50))
				delta_x = pick(-2, 2)
				delta_y = 0
			else
				delta_x = 0
				delta_y = pick(-2, 2)
		else
			if(abs(delta_x) > abs(delta_y))
				delta_x = 0
				delta_y = min(abs(delta_y), 2) * SIGN(delta_y)
			else
				delta_x = min(abs(delta_x), 2) * SIGN(delta_x)
				delta_y = 0
		target_turf = locate(sword_turf.x + delta_x, sword_turf.y + delta_y, target_turf.z)
		do_teleport(src, target_turf, forced = TRUE)
		Beam(sword_turf, "purple_lightning", time = 0.5 SECONDS)
		sword_turf = get_turf(src)
		face_atom(target)
		SLEEP_CHECK_DEATH(0.1 SECONDS)
	else
		face_atom(target)
	var/stab_dir = get_dir(src, target)
	var/turn_size = ISDIAGONALDIR(stab_dir) ? 45 : 90
	for(var/i = 1; i <= stab_range; i++)
		SLEEP_CHECK_DEATH(0.1 SECONDS)
		if(stage >= STAGE_MID && i != 1 && i != stab_range) // 3 wide in the last stage
			new /obj/effect/better_animated_temp_visual/tar_king_chaser_impale(get_step(sword_turf, turn(stab_dir, turn_size)), src, damage)
			new /obj/effect/better_animated_temp_visual/tar_king_chaser_impale(get_step(sword_turf, turn(stab_dir, -turn_size)), src, damage)
		sword_turf = get_step(sword_turf, stab_dir)
		new /obj/effect/better_animated_temp_visual/tar_king_chaser_impale(sword_turf, src, damage)

/mob/living/simple_animal/hostile/megafauna/tar_king/process()
	if(stat == DEAD || stage >= STAGE_DEAD)
		STOP_PROCESSING(SSfastprocess, src)
		return
	if(!attack_stack.len) // stage transition
		check_stage()
	process_orbitals()

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/enrage()
	enraged++
	say(enraged == 1 ? "Hmm.." : "You dare..", spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)
	if(enraged >= ENRAGE_LIMIT)
		ADD_TRAIT(src, TRAIT_SHIELDBUSTER, ENRAGED_TRAIT) // prevents cheesing the boss by parrying it forever
		addtimer(CALLBACK(src, PROC_REF(end_enrage)), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/end_enrage(callout = FALSE)
	if(!enraged)
		return
	if(callout && enraged >= ENRAGE_LIMIT)
		say(pick("Fool..!", "You thought me defeated..?"), spans = list(SPAN_COLOSSUS), ignore_spam = TRUE) // mock the player for their hubris
	enraged--
	if(!enraged)
		REMOVE_TRAIT(src, TRAIT_SHIELDBUSTER, ENRAGED_TRAIT)

/mob/living/simple_animal/hostile/megafauna/tar_king/Goto(target, delay, minimum_distance)
	if(!attack_stack.len)
		return ..()
	else
		walk(src,0)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/add_mob_profile(mob/living/L)
	attack_adjustments[L.real_name] = ATTACK_MATRIX
	RegisterSignal(L,COMSIG_MOVABLE_MOVED,PROC_REF(react_after_move))

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/react_after_move(mob/living/L, old_loc, target_dir, forced)
	if(!last_done_attack || last_done_attack == TAR_ATTACK || last_done_attack == RUNE_ATTACK)
		return
	var/angle_dir_target = dir2angle(target_dir)
	angle_dir_target = angle_dir_target == 0 ? 360 : angle_dir_target
	var/chosen_dir = angle2dir(angle_dir_target -  dir2angle(get_dir(src,L)))
	attack_adjustments[L.real_name][last_done_attack][uppertext(dir2text(chosen_dir))] += 1
	last_done_attack = 0

/mob/living/simple_animal/hostile/megafauna/tar_king/Shoot()
	if(attack_stack.len)
		return
	attack_stack = forge_combo()
	SetRecoveryTime((2 - stage / 2) SECONDS, 0)

	while(attack_stack.len)
		walk(src,0)
		switch(attack_stack[1])
			if(SLASH_ATTACK)
				slash_attack_chain()
			if(IMPALE_ATTACK)
				impale_attack_chain()
			if(RUNE_ATTACK)
				rune_attack_chain()
		attack_stack.Cut(1, 2)
		//INVOKE_ASYNC(src, PROC_REF(Goto), target, move_to_delay, minimum_distance)
		SLEEP_CHECK_DEATH((0.5 - stage / 4) SECONDS)
		if(check_stage())
			return
		if(!target || QDELETED(target))
			return

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/check_stage()
	if(stage < STAGE_END && health < 800)
		stage = STAGE_END
		speed = 2
		move_to_delay = 2
		ranged_cooldown_time = 2 SECONDS
		orbitals[2] -= 60 // move it back so all 3 orbitals are evenly spaced
		say(pick("Die..!", "Enough..!"), spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)
		stage_transition()
		return TRUE
	else if(stage < STAGE_MID && health < 1500)
		stage = STAGE_MID
		ranged_cooldown_time = 3 SECONDS
		say(pick("Ah.. a worthy opponent..!", "A challenge..!"), spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)
		stage_transition()
		return TRUE
	return FALSE

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
	if(dist > 4 && move == SLASH_ATTACK)
		var/step_dir = pick(GLOB.alldirs)
		var/turf/new_loc = get_step(L,step_dir)
		Move(new_loc,get_dir(src,new_loc))
		say("Coward..!", spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)	

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
	var/last_move = ""
	for(var/i = 0; i < 3 + stage * 2; i++) // 3-7 attacks in the combo based on current stage
		last_move = pick(list(SLASH_ATTACK, IMPALE_ATTACK, RUNE_ATTACK) - last_move) // don't do the same attack twice
		combo += last_move
	return combo

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/slash_attack_chain(arc_size = 90)
	slash_attack_telegraph(arc_size)
	SLEEP_CHECK_DEATH(0.3 SECONDS)
	react(SLASH_ATTACK)
	SLEEP_CHECK_DEATH(0.3 SECONDS)
	slash_attack_finish()

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/slash_attack_telegraph()
	say("En-Ghar..!", spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)
	animate(src, 0.6 SECONDS, transform = turn(matrix(), 30))
	sword_cleave(dir, 90, 15, TRUE)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/slash_attack_finish()
	animate(src, 0.2 SECONDS, transform = initial(transform))
	new /obj/effect/tar_king/slash(get_turf(src),src,dir)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/impale_attack_chain()
	impale_attack_telegraph()
	SLEEP_CHECK_DEATH(0.3 SECONDS)
	react(IMPALE_ATTACK)
	SLEEP_CHECK_DEATH(0.3 SECONDS)
	impale_attack_finish()	

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/impale_attack_telegraph()
	say("Et-Tyr..!", spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)
	INVOKE_ASYNC(src, PROC_REF(sword_stab), 15, 5 + stage)
	switch(dir)
		if(NORTH)
			animate(src,0.2 SECONDS,pixel_y = initial(pixel_y) - 10)
		if(SOUTH)
			animate(src,0.2 SECONDS,pixel_y = initial(pixel_y) + 10)
		if(EAST)
			animate(src,0.2 SECONDS,pixel_x = initial(pixel_y) - 10)
		if(WEST)
			animate(src,0.2 SECONDS,pixel_x = initial(pixel_y) + 10)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/impale_attack_finish()
	new /obj/effect/tar_king/impale(get_turf(src),src,dir)
	SLEEP_CHECK_DEATH(2)
	animate(src, 0.2 SECONDS, pixel_x = initial(pixel_x), pixel_y = initial(pixel_y))

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/rune_attack_chain(direct_teleport = TRUE, chain_length = 0)
	new /obj/effect/tar_king/orb_in(get_turf(src),src,dir)

	var/turf/target_turf = get_turf(target)
	var/turf/start_turf

	if(direct_teleport)
		start_turf = get_turf(src)
	else
		var/distance_to_target
		var/list/available_pits = list()
		for(var/obj/structure/tar_pit/pit as anything in GLOB.tar_pits)
			distance_to_target = get_dist(pit, target)
			if(distance_to_target > 8) // too far away from the target
				continue
			if(distance_to_target < 2) // too close to the target
				continue
			available_pits += pit

		if(available_pits.len)
			start_turf = get_turf(pick(available_pits))
		else if(get_dist(src, target) > 2)
			start_turf = get_turf(src)
		else // pick a random turf in the area and hope for the best
			var/area/target_area = get_area(target)
			start_turf = pick(target_area.turfs_by_zlevel[target_turf])

	// moving rune effect that travels towards where the tar king will be
	var/obj/effect/tar_king/rune_attack/tar_telegraph = new(target_turf, null, get_dir(src, target))
	tar_telegraph.pixel_x += ((start_turf.x - target_turf.x) * 32)
	tar_telegraph.pixel_y += ((start_turf.y - target_turf.y) * 32)

	animate(
		tar_telegraph,
		0.7 SECONDS,
		FALSE,
		pixel_x = initial(tar_telegraph.pixel_x),
		pixel_y = initial(tar_telegraph.pixel_y),
		easing = SINE_EASING | EASE_OUT
	)

	icon_state = "tar_king_chaser"
	if(!direct_teleport) // just go straight to the target
		var/turf/original = get_turf(src)
		do_teleport(src, start_turf, forced = TRUE)
		playsound(src,'sound/magic/blind.ogg', 125, 1, -5) //make a sound
		Beam(original, "purple_lightning", time = 0.5 SECONDS)
		say("Ishakt-Tarim..!", spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)

	SLEEP_CHECK_DEATH(1 SECONDS)
	do_teleport(src, target_turf, forced = TRUE)
	Beam(start_turf, "purple_lightning", time = 0.5 SECONDS)
	say("Atyr..!", spans = list(SPAN_COLOSSUS), ignore_spam = TRUE)

	SLEEP_CHECK_DEATH(0.2 SECONDS)
	playsound(src,'sound/magic/blind.ogg', 125, 1, -5) //make a sound
	for(var/mob/living/carbon/victim in range(2, src))
		if(victim == src)
			continue
		if(victim.check_shields(src, 25, "rune magic", MELEE_ATTACK, armour_penetration, BRUTE))
			enrage()
			continue
		else
			end_enrage(TRUE)
		var/limb_to_hit = victim.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		victim.apply_damage(25, BURN, limb_to_hit, victim.run_armor_check(limb_to_hit, MAGIC, null, null, armour_penetration), wound_bonus = CANT_WOUND)
		playsound(victim,'sound/weapons/sear.ogg', 50, 1, -4)

	if(chain_length < stage && get_dist(src, target) > 1)
		rune_attack_chain(TRUE, chain_length + 1)
	else
		SLEEP_CHECK_DEATH(0.5 SECONDS)
		icon_state = "tar_king"

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/process_orbitals()
	var/orbitals_shown = 1 + stage

	for(var/i in 1 to orbitals.len)
		orbitals[i] += orbital_theta_per_tick

	for(var/i in 1 to orbitals_shown)
		var/xcoord = loc.x + orbital_range * cos(orbitals[i])
		var/ycoord = loc.y + orbital_range * sin(orbitals[i])
		var/turf/located = locate(xcoord,ycoord,loc.z)
		new /obj/effect/better_animated_temp_visual/tar_king_chaser_impale(located, src, 10)

/mob/living/simple_animal/hostile/megafauna/tar_king/proc/stage_transition()
	walk(src,0)
	SetRecoveryTime(10 SECONDS, 0)
	icon_state = "tar_king_chaser"
	for(var/i in 0 to stage)
		new /obj/effect/temp_visual/tar_king_chaser(loc, src, target, 1)
	attack_stack += STAGE_TRANSITION
	SLEEP_CHECK_DEATH(10 SECONDS)
	icon_state = "tar_king"
	attack_stack -= STAGE_TRANSITION

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale
	duration = 10
	icon = 'yogstation/icons/effects/32x48.dmi'
	animated_icon_state = "tar_king_special"
	name = "incoming doom"
	desc = "Run while you still can!"
	var/damage
	var/bursting
	var/mob/living/caster

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/Initialize(mapload, new_caster, new_damage)
	. = ..()
	caster = new_caster
	damage = new_damage
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
	sleep(0.6 SECONDS) // needs to line up with the sprite's animation
	bursting = TRUE
	do_damage(T)
	sleep(0.1 SECONDS) // slightly forgiving so that you don't hit yourself twice on the same tile
	bursting = FALSE 

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/proc/on_entered(datum/source, atom/movable/AM, ...)
	if(bursting)
		do_damage(get_turf(src))

/obj/effect/better_animated_temp_visual/tar_king_chaser_impale/proc/do_damage(turf/T)
	if(!damage)
		return
	for(var/mob/living/victim in T.contents) //find and damage mobs...
		if((caster && caster.faction_check_mob(victim)) || victim.stat == DEAD || victim == caster)
			continue
		var/mob/living/simple_animal/hostile/megafauna/tar_king/king_of_tar = caster
		if(victim.check_shields(caster, damage, name, MELEE_ATTACK, 50, BRUTE))
			if(istype(king_of_tar))
				king_of_tar.enrage()
			continue
		else
			if(istype(king_of_tar))
				king_of_tar.end_enrage(TRUE)
		playsound(victim, pick('sound/weapons/sword1.ogg','sound/weapons/sword2.ogg'), 50, 1, -4)
		to_chat(victim, span_userdanger("You're struck by a [name]!"))
		var/limb_to_hit = victim.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		var/armor = victim.run_armor_check(limb_to_hit, MELEE, "Your armor absorbs [src]!", "Your armor blocks part of [src]!", 50, "Your armor was penetrated by [src]!")
		victim.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus = CANT_WOUND)
		if(caster)
			log_combat(caster, victim, "struck with a [name]")

	for(var/obj/mecha/mech in T.contents) //also damage mechs.
		if(mech.occupant)
			if(caster && caster != mech && caster.faction_check_mob(mech.occupant))
				continue
			to_chat(mech.occupant, span_userdanger("Your [mech.name] is struck by a [name]!"))
		playsound(mech,'sound/weapons/sword2.ogg', 50, 1, -4)
		mech.take_damage(damage, BRUTE, MELEE, 0)

/obj/effect/temp_visual/tar_king_chaser
	duration = 10 SECONDS
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
	new /obj/effect/better_animated_temp_visual/tar_king_chaser_impale(loc, caster, damage)

/obj/item/gps/internal/tar_king
	icon_state = null
	gpstag = "Murky Signal"
	desc = "There's something flickering in the dark."
	invisibility = 100
