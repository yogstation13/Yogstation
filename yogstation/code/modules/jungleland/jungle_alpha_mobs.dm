/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha
	gold_core_spawnable = NO_SPAWN
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = MOB_BEAST | MOB_ORGANIC

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/death(gibbed)
	new /obj/structure/closet/crate/necropolis/tendril(loc)
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Big squiggle----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_meduracha
	name ="Meduracha majora"
	desc = "Colossal mass of tentacles, its deep eye looks directly at you."
	icon_state = "alpha_meduracha"
	icon_living = "alpha_meduracha"
	icon_dead = "alpha_meduracha_dead"
	speak = list("hgrah!","blrp!","poasp!","ahkr!")
	speak_emote = list("bubbles", "vibrates")
	emote_hear = list("gazes.","bellows.","splashes.")
	emote_taunt = list("reverbs", "shakes")
	speak_chance = 1
	taunt_chance = 1
	move_to_delay = 7
	butcher_results = list(/obj/item/stack/sheet/meduracha = 5, /obj/item/gem/emerald = 2)
	maxHealth = 300
	health = 300
	spacewalk = TRUE
	crusher_loot = /obj/item/crusher_trophy/jungleland/meduracha_tentacles
	melee_damage_lower = 25
	melee_damage_upper = 25
	ranged = TRUE 
	ranged_cooldown = 5 SECONDS
	projectiletype = /obj/projectile/reagent/meduracha_spit

	var/list/anchors = list("SOUTH" = null, "NORTH" = null, "EAST" = null, "WEST" = null)
	
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_meduracha/Initialize()
	. = ..()
	for(var/side in anchors)
		anchors[side] = get_beam()
	
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_meduracha/Move(atom/newloc, dir, step_x, step_y)
	for(var/direction in list("NORTH","SOUTH","EAST","WEST"))
		var/datum/beam/B = anchors[direction]
		if(!B || QDELETED(B))
			anchors[direction] = get_beam()
			B = anchors[direction]
		if(get_dist(B.target,src) > 5)
			remake_beam(direction)
	. = ..() 
	
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_meduracha/Shoot(atom/targeted_atom)
	. = ..()
	var/angle = Get_Angle(src,targeted_atom)
	var/list/to_shoot = list() 
	
	to_shoot += get_turf(targeted_atom)
	to_shoot += locate(round(x + sin(angle + 20) * 7),round(y + cos(angle + 15) * 7),z)
	to_shoot += locate(round(x + sin(angle - 20) * 7),round(y + cos(angle - 15) * 7),z)
	for(var/turf/T as anything in to_shoot)
		shoot_projectile(T)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_meduracha/proc/shoot_projectile(atom/targeted_atom)
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

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_meduracha/proc/get_beam()
	var/list/turfs = spiral_range_turfs(4,src)
	var/turf/T = pick(turfs)
	return Beam(T,"meduracha",'yogstation/icons/effects/beam.dmi',INFINITY,8)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_meduracha/proc/remake_beam(side)
	var/datum/beam/B = anchors[side]
	anchors[side] = get_beam()
	qdel(B)

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Big blob--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_blobby
	name = "Gelatinous Giant"
	desc = "A gelatinous creature of the swampy regions of the jungle. It's a big blob of goo, and it's not very friendly."
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	icon_state = "big_blob"
	icon_living = "big_blob"
	icon_dead = "big_blob_dead"
	speak = list("brbl","bop","pop","blsp")
	speak_emote = list("bops", "pops")
	emote_hear = list("vibrates.","listens.","hears.")
	emote_taunt = list("pops agressively")
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	faction = list("mining")
	maxHealth = 400
	health = 400
	spacewalk = TRUE
	pixel_x = -16
	pixel_y = -16
	move_to_delay = 5
	loot  = list(/obj/item/stack/sheet/slime = 10, /obj/item/gem/emerald = 2)
	melee_damage_lower = 40
	melee_damage_upper = 40
	crusher_loot = /obj/item/crusher_trophy/jungleland/blob_brain
	/// Increments up as splits happen, used to shrink the mob
	var/stage = 1
	/// How much health needs to be lost to split off new blobs
	var/stage_threshold = 100 //every 100 health lost, split off

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_blobby/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(stage < (maxHealth/stage_threshold - health/stage_threshold) + 1)
		increment_stage()

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_blobby/proc/increment_stage()
	if(!target)
		return
	var/mob/living/simple_animal/hostile/A = new /mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby(get_step(src,turn(get_dir(src,target),90)), 4 - stage)
	var/mob/living/simple_animal/hostile/B = new /mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby(get_step(src,turn(get_dir(src,target),-90)), 4 - stage)
	A.PickTarget(list(target))
	B.PickTarget(list(target))
	stage++
	var/matrix/M = new
	M.Scale(1/stage)
	transform = M

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------Big trees------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad
	name ="Wrath of Gaia"
	desc = "Colossal tree inhabited by all the furious spirits of the jungle."
	icon = 'yogstation/icons/mob/jungle96x96.dmi'
	icon_state = "wrath_of_gaia"
	icon_living = "wrath_of_gaia"
	icon_dead = "wrath_of_gaia_dead"
	maxHealth = 500
	health = 500
	loot = list(/obj/item/organ/regenerative_core/dryad = 5, /obj/item/gem/emerald = 2)
	crusher_loot = /obj/item/crusher_trophy/jungleland/dryad_branch
	melee_damage_lower = 0
	melee_damage_upper = 0
	minimum_distance = 5
	ranged = TRUE 
	ranged_cooldown_time = 20 SECONDS
	move_to_delay = 10
	pixel_x = -32
	projectiletype = /obj/projectile/jungle/damage_orb

	var/max_spawn = 3
	var/list/spawnables = list(
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/dryad = 4,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha = 2, 
		/mob/living/simple_animal/hostile/asteroid/wasp/yellowjacket = 2,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/emeraldspider = 2,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby = 2,
		/mob/living/simple_animal/hostile/asteroid/wasp/mosquito = 2
	)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad/Shoot(atom/targeted_atom)
	playsound(src, 'sound/magic/clockwork/narsie_attack.ogg', 80, 1)
	addtimer(CALLBACK(src, PROC_REF(finish_shoot), targeted_atom), 1 SECONDS) //give it a slight telegraph before doing the attack

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad/proc/finish_shoot(atom/targeted_atom)
	for(var/i in 1 to rand(1, max_spawn))
		var/to_spawn = pickweight(spawnables)
		var/mob/living/simple_animal/hostile/spawned = new to_spawn(get_step(src,pick(GLOB.cardinals)))
		spawned.PickTarget(targeted_atom)

/**
 * Corrupted version also shoots, but spawns less enemies and mostly spawns corrupted dryads
 */
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad/corrupted
	name ="Wrath of Corruption"
	desc = "Colossal tree that used to be a home to the dryads. Now it serves as a weapon of corruption, spreading it's destruction wherever it goes."
	icon_state = "wrath_of_corruption"
	icon_living = "wrath_of_corruption"
	icon_dead = "wrath_of_corruption_dead"
	loot = list(/obj/item/organ/regenerative_core/dryad/corrupted = 5, /obj/item/gem/emerald = 2)
	crusher_loot = /obj/item/crusher_trophy/jungleland/corrupted_dryad_branch

	max_spawn = 2
	spawnables = list(
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/corrupted_dryad = 20
	)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad/corrupted/finish_shoot(atom/targeted_atom)
	. = ..()
	var/angle = Get_Angle(src,targeted_atom)
	var/list/to_shoot = list() 
	
	to_shoot += get_turf(targeted_atom)
	to_shoot += locate(round(x + sin(angle + 30) * 7),round(y + cos(angle + 15) * 7),z)
	to_shoot += locate(round(x + sin(angle - 30) * 7),round(y + cos(angle - 15) * 7),z)
	to_shoot += locate(round(x + sin(angle + 15) * 7),round(y + cos(angle + 15) * 7),z)
	to_shoot += locate(round(x + sin(angle - 15) * 7),round(y + cos(angle - 15) * 7),z)

	for(var/turf/T as anything in to_shoot)
		shoot_projectile(T)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_dryad/corrupted/proc/shoot_projectile(atom/targeted_atom)
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

////////////////////////////////////////////////////////////////////////////////////
//------------------------------------Big wasp------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket
	name = "yellow jacket matriarch"
	desc = "A large and aggressive creature with a massive stinger, it looks very angry."
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	icon_state = "wasp"
	icon_living = "wasp"
	icon_dead = "wasp_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 5
	movement_type = FLYING
	ranged = 1
	ranged_cooldown_time = 12 SECONDS
	speak_emote = list("buzzes")
	vision_range = 5
	aggro_vision_range = 9
	speed = 2
	maxHealth = 280
	health = 280
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
	var/dash_speed = 1
	var/charging = FALSE
	var/revving_charge = FALSE
	var/poison_type = /datum/reagent/toxin/concentrated
	var/poison_per_attack = 7.5

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(target.reagents)
			L.reagents.add_reagent(poison_type, poison_per_attack)

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/OpenFire()
	if(charging)
		return
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)
		charge()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/Aggro()
	vision_range = aggro_vision_range

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/proc/charge(atom/chargeat = target, delay = 4)
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
	walk_towards(src, T, dash_speed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * dash_speed)
	walk(src, 0) // cancel the movement
	release_guards()
	charging = FALSE

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/Move()
	if(revving_charge)
		return FALSE
	if(charging)
		DestroySurroundings() //"Fred, were you feeding steroids to the wasp again?"
	..()

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/proc/release_guards()
	new /mob/living/simple_animal/hostile/asteroid/wasp/yellowjacket(get_turf(src))

////////////////////////////////////////////////////////////////////////////////////
//----------------------------------Big mosquito----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/mosquito
	name ="Mosquito Patriarch"
	desc = "A colossal blood sucking mosquito, it looks very angry."
	icon = 'yogstation/icons/mob/jungle64x64.dmi'
	icon_state = "mosquito"
	icon_living = "mosquito"
	icon_dead = "mosquito_dead"
	maxHealth = 350
	health = 350
	move_to_delay = 4
	ranged_cooldown_time = 3 SECONDS //constantly dashes
	crusher_loot = /obj/item/crusher_trophy/jungleland/corrupted_dryad_branch
	butcher_results = list(/obj/item/stinger = 1, /obj/item/stack/sheet/animalhide/weaver_chitin = 2, /obj/item/stack/sheet/sinew = 4, /obj/item/gem/ruby = 2)
	melee_damage_lower = 35
	melee_damage_upper = 35
	pixel_x = -16
	pixel_y = -16
	dash_speed = 0.8
	poison_per_attack = 0
	attack_sound = null

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/mosquito/AttackingTarget()
	..()
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/humie = target
	humie.blood_volume -= 15 // ouch!
	var/malaria_chance = 150 - humie.getarmor(null,BIO) // NEVER 100 PERCENT
	if(prob(malaria_chance * 0.5))
		var/datum/disease/malaria/infection = new() 
		humie.ForceContractDisease(infection,FALSE,TRUE)
	icon_state = "mosquito_blood"

/mob/living/simple_animal/hostile/asteroid/yog_jungle/alpha/alpha_yellowjacket/mosquito/release_guards()
	return //no guards, mosquitos are spiteful creatures
