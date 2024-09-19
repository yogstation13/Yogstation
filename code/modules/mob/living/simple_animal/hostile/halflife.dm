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
	var/headcrabspawn = /mob/living/simple_animal/hostile/halflife/headcrab
	var/idle_sound_chance = 50
	var/sound_vary = TRUE
	var/fungalheal = FALSE
	var/aggro_sound = 'sound/creatures/halflife/zombieaggro.ogg'
	var/idle_sounds = list('sound/creatures/halflife/zombiesound.ogg', 'sound/creatures/halflife/zombiesound2.ogg', 'sound/creatures/halflife/zombiesound3.ogg')

/mob/living/simple_animal/hostile/halflife/zombie/Aggro()
	. = ..()
	set_combat_mode(TRUE)
	if(prob(idle_sound_chance))
		playsound(src, aggro_sound, 50, sound_vary)

/mob/living/simple_animal/hostile/halflife/zombie/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(stat)
		return
	if(prob(10))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, sound_vary)
	//If there is fungal infestation on the ground, and the zombie can heal off of it, do so
	if(fungalheal)
		if(locate(/obj/structure/alien/weeds) in src.loc)
			adjustHealth(-maxHealth*0.05)


/mob/living/simple_animal/hostile/halflife/zombie/death(gibbed)
	if(prob(25) && crabless_possible) //25% chance to spawn a headcrab on death
		icon_dead = no_crab_state
		icon_state = no_crab_state
		new headcrabspawn(get_turf(src))
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

/mob/living/simple_animal/hostile/halflife/zombie/fast
	name = "Fast Zombie"
	desc = "A terrifying skinless human, taken over by a parasitic head crab."
	icon_state = "fastzombie"
	icon_living = "fastzombie"
	icon_dead = "fastzombie_dead"
	faction = list("headcrab")
	maxHealth = 100
	health = 100
	speak_chance = 0
	melee_damage_lower = 8
	melee_damage_upper = 10
	rapid_melee = 4 //attacks quite fast
	attack_sound = 'sound/creatures/halflife/fastzombieattack.ogg'
	combat_mode = TRUE
	move_to_delay = 3
	ranged = 1 //for jumping
	deathsound = 'sound/creatures/halflife/fastzombiedeath.ogg'
	no_crab_state = "fastzombie_nocrab"
	idle_sound_chance = 100
	sound_vary = FALSE
	aggro_sound = 'sound/creatures/halflife/fastzombiealert.ogg'
	idle_sounds = list('sound/creatures/halflife/fastzombie_breath.ogg', 'sound/creatures/halflife/fastzombiesound1.ogg', 'sound/creatures/halflife/fastzombiesound2.ogg', 'sound/creatures/halflife/fastzombiesound3.ogg')
	var/charging = FALSE
	var/revving_charge = FALSE
	var/dash_speed = 1

/mob/living/simple_animal/hostile/halflife/zombie/fast/OpenFire()
	if(charging)
		return
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)
		charge()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/halflife/zombie/fast/proc/charge(atom/chargeat = target, delay = 5)
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
	playsound(src, 'sound/creatures/halflife/fastzombieleap.ogg', 40, sound_vary)
	walk_towards(src, T, dash_speed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * dash_speed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/halflife/zombie/fast/Move()
	if(revving_charge)
		return FALSE
	..()

/mob/living/simple_animal/hostile/halflife/zombie/fungal
	name = "Fungal Zombie"
	desc = "A shambling human, taken over by a parasitic head crab. This one is covered in a spreading fungal infection."
	icon_state = "fungalzombie"
	icon_living = "fungalzombie"
	icon_dead = "fungalzombie_dead"
	no_crab_state = "fungalzombie_nocrab"
	maxHealth = 180
	health = 180
	fungalheal = TRUE
	move_to_delay = 6
	headcrabspawn = /mob/living/simple_animal/hostile/halflife/headcrab/armored
	var/datum/action/cooldown/spell/conjure/xenfloor/infest

/mob/living/simple_animal/hostile/halflife/zombie/fungal/Initialize(mapload)
	. = ..()
	infest = new(src)
	infest.Grant(src)

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
	ranged = 1 //for leaping
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

/mob/living/simple_animal/hostile/halflife/headcrab/armored
	name = "Armored Headcrab"
	desc = "A parasitic headcrab with a hardened fungal carapace."
	icon_state = "armoredheadcrab"
	icon_living = "armoredheadcrab"
	icon_dead = "armoredheadcrab_dead"
	maxHealth = 70
	health = 70
