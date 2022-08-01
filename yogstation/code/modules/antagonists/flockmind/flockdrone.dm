/mob/living/simple_animal/hostile/flockdrone
	name = "flock drone"
	desc = "A weird glowy thing."
	speak_emote = list("tones")
	initial_language_holder = /datum/language_holder/flock
	bubble_icon = "swarmer"
	mob_biotypes = MOB_ROBOTIC
	health = 40
	maxHealth = 40
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	status_flags = CANPUSH
	icon_state = "swarmer"
	icon_living = "swarmer"
	icon_dead = "swarmer_unactivated"
	icon_gib = null
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
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
	hud_type = /datum/hud/living/swarmer
	wanted_objects = list(/obj/item)
	unwanted_objects = list(/obj/item/disk/nuclear) //We don't want to eat dat fukken disk
	search_objects = 1
	var/resources = 0
	var/max_resources = 100
	var/murderer = FALSE
	var/mob/camera/flocktrace/pilot

/mob/living/simple_animal/hostile/flockdrone/Initialize()
	. = ..()
	new /obj/item/radio/headset/silicon/ai(src)

/mob/living/simple_animal/hostile/flockdrone/OpenFire(atom/A)
	if(!ismecha(A) && !isliving(A) && !mind)
		return 
	if(a_intent == INTENT_HELP)
		projectiletype = /obj/item/projectile/beam/disabler/flock
	else 
		projectiletype = /obj/item/projectile/beam/flock
	. = ..()

/mob/living/simple_animal/hostile/flockdrone/Shoot(atom/targeted_atom)
	if(mind)
		return ..()
	if(ishuman(targeted_atom) || ismonkey(targeted_atom))  //If the target is a stunable monke/human, we try to shoot it down with a disabler. If it isn't stunable, we shoot it to death
		var/mob/living/carbon/C = targeted_atom
		if(HAS_TRAIT(C, TRAIT_STUNIMMUNE) || HAS_TRAIT(C, TRAIT_STUNRESISTANCE))
			a_intent_change(INTENT_HARM)
		else
			a_intent_change(INTENT_HELP)

	else if(ismecha(targeted_atom) || isliving(targeted_atom)) //If the target is a mech or a non-human/monke, we KILL IT
		a_intent_change(INTENT_HARM)

	return ..()

/mob/living/simple_animal/hostile/flockdrone/AttackingTarget()
	if(isitem(target))
		target.flock_act(src)
		return
	else if(isliving(target) || !mind)
		var/mob/living/L = target
		if(L.stat == DEAD)
			if(!mind || isflockdrone(L))
				L.flock_act()
		else if(!mind)
			if(L.IsStun() || L.IsImmobilized() || L.IsParalyzed() || L.IsUnconscious() || L.IsSleeping() || isflockdrone(L))
				L.flock_act()
				return
			else if(ishuman(L) || ismonkey(L))
				if(HAS_TRAIT(L, TRAIT_STUNIMMUNE) || HAS_TRAIT(L, TRAIT_STUNRESISTANCE))
					a_intent_change(INTENT_HARM)
				else 
					a_intent_change(INTENT_HELP)
	if(a_intent == INTENT_HELP)
		melee_damage_type = STAMINA
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
	change_resources(resource_gain)
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

/mob/living/simple_animal/hostile/flockdrone/toggle_move_intent(mob/user)
	. = ..()
	to_chat(user, span_notice("You are now able to move through feather walls."))

/mob/living/simple_animal/hostile/flockdrone/Bump(atom/AM)
	. = ..()
	if(istype(AM, /turf/closed/wall/feather) && AM != loc && m_intent == MOVE_INTENT_WALK) 
		var/atom/movable/stored_pulling = pulling
		if(stored_pulling)
			stored_pulling.setDir(get_dir(stored_pulling.loc, loc))
			stored_pulling.forceMove(loc)
		forceMove(AM)
		if(stored_pulling)
			start_pulling(stored_pulling, supress_message = TRUE) 

/mob/living/simple_animal/hostile/flockdrone/proc/change_resources(var/amount, silent = FALSE)
	if(resources >= max_resources)
		if(!silent )
			to_chat(src, span_warning("You gain [amount] resources, but your storage is full!"))
		return
	resources += amount
	if(resources > max_resources)
		if(!silent )
			to_chat(src, span_warning("You gain [amount] resources, but [resources - max_resources] of them don't fit in your storage!"))
		resources = max_resources
	else if(resources < 0)
		resources = 0
	else if(amount >= 0)
		if(!silent )
			to_chat(src, span_notice("You gain [amount] resources."))
	else 
		if(!silent )
			to_chat(src, span_notice("You spend [amount] resources."))
	if(hud_used && istype(hud_used, /datum/hud/living/flock))
		var/datum/hud/living/flock/flockhud = hud_used
		flockhud.resources.update_counter(resources)

/mob/living/simple_animal/hostile/flockdrone/AltClickOn(atom/target)
	. = ..()
	if(.)
		target.flock_act(src)

/mob/living/simple_animal/hostile/flockdrone/proc/repair(mob/living/simple_animal/hostile/flockdrone/user)
	if(stat == DEAD)
		return
	if(health >= maxHealth)
		visible_message(span_notice("[user] finishes repairing [user == src ? "itself" : src]!"), \
				span_notice("[user == src ? "You finish" : "[user] finishes"] repairing [user == src ? "yourself" : src]!"))
		return
	if(user.resources < 10)
		to_chat(user, span_notice("You don't have enough resources to repair [user == src ? "yourself" : src] further."))
		return
	if(!do_mob(drone, src, 1 SECONDS))
		return
	if(getBruteLoss())
		adjustBruteLoss(10)
	else if(getFireLoss())
		adjustFireLoss(10)
	visible_message(span_notice("[user] fixes some damage on [user == src ? "itself" : src]!"), \
			span_notice("[user == src ? "You fix" : "[user] fixes"] some damage on [user == src ? "yourself" : src]!"))
	user.change_resources(-10, TRUE)
	repair(user)

/obj/item/projectile/beam/disabler/flock
	name = "flock disabler"
	damage = 25

/obj/item/projectile/beam/flock
	name = "flock laser"
	damage = 15

//////////////////////////////////////////////
//                                          //
//                PILOTING                  //
//                                          //
//////////////////////////////////////////////

/mob/living/simple_animal/hostile/flockdrone/attack_flocktrace(mob/camera/flocktrace/user, var/list/modifiers)
	if(!user.client)
		return
	if(mind)
		if(!pilot)
			return
		if(!isflockmind(user))
			to_chat(user, span_warning("[src] is already piloted!"))
			return
		else
			if(isflockmind(pilot))
				return
			var/confirmation = input(user,"Do you want to posses an already controled drone? The current pilot will be ejected.","Confiramtion") in list("Yes", "No")
			if(confirmation == "No")
				return
			EjectPilot()
			Posses(user)
		return
	else
		var/confirmation = input(user,"Do you want to posses [src]?","Confiramtion") in list("Yes", "No")
		if(confirmation == "No")
			return
		Posses(user)


/mob/living/simple_animal/hostile/flockdrone/proc/EjectPilot()
	if(!pilot)
		return
	mind.transfer_to(pilot)
	var/turf/location = get_turf(src)
	if(location && istype(location))
		pilot.forceMove(location)
	else
		pilot.forceMove(loc)
	mind.transfer_to(pilot)
	pilot = null
	if(AIStatus == AI_ON)
		toggle_ai()

/mob/living/simple_animal/hostile/flockdrone/proc/Posses(mob/user)
	if(!user)
		return
	if(pilot || mind)
		return
	user.forceMove(src)
	user.mind.transfer_to(src)
	pilot = user
	if(AIStatus != AI_ON)
		toggle_ai()
	
/mob/living/simple_animal/hostile/flockdrone/death(gibbed)
	EjectPilot()
	. = ..()