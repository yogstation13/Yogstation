/mob/living/simple_animal/hostile/yog_jungle/alpha
	gold_core_spawnable = FALSE

/mob/living/simple_animal/hostile/yog_jungle/alpha/death(gibbed)
	new /obj/structure/closet/crate/necropolis/tendril(loc)
	return ..()

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_meduracha
	name ="Meduracha majora"
	desc = "Collosal beast of tentacles, its deep eye looks directly at you."
	icon_state = "alpha_meduracha"
	icon_living = "alpha_meduracha"
	icon_dead = "alpha_meduracha_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("hgrah!","blrp!","poasp!","ahkr!")
	speak_emote = list("bubbles", "vibrates")
	emote_hear = list("gazes.","bellows.","splashes.")
	emote_taunt = list("reverbs", "shakes")
	speak_chance = 1
	taunt_chance = 1
	move_to_delay = 7
	butcher_results = list(/obj/item/stack/sheet/meduracha = 5, /obj/item/gem/emerald = 2)
	faction = list("mining")
	response_help  = "gently pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 300
	health = 300
	spacewalk = TRUE
	crusher_loot = /obj/item/crusher_trophy/jungleland/meduracha_tentacles
	melee_damage_lower = 20
	melee_damage_upper = 25
	ranged = TRUE 
	ranged_cooldown = 5 SECONDS
	projectiletype = /obj/projectile/jungle/meduracha_spit
	sentience_type = SENTIENCE_BOSS

	var/list/anchors = list("SOUTH" = null, "NORTH" = null, "EAST" = null, "WEST" = null)
	
/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_meduracha/Initialize()
	. = ..()
	for(var/side in anchors)
		anchors[side] = get_beam()
	
/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_meduracha/Move(atom/newloc, dir, step_x, step_y)
	for(var/direction in list("NORTH","SOUTH","EAST","WEST"))
		var/datum/beam/B = anchors[direction]
		if(!B || QDELETED(B))
			anchors[direction] = get_beam()
			B = anchors[direction]
		if(get_dist(B.target,src) > 5)
			remake_beam(direction)
	. = ..() 
	
/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_meduracha/Shoot(atom/targeted_atom)
	. = ..()
	var/angle = Get_Angle(src,targeted_atom)
	var/list/to_shoot = list() 
	
	to_shoot += get_turf(targeted_atom)
	to_shoot += locate(round(x + sin(angle + 20) * 7),round(y + cos(angle + 15) * 7),z)
	to_shoot += locate(round(x + sin(angle - 20) * 7),round(y + cos(angle - 15) * 7),z)
	for(var/turf/T as anything in to_shoot)
		shoot_projectile(T)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_meduracha/proc/shoot_projectile(atom/targeted_atom)
	var/turf/startloc = get_turf(src)
	var/obj/projectile/P = new projectiletype(startloc)
	playsound(src, projectilesound, 100, 1)
	P.starting = startloc
	P.firer = src
	P.fired_from = src
	P.yo = targeted_atom.y - startloc.y
	P.xo = targeted_atom.x - startloc.x
	if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
		newtonian_move(get_dir(targeted_atom, targets_from))
	P.original = targeted_atom
	P.preparePixelProjectile(targeted_atom, src)
	P.fire()

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_meduracha/proc/get_beam()
	var/list/turfs = spiral_range_turfs(4,src)
	var/turf/T = pick(turfs)
	return Beam(T,"meduracha",'yogstation/icons/effects/beam.dmi',INFINITY,8)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_meduracha/proc/remake_beam(side)
	var/datum/beam/B = anchors[side]
	anchors[side] = get_beam()
	qdel(B)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_blobby
	name = "Gelatinous Giant"
	desc = "A gelatinous creature of the swampy regions of the jungle. It's a big blob of goo, and it's not very friendly."
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	icon_state = "big_blob"
	icon_living = "big_blob"
	icon_dead = "big_blob_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("brbl","bop","pop","blsp")
	speak_emote = list("bops", "pops")
	emote_hear = list("vibrates.","listens.","hears.")
	emote_taunt = list("pops agressively")
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	faction = list("mining")
	maxHealth = 400
	health = 400
	spacewalk = TRUE
	pixel_x = -16
	pixel_y = -16
	move_to_delay = 5
	loot  = list(/obj/item/stack/sheet/slime = 10, /obj/item/gem/emerald = 2)
	melee_damage_lower = 30
	melee_damage_upper = 40
	crusher_loot = /obj/item/crusher_trophy/jungleland/blob_brain
	sentience_type = SENTIENCE_BOSS
	var/stage = 1

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_blobby/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if((stage == 1 && health <= 300) || (stage == 2 && health <= 200) || (stage == 3 && health <= 100))
		increment_stage()
		return

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_blobby/proc/increment_stage()
	if(!target)
		return
	var/mob/living/simple_animal/hostile/A = new /mob/living/simple_animal/hostile/yog_jungle/blobby(get_step(src,turn(get_dir(src,target),90)),4 - stage)
	var/mob/living/simple_animal/hostile/B = new /mob/living/simple_animal/hostile/yog_jungle/blobby(get_step(src,turn(get_dir(src,target),-90)),4 - stage)
	A.PickTarget(list(target))
	B.PickTarget(list(target))
	stage++
	var/matrix/M = new
	M.Scale(1/stage)
	transform = M

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_dryad
	name ="Wrath of Gaia"
	desc = "Collosal tree inhabited by all the furious spirits of the jungle."
	icon = 'yogstation/icons/mob/jungle96x96.dmi'
	icon_state = "wrath_of_gaia"
	icon_living = "wrath_of_gaia"
	icon_dead = "wrath_of_gaia_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	faction = list("mining")
	response_help  = "gently pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 500
	health = 500
	crusher_loot = /obj/item/crusher_trophy/jungleland/dryad_branch
	loot = list(/obj/item/organ/regenerative_core/dryad = 5, /obj/item/gem/emerald = 2)
	melee_damage_lower = 20
	melee_damage_upper = 25
	ranged = TRUE 
	ranged_cooldown = 20 SECONDS
	move_to_delay = 10
	pixel_x = -32
	sentience_type = SENTIENCE_BOSS
	var/list/spawnables = list(/mob/living/simple_animal/hostile/yog_jungle/dryad,/mob/living/simple_animal/hostile/yog_jungle/meduracha, /mob/living/simple_animal/hostile/yog_jungle/yellowjacket,/mob/living/simple_animal/hostile/yog_jungle/emeraldspider)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_dryad/OpenFire(atom/A)
	. = ..()
	for(var/i in 0 to rand(1,3))
		var/to_spawn = pick(spawnables)
		var/mob/living/simple_animal/hostile/spawned = new to_spawn(get_step(src,pick(GLOB.cardinals)))
		spawned.PickTarget(A)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_corrupted_dryad
	name ="Wrath of Corruption"
	desc = "Collosal tree that used to be a home of the dryads. Now it serves as a weapon of corruption, spreading it's destruction wherever it goes."
	icon = 'yogstation/icons/mob/jungle96x96.dmi'
	icon_state = "wrath_of_corruption"
	icon_living = "wrath_of_corruption"
	icon_dead = "wrath_of_corruption_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	faction = list("mining")
	response_help  = "gently pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 500
	health = 500
	crusher_loot = /obj/item/crusher_trophy/jungleland/corrupted_dryad_branch
	loot = list(/obj/item/organ/regenerative_core/dryad/corrupted = 5, /obj/item/gem/emerald = 2)
	melee_damage_lower = 20
	melee_damage_upper = 25
	ranged = TRUE 
	ranged_cooldown = 17.5 SECONDS
	move_to_delay = 10
	pixel_x = -32
	projectiletype = /obj/projectile/jungle/damage_orb
	sentience_type = SENTIENCE_BOSS

	var/list/spawnables = list(/mob/living/simple_animal/hostile/yog_jungle/skin_twister,/mob/living/simple_animal/hostile/yog_jungle/blobby,/mob/living/simple_animal/hostile/yog_jungle/corrupted_dryad)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_corrupted_dryad/Shoot(atom/targeted_atom)
	var/angle = Get_Angle(src,targeted_atom)
	var/list/to_shoot = list() 
	
	to_shoot += get_turf(targeted_atom)
	to_shoot += locate(round(x + sin(angle + 30) * 7),round(y + cos(angle + 15) * 7),z)
	to_shoot += locate(round(x + sin(angle - 30) * 7),round(y + cos(angle - 15) * 7),z)
	to_shoot += locate(round(x + sin(angle + 15) * 7),round(y + cos(angle + 15) * 7),z)
	to_shoot += locate(round(x + sin(angle - 15) * 7),round(y + cos(angle - 15) * 7),z)

	for(var/turf/T as anything in to_shoot)
		shoot_projectile(T)
	for(var/i in 0 to rand(1,3))
		var/to_spawn = pick(spawnables)
		var/mob/living/simple_animal/hostile/spawned = new to_spawn(get_step(src,pick(GLOB.cardinals)))
		spawned.faction = faction
		spawned.PickTarget(targeted_atom)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_corrupted_dryad/proc/shoot_projectile(atom/targeted_atom)
	var/turf/startloc = get_turf(src)
	var/obj/projectile/P = new projectiletype(startloc)
	playsound(src, projectilesound, 100, 1)
	P.starting = startloc
	P.firer = src
	P.fired_from = src
	P.yo = targeted_atom.y - startloc.y
	P.xo = targeted_atom.x - startloc.x
	if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
		newtonian_move(get_dir(targeted_atom, targets_from))
	P.original = targeted_atom
	P.preparePixelProjectile(targeted_atom, src)
	P.fire()

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_mosquito
	name ="Mosquito Patriarch"
	desc = "A collosoal blood sucking mosquito, it is very angry."
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	icon_state = "mosquito"
	icon_living = "mosquito"
	icon_dead = "mosquito_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	faction = list("mining")
	response_help  = "gently pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 350
	health = 350
	crusher_loot = /obj/item/crusher_trophy/jungleland/corrupted_dryad_branch
	butcher_results = list(/obj/item/stinger = 1, /obj/item/stack/sheet/animalhide/weaver_chitin = 2, /obj/item/stack/sheet/sinew = 4, /obj/item/gem/ruby = 2)
	melee_damage_lower = 15
	melee_damage_upper = 25
	pixel_x = -16
	pixel_y = -16
	sentience_type = SENTIENCE_BOSS
	var/can_charge = TRUE
	var/cooldown = 5 SECONDS
	var/charge_ramp_up = 1 SECONDS
	var/charging = FALSE

	var/has_blood = FALSE
	var/overshoot_dist = 5

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_mosquito/Aggro()
	. = ..()
	prepare_charge()

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_mosquito/Goto(target, delay, minimum_distance)
	if (iscarbon(target) && get_dist(src,target) > 4 && get_charge())
		prepare_charge()
		return

	if(!charging)
		return ..()

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_mosquito/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	charging = FALSE
	if(!ishuman(hit_atom))
		animate(src,color = initial(color),time = charge_ramp_up/2)
		return 
	
	var/mob/living/carbon/human/humie = hit_atom
	humie.blood_volume -= 15 // ouch!
	var/malaria_chance = 150 - humie.getarmor(null,BIO) // NEVER 100 PERCENT
	if(prob(malaria_chance * 0.5))
		var/datum/disease/malaria/infection = new() 
		humie.ForceContractDisease(infection,FALSE,TRUE)
	has_blood = TRUE 
	rapid_melee = TRUE
	melee_damage_lower = 30 
	melee_damage_upper = 50
	icon_state = "mosquito_blood"
	animate(src,color = initial(color),time = charge_ramp_up*2)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_mosquito/proc/prepare_charge()
	if(!get_charge())
		return FALSE 

	var/dir = Get_Angle(src.loc,target.loc)
	
	//i actually fucking hate this utility function, for whatever reason Get_Angle returns the angle assuming that [0;-1] is 0 degrees rather than [1;0] like any sane being.
	var/tx = clamp(0,round(target.loc.x + sin(dir) * overshoot_dist),255)
	var/ty = clamp(0,round(target.loc.y + cos(dir) * overshoot_dist),255)

	var/turf/found_turf = locate(tx,ty,loc.z)

	if(found_turf == null)
		return FALSE 
	
	var/dist = get_dist(src,found_turf)

	charging = TRUE
	animate(src,color = rgb(163, 0, 0),time = charge_ramp_up)
	sleep(charge_ramp_up)
	if(stat == DEAD)
		animate(src,color = initial(color),time = charge_ramp_up)
		return

	throw_at(found_turf,dist + overshoot_dist,4,spin = FALSE)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_mosquito/proc/reset_charge()
	can_charge = TRUE

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_mosquito/proc/use_charge()
	can_charge = FALSE 
	addtimer(CALLBACK(src,PROC_REF(reset_charge)),cooldown,TIMER_UNIQUE)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_mosquito/proc/get_charge()
	return can_charge 

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_yellowjacket
	name = "yellow jacket matriarch"
	desc = "A large and aggressive creature with a massive stinger. It is very angry."
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	icon_state = "wasp"
	icon_living = "wasp"
	icon_dead = "wasp_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 5
	movement_type = FLYING
	ranged = 1
	ranged_cooldown_time = 120
	speak_emote = list("buzzes")
	vision_range = 5
	aggro_vision_range = 9
	see_in_dark = 7
	speed = 2
	maxHealth = 320
	health = 320
	environment_smash = ENVIRONMENT_SMASH_NONE //held off by walls and windows, stupid oversized bee
	melee_damage_lower = 10  //not that lethal, but it'll catch up to you easily
	melee_damage_upper = 10
	attacktext = "stings"
	attack_sound = 'sound/voice/moth/scream_moth.ogg'
	deathmessage = "rolls over, falling to the ground."
	butcher_results = list(/obj/item/stinger = 1, /obj/item/stack/sheet/animalhide/weaver_chitin = 4, /obj/item/stack/sheet/sinew = 2, /obj/item/gem/topaz = 2)
	loot = list()
	crusher_loot = /obj/item/crusher_trophy/jungleland/wasp_head
	pixel_x = -16 
	pixel_y = -16
	sentience_type = SENTIENCE_BOSS
	var/charging = FALSE
	var/revving_charge = FALSE
	var/poison_type = /datum/reagent/toxin/concentrated
	var/poison_per_attack = 7.5

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_yellowjacket/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(target.reagents)
			L.reagents.add_reagent(poison_type, poison_per_attack)

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_yellowjacket/OpenFire()
	if(charging)
		return
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)
		charge()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_yellowjacket/Aggro()
	vision_range = aggro_vision_range

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_yellowjacket/proc/charge(atom/chargeat = target, delay = 4)
	if(!chargeat)
		return
	var/chargeturf = get_turf(chargeat)
	if(!chargeturf)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir, 2)
	if(!T)
		return
	charging = TRUE
	revving_charge = TRUE
	do_alert_animation(src)
	walk(src, 0)
	setDir(dir)
	SLEEP_CHECK_DEATH(delay)
	revving_charge = FALSE
	var/movespeed = 1
	walk_towards(src, T, movespeed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * movespeed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/yog_jungle/alpha/alpha_yellowjacket/Move()
	if(revving_charge)
		return FALSE
	if(charging)
		DestroySurroundings() //"Fred, were you feeding steroids to the wasp again?"
	..()

