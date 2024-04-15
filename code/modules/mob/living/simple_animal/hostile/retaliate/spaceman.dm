/mob/living/simple_animal/hostile/retaliate/spaceman
	name = "spaceman"
	desc = "What in the actual hell..?"
	icon_state = "old"
	icon_living = "old"
	icon_dead = "old_dead"
	icon_gib = "clown_gib"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	gender = MALE
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "punches"
	a_intent = INTENT_HARM
	maxHealth = 100
	health = 100
	speed = 0
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "hits"
	attack_sound = 'sound/weapons/punch1.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/retaliate/yogscastpeace //this should be in a different file
	name = "yogscast Private Security Officer"
	desc = "An officer part of yogscast's private security force."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "yogscast"
	icon_living = "yogscast"
	icon_dead = null
	icon_gib = "syndicate_gib"
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	vision_range = 3
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("yogscastprivate")
	a_intent = INTENT_HARM
	loot = list(/obj/effect/mob_spawn/human/corpse/yogscastsoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	status_flags = CANPUSH
	search_objects = 1

/mob/living/simple_animal/hostile/retaliate/yogscastpeace/Aggro()
	..()
	summon_backup(15)
	say("411 in progress, requesting backup!")

/mob/living/simple_animal/hostile/retaliate/yogscastpeace/ranged
	icon_state = "yogscastrangedsmg"
	icon_living = "yogscastrangedsmg"
	vision_range = 9
	rapid = 3
	ranged = 1
	retreat_distance = 3
	minimum_distance = 5
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gunshot_smg.ogg'
	loot = list(/obj/item/gun/ballistic/automatic/wt550,
				/obj/effect/mob_spawn/human/corpse/yogscastsoldier)
