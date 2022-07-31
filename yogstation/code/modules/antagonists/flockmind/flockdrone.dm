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
	harm_intent_damage = 10
	minbodytemp = 0
	maxbodytemp = 500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	melee_damage_lower = 10
	melee_damage_upper = 10
	melee_damage_type = BRUTE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	attacktext = "shocks"
	attack_sound = 'sound/effects/empulse.ogg'
	friendly = "pinches"
	speed = 0
	faction = list("flock")
	AIStatus = AI_ON
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
	var/mob/camera/flockcontroler

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

/mob/living/simple_animal/hostile/flockdrone/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD || L.IsStun() || L.IsImmobilized() || L.IsParalyzed() || L.IsUnconscious() || L.IsSleeping())
			CageOrDeconstruct(L)
			return
		else if(ishuman(L) || ismonkey(L))
			if(HAS_TRAIT(L, TRAIT_STUNIMMUNE) || HAS_TRAIT(L, TRAIT_STUNRESISTANCE))
				melee_damage_type = BRUTE
			else 
				melee_damage_type = initial(melee_damage_type)
	. = ..()
	if(. && isliving(target)) //We deal bonus 5 brute damage to living/alive targets. Always.
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor = run_armor_check(affecting, MELEE, armour_penetration = src.armour_penetration)
		apply_damage(5, BRUTE, affecting, armor)

/mob/living/simple_animal/hostile/flockdrone/proc/CageOrDeconstruct(mob/living/L)
	return

/obj/item/projectile/beam/disabler/flock
	name = "flock disabler"
	damage = 25

/obj/item/projectile/beam/flock
	name = "flock laser"
	damage = 15