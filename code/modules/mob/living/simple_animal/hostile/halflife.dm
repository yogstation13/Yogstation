/mob/living/simple_animal/hostile/halflife/zombie
	name = "Zombie"
	desc = "A shambling human, taken over by a parasitic head crab."
	icon = 'icons/mob/halflife.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie_dead"
	faction = list("headcrab")
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	stat_attack = UNCONSCIOUS //braains
	maxHealth = 120
	health = 120
	speak_chance = 1
	speak = list("G-GOD HELP ME!","OH G-GOD!","K-KILL ME!")
	harm_intent_damage = 5
	melee_damage_lower = 21
	melee_damage_upper = 21
	attack_vis_effect = ATTACK_EFFECT_CLAW
	attacktext = "claws"
	attack_sound = 'sound/creatures/halflife/zombieattack.ogg'
	combat_mode = TRUE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	status_flags = CANPUSH
	move_to_delay = 5
	deathsound = 'sound/creatures/halflife/zombiedeath.ogg'
	var/no_crab_state = "zombie_dead_nocrab"
	var/crabless_possible = TRUE
	var/aggro_sound = 'sound/creatures/halflife/zombieaggro.ogg'
	var/idle_sounds = list('sound/creatures/halflife/zombiesound.ogg', 'sound/creatures/halflife/zombiesound2.ogg', 'sound/creatures/halflife/zombiesound3.ogg')

/mob/living/simple_animal/hostile/halflife/zombie/Aggro()
	. = ..()
	set_combat_mode(TRUE)
	if(prob(50))
		playsound(src, aggro_sound, 50, TRUE)

/mob/living/simple_animal/hostile/halflife/zombie/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(stat)
		return
	if(prob(10))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/halflife/zombie/death(gibbed)
	if(prob(25) && crabless_possible) //25% chance to spawn a headcrab on death
		icon_dead = no_crab_state
		icon_state = no_crab_state
		new /mob/living/simple_animal/hostile/halflife/headcrab(get_turf(src))
	..()

/mob/living/simple_animal/hostile/halflife/zombie/zombine
	name = "Zombine"
	desc = "A shambling combine soldier, taken over by a parasitic head crab."
	icon_state = "zombine"
	icon_living = "zombie"
	icon_dead = "zombine_dead"
	maxHealth = 180
	health = 180
	speak = list("S-Sector, nnnot... secur-e-e...","B-Biotics-s...","O-Over...watch... r-r-reserve...")
	attack_sound = 'sound/creatures/halflife/zombineattack.ogg'
	deathsound = 'sound/creatures/halflife/zombinedeath.ogg'
	crabless_possible = FALSE
	aggro_sound = 'sound/creatures/halflife/zombineaggro.ogg'
	idle_sounds = list('sound/creatures/halflife/zombinesound1.ogg', 'sound/creatures/halflife/zombinesound2.ogg', 'sound/creatures/halflife/zombinesound3.ogg', 'sound/creatures/halflife/zombinesound4.ogg')

//leaping headcrabs
/mob/living/simple_animal/hostile/halflife/headcrab
	name = "Headcrab"
	desc = "A parasitic headcrab."
	icon = 'icons/mob/halflife.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	faction = list("headcrab")
	mob_biotypes = MOB_ORGANIC
	stat_attack = UNCONSCIOUS //braains
	maxHealth = 30
	health = 30
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_vis_effect = ATTACK_EFFECT_BITE
	ranged = 1 //for charging
	attacktext = "bites"
	attack_sound = 'sound/creatures/halflife/headcrabbite.ogg'
	combat_mode = TRUE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	move_to_delay = 8
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/xen = 1)
	deathsound = 'sound/creatures/halflife/headcrabdeath.ogg'
	var/charging = FALSE
	var/revving_charge = FALSE
	var/dash_speed = 1

/mob/living/simple_animal/hostile/halflife/headcrab/OpenFire()
	if(charging)
		return
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)
		charge()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/halflife/headcrab/proc/charge(atom/chargeat = target, delay = 5)
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
	walk(src, 0)
	setDir(dir)
	SLEEP_CHECK_DEATH(delay)
	revving_charge = FALSE
	playsound(src, 'sound/creatures/halflife/headcrableap.ogg', 40, TRUE)
	walk_towards(src, T, dash_speed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * dash_speed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/halflife/headcrab/Move()
	if(revving_charge)
		return FALSE
	..()
