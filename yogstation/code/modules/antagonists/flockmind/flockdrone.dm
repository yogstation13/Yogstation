/mob/living/simple_animal/hostile/flockdrone
	name = "flock drone"
	desc = "A weird glowy thing."
	speak_emote = list("tones")
	initial_language_holder = /datum/language_holder/flock
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
	wanted_objects = list(/obj/item)
	unwanted_objects = list(/obj/item/disk/nuclear) //We don't want to eat dat fukken disk
	search_objects = 1
	var/resources = 0
	var/max_resources = 100
	var/murderer = FALSE
	var/mob/camera/flocktrace

/mob/living/simple_animal/hostile/flockdrone/Initialize()
	. = ..()
	var/obj/item/radio/headset/silicon/ai/radio = new(src)

/mob/living/simple_animal/hostile/flockdrone/OpenFire(atom/A)
	if(!ismecha(A) && !isliving(A) && !mind)
		return 
	. = ..()

/mob/living/simple_animal/hostile/flockdrone/Shoot(atom/targeted_atom)
	if(mind)
		return ..()
	if(ishuman(targeted_atom) || ismonkey(targeted_atom))  //If the target is a stunable monke/human, we try to shoot it down with a disabler. If it isn't stunable, we shoot it to death
		var/mob/living/carbon/C = targeted_atom
		if(HAS_TRAIT(C, TRAIT_STUNIMMUNE) || HAS_TRAIT(C, TRAIT_STUNRESISTANCE))
			set_murdering(TRUE)
		else
			set_murdering(FALSE)

	else if(ismecha(targeted_atom) || isliving(targeted_atom)) //If the target is a mech or a non-human/monke, we KILL IT
		set_murdering(TRUE)

	return ..()

/mob/living/simple_animal/hostile/flockdrone/AttackingTarget()
	if(isitem(target))
		target.flock_act(src)
		return
	else if(isliving(target) || !mind)
		var/mob/living/L = target
		if(L.stat == DEAD || L.IsStun() || L.IsImmobilized() || L.IsParalyzed() || L.IsUnconscious() || L.IsSleeping())
			L.flock_act(src) //We place them in a cage or just recycle if a simplemob/silicon
			return
		else if(ishuman(L) || ismonkey(L))
			if(HAS_TRAIT(L, TRAIT_STUNIMMUNE) || HAS_TRAIT(L, TRAIT_STUNRESISTANCE))
				set_murdering(TRUE)
			else 
				set_murdering(FALSE)
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

/mob/living/simple_animal/hostile/flockdrone/get_status_tab_items()
	. = ..()
	. += "Resources: [resources]/[max_resources]"

/mob/living/simple_animal/hostile/flockdrone/CanAllowThrough(atom/movable/O)
	. = ..()
	if(istype(O, /obj/item/projectile/beam/disabler/flock) || istype(O, /obj/item/projectile/beam/flock))//Allows for swarmers to fight as a group without wasting their shots hitting each other
		return TRUE
	if(isflockdrone(O))
		return TRUE

/mob/living/simple_animal/hostile/flockdrone/Life(seconds, times_fired)
	. = ..()
	if(!mind && !client && (resources > 20)) //The drone will try to convert tiles around it if not player-controlled.
		for(var/tile in spiral_range_turfs(1, src))
			var/turf/T = tile
			if(!T || !isturf(loc))
				continue
			if(get_dist(T, src) <= 1)
				if(prob(25))
					flock_act(src)
					if(prob(50))
						break

/mob/living/simple_animal/hostile/flockdrone/proc/Eat(obj/item/target)
	var/resource_gain = target.integrate_amount()
	if(resources + resource_gain > max_resources)
		to_chat(src, span_warning("You cannot hold more materials!"))
		return TRUE
	if(!resource_gain)
		to_chat(src, span_warning("You cannot recycle this."))
		return FALSE
	resources += resource_gain
	do_attack_animation(target)
	changeNext_move(CLICK_CD_RAPID)
	var/obj/effect/temp_visual/swarmer/integrate/I = new /obj/effect/temp_visual/swarmer/integrate(get_turf(target))
	I.pixel_x = target.pixel_x
	I.pixel_y = target.pixel_y
	I.pixel_z = target.pixel_z
	if(istype(target, /obj/item/stack))
		var/obj/item/stack/S = target
		S.use(1)
		if(S.amount)
			return TRUE
	qdel(target)
	return TRUE

/mob/living/simple_animal/hostile/flockdrone/proc/set_murdering(true_or_false = TRUE)
	murderer = true_or_false
	if(murderer)
		melee_damage_type = BRUTE
		projectiletype = /obj/item/projectile/beam/flock
	else
		melee_damage_type = STAMINA
		projectiletype = /obj/item/projectile/beam/disabler/flock

/obj/item/projectile/beam/disabler/flock
	name = "flock disabler"
	damage = 25

/obj/item/projectile/beam/flock
	name = "flock laser"
	damage = 15