/mob/living/simple_animal/wallbreaker
	name = "wall breaker"
	desc = "It's a skeleton with a bomb!!"
	icon = 'icons/mob/wallbreaker.dmi'
	icon_state = "wallbreaker"
	icon_living = "wallbreaker"
	icon_dead = "wallbreaker"
	icon_gib = "wallbreaker"
	mob_biotypes = list(MOB_UNDEAD)
	mouse_opacity = MOUSE_OPACITY_ICON
	speak_emote = list("shouts")
	speed = -1
	maxHealth = 50
	health = 50
	harm_intent_damage = 5
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_vis_effect = ATTACK_EFFECT_KICK
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	mob_size = MOB_SIZE_SMALL
	environment_smash = ENVIRONMENT_SMASH_NONE
	gold_core_spawnable = HOSTILE_SPAWN
	var/datum/action/innate/wallbreaker/explode/E
	var/turf/closed/wall/target

/mob/living/simple_animal/wallbreaker/Initialize()
	. = ..()
	E = new
	E.Grant(src)

/mob/living/simple_animal/wallbreaker/Destroy()
	QDEL_NULL(E)
	return ..()

/mob/living/simple_animal/wallbreaker/Life()
	if(AIStatus == AI_ON)
		var/turf/closed/wall/closest_wall = null
		var/closest_wall_dist = 1000
		for (var/turf/closed/wall/W in range(9))
			var/dist = get_dist(get_turf(src), W)
			if (dist < closest_wall_dist)
				closest_wall = W
				closest_wall_dist = dist
				if (dist <= 1)
					E.Activate()
					return
		if (closest_wall)
			target = closest_wall
		step_to(src, target, 0, 1)
	

/datum/action/innate/wallbreaker/explode
	name = "Detonate"
	desc = "Explode your bomb!"
	button_icon_state = "bonechill"
	icon_icon = 'icons/mob/actions/actions_humble.dmi'

/datum/action/innate/wallbreaker/explode/Activate()
	for (var/turf/closed/wall/wall in range(1))
		wall.ex_act(1)
	dyn_explosion(get_turf(owner), 15, 30)

/mob/living/simple_animal/wallbreaker/death(gibbed)
	E.Activate()
