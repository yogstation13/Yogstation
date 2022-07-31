/mob/living/simple_animal/hostile/flockdrone
	name = "flock drone"
	desc = "A weird glowy thing."
	speak_emote = list("tones")
	initial_language_holder = /datum/language_holder/swarmer
	bubble_icon = "swarmer"
	mob_biotypes = MOB_ROBOTIC
	health = 40
	maxHealth = 40
	status_flags = CANPUSH
	icon_state = "swarmer"
	icon_living = "swarmer"
	icon_dead = "swarmer_unactivated"
	icon_gib = null
	wander = TRUE
	harm_intent_damage = 5
	minbodytemp = 0
	maxbodytemp = 500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_damage_type = BRUTE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	attacktext = "shocks"
	attack_sound = 'sound/effects/empulse.ogg'
	friendly = "pinches"
	speed = 0
	faction = list("flock")
	AIStatus = AI_OFF
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	ranged = TRUE
	projectiletype = /obj/item/projectile/beam/disabler/flock
	ranged_cooldown_time = 15
	projectilesound = 'sound/weapons/laser.ogg'
	deathmessage = "explodes with a sharp pop!"
	light_color = LIGHT_COLOR_CYAN
	speech_span = SPAN_ROBOT
	var/resources = 0
	var/max_resources = 100

/mob/living/simple_animal/hostile/flockdrone/OpenFire(atom/A)
	if(!ismecha(A) && !isliving(A) && !mind)
		return 
	. = ..()

/mob/living/simple_animal/hostile/flockdrone/Shoot(atom/targeted_atom)
	if(mind)
		return ..()
	if(!ishuman(targeted_atom) && !ismonkey(targeted_atom))
		projectiletype = /obj/item/projectile/beam/flock
	else
		var/mob/living/carbon/C = targeted_atom
		if(HAS_TRAIT(C, TRAIT_STUNIMMUNE) || HAS_TRAIT(C, TRAIT_STUNRESISTANCE))
			projectiletype = /obj/item/projectile/beam/flock
		else
			projectiletype = initial(projectiletype)
			
	return ..()

/obj/item/projectile/beam/disabler/flock
	name = "flock disabler"
	damage = 25

/obj/item/projectile/beam/flock
	name = "flock laser"
	damage = 15