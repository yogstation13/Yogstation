/obj/projectile/robot_bullet
	damage = 15
	damage_type = BRUTE

/obj/projectile/robot_bullet/weak
	damage = 10
	damage_type = BRUTE

/mob/living/simple_animal/hostile/robot
	name = "combat robot"
	desc = "An old outlawed combat robot. This one seems to be fitted with sharp claws."
	icon = 'icons/mob/robots.dmi'
	icon_state = "Security"
	icon_living = "Security"
	
	gender = NEUTER
	mob_biotypes = list(MOB_ROBOTIC)
	health = 75
	maxHealth = 75
	healable = FALSE
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gunshot.ogg'
	projectiletype = /obj/projectile/robot_bullet/weak
	faction = list("robots")
	check_friendly_fire = TRUE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	minbodytemp = 0
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	environment_smash = ENVIRONMENT_SMASH_NONE
	obj_damage = 0

	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/robot_debris)

	do_footstep = TRUE

/mob/living/simple_animal/hostile/robot/Initialize(mapload)
	. = ..()
	deathmessage = "[src] blows apart!"

/mob/living/simple_animal/hostile/robot/Aggro()
	. = ..()
	a_intent_change(INTENT_HARM)
	if(prob(5))
		say(pick("INTRUDER DETECTED!", "CODE 7-34.", "101010!!"), forced = type)

/mob/living/simple_animal/hostile/robot/LoseAggro()
	. = ..()
	a_intent_change(INTENT_HELP)

/mob/living/simple_animal/hostile/robot/death(gibbed)
	do_sparks(3, TRUE, src)
	..(TRUE)


/mob/living/simple_animal/hostile/robot/range
	name = "ranged combat robot"
	desc = "An old outlawed combat robot. This one seems to be fitted with a low-powered rifle."
	ranged = TRUE
	retreat_distance = 6
	minimum_distance = 6

/mob/living/simple_animal/hostile/robot/burst
	desc = "An old outlawed combat robot. This one seems to be fitted with a low-powered machine gun."
	ranged = TRUE
	rapid = 3
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/robot/advanced
	name = "advanced combat robot"
	icon_state = "hosborg"
	icon_living = "hosborg"
	desc = "An old outlawed combat robot. This one has extra armor plates fitted, and sharper claws."
	health = 150
	maxHealth = 150
	dodging = TRUE
	projectiletype = /obj/projectile/robot_bullet
	melee_damage_lower = 8
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/robot/advanced/ranged
	name = "advanced ranged combat robot"
	desc = "An old outlawed combat robot. This one has slightly less extra armor plates fitted, but features a high-powered rifle."
	health = 125
	maxHealth = 125
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/robot/advanced/Initialize(mapload)
	. = ..()
	add_overlay("eyes-hosborg")


//"Weak" commander robot
/mob/living/simple_animal/hostile/boss/robot_leader
	name = "commander robot"
	icon = 'icons/mob/robots.dmi'
	icon_state = "rdborg"
	icon_living = "rdborg"
	desc = "An old outlawed combat robot. This one is fitted with additional sensors and communication antennas."
	mob_biotypes = list(MOB_ROBOTIC)
	boss_abilities = list(/datum/action/boss/robot_summon_weak)
	faction = list("robots")

	ranged = TRUE
	environment_smash = ENVIRONMENT_SMASH_NONE
	minimum_distance = 3
	retreat_distance = 3
	obj_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 25
	health = 500
	maxHealth = 500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	projectiletype = /obj/projectile/robot_bullet
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gunshot.ogg'

	check_friendly_fire = TRUE

	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT


	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/robot_debris)

	do_footstep = TRUE


//Weak Summon Ability
//Robot can summon weak combat robots
/datum/action/boss/robot_summon_weak
	name = "Summon Weak Robots"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "art_summon"
	usage_probability = 30
	boss_cost = 40
	boss_type = /mob/living/simple_animal/hostile/boss/robot_leader
	needs_target = FALSE
	say_when_triggered = "SEND SIGNAL; RECIEVE SUPPORT; COMMENCE DESTRUCTION"
	var/summons_remaining = 6

/datum/action/boss/robot_summon_weak/Trigger()
	if(summons_remaining && ..())
		var/list/minions = list(
			/mob/living/simple_animal/hostile/robot,
			/mob/living/simple_animal/hostile/robot/range)
		var/list/directions = GLOB.cardinals.Copy()
		for(var/i in 1 to 3)
			var/minions_chosen = pick(minions)
			new minions_chosen (get_step(boss, pick_n_take(directions)), TRUE)
		summons_remaining -= 3;
