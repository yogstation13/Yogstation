//A wasp that charges at their enemy, injecting them with poison
/mob/living/simple_animal/hostile/asteroid/wasp
	name = "wasp"
	desc = "A massive, mutated wasp equipped with a giant stinger. Its eyes flash with burning fury."
	icon = 'icons/mob/jungle/wasp.dmi'
	icon_state = "wasp"
	icon_living = "wasp"
	icon_aggro = "wasp"
	icon_dead = "wasp_dead"
	icon_gib = "syndicate_gib"
	throw_message = "bounces harmlessly off the"
	move_to_delay = 16
	movement_type = FLYING
	ranged = 1
	ranged_cooldown_time = 120
	speak_emote = list("buzzes")
	vision_range = 5
	aggro_vision_range = 9
	see_in_dark = 7
	speed = 2
	maxHealth = 200
	health = 200
	environment_smash = ENVIRONMENT_SMASH_NONE //held off by walls and windows, stupid oversized bee
	melee_damage_lower = 12  //not that lethal, but it'll catch up to you easily
	melee_damage_upper = 12
	attacktext = "stings"
	attack_sound = 'sound/voice/moth/scream_moth.ogg'
	message = "rolls over, falling to the ground."
	gold_core_spawnable = HOSTILE_SPAWN
	butcher_results = list(/obj/item/stack/sheet/bone = 1, /obj/item/stack/sheet/sinew = 3, /obj/item/stack/sheet/animalhide/weaver_chitin = 2)
	loot = list()
	var/charging = FALSE
	var/revving_charge = FALSE
	var/poison_type = /datum/reagent/toxin/venom
	var/poison_per_attack = 5

/mob/living/simple_animal/hostile/asteroid/wasp/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(target.reagents)
			L.reagents.add_reagent(poison_type, poison_per_attack)

/mob/living/simple_animal/hostile/asteroid/wasp/OpenFire()
	if(charging)
		return
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)
		charge()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/asteroid/wasp/Aggro()
	vision_range = aggro_vision_range

/mob/living/simple_animal/hostile/asteroid/wasp/proc/charge(var/atom/chargeat = target, var/delay = 5)
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
	SLEEP_CHECK_(delay)
	revving_charge = FALSE
	var/movespeed = 1
	walk_towards(src, T, movespeed)
	SLEEP_CHECK_(get_dist(src, T) * movespeed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/asteroid/wasp/Move()
	if(revving_charge)
		return FALSE
	if(charging)
		DestroySurroundings() //"Fred, were you feeding steroids to the wasp again?"
	..()
