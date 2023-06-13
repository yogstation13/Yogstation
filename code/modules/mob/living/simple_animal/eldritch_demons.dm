/mob/living/simple_animal/hostile/eldritch
	name = "Demon"
	real_name = "Demon"
	desc = ""
	gender = NEUTER
	mob_biotypes = NONE
	speak_emote = list("screams")
	response_help = "thinks better of touching"
	response_disarm = "flails at"
	attacktext = "tears"
	speak_chance = 1
	icon = 'icons/mob/eldritch_mobs.dmi'
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	AIStatus = AI_OFF
	attack_sound = 'sound/weapons/punch1.ogg'
	see_in_dark = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	healable = 0
	movement_type = GROUND
	pressure_resistance = 100
	del_on_death = TRUE
	deathmessage = "implodes into itself"
	faction = list("heretics")
	//simple_mob_flags = SILENCE_RANGED_MESSAGE

	///Innate spells that are supposed to be added when a beast is created
	var/list/actions_to_add

/mob/living/simple_animal/hostile/eldritch/Initialize()
	. = ..()
	for(var/spell in actions_to_add)
		var/datum/action/cooldown/spell/new_spell = new spell(src)
		new_spell.Grant(src)

/mob/living/simple_animal/hostile/eldritch/raw_prophet
	name = "Raw Prophet"
	real_name = "Raw Prophet"
	desc = "An eye supported by a mass of severed limbs. It has a piercing gaze."
	icon_state = "raw_prophet"
	status_flags = CANPUSH
	icon_living = "raw_prophet"
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 50
	health = 50
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	actions_to_add = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/long,
		/datum/action/cooldown/spell/list_target/telepathy/eldritch,
		/datum/action/cooldown/spell/pointed/blind/eldritch,
		/datum/action/innate/expand_sight,
	)

	/// A weakref to the last target we smacked. Hitting targets consecutively does more damage.
	var/datum/weakref/last_target

/mob/living/simple_animal/hostile/eldritch/raw_prophet/Initialize()
	. = ..()
	var/on_link_message = "You feel something new enter your sphere of mind... \
		You hear whispers of people far away, screeches of horror and a huming of welcome to [src]'s Mansus Link."

	var/on_unlink_message = "Your mind shatters as [src]'s Mansus Link leaves your mind."

	AddComponent(/datum/component/mind_linker, \
		network_name = "Mansus Link", \
		chat_color = "#568b00", \
		linker_action_path = /datum/action/cooldown/spell/pointed/manse_link, \
		link_message = on_link_message, \
		unlink_message = on_unlink_message, \
		post_unlink_callback = CALLBACK(src, PROC_REF(after_unlink)), \
		speech_action_background_icon_state = "bg_heretic", \
	)

/mob/living/simple_animal/hostile/eldritch/raw_prophet/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(user == src) // Easy to hit yourself + very fragile = accidental suicide, prevent that
		return

	return ..()

/mob/living/simple_animal/hostile/eldritch/raw_prophet/AttackingTarget(atom/attacked_target)
	if(WEAKREF(attacked_target) == last_target)
		melee_damage_lower = min(melee_damage_lower + 5, 30)
		melee_damage_upper = min(melee_damage_upper + 5, 35)
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)

	. = ..()
	if(!.)
		return

	SpinAnimation(5, 1)
	last_target = WEAKREF(attacked_target)

/mob/living/simple_animal/hostile/eldritch/raw_prophet/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/rotation_degree = (360 / 3)
	if(movement_dir & WEST || movement_dir & SOUTH)
		rotation_degree *= -1

	var/matrix/to_turn = matrix(transform)
	to_turn = turn(transform, rotation_degree)
	animate(src, transform = to_turn, time = 0.1 SECONDS)

/mob/living/simple_animal/hostile/eldritch/raw_prophet/proc/after_unlink(mob/living/unlinked_mob)
	if(QDELETED(unlinked_mob) || unlinked_mob.stat == DEAD)
		return

	INVOKE_ASYNC(unlinked_mob, TYPE_PROC_REF(/mob, emote), "scream")
	unlinked_mob.AdjustParalyzed(0.5 SECONDS) //micro stun

/mob/living/simple_animal/hostile/eldritch/armsy
	name = "Lavish Serpent"
	real_name = "Waning Devourer"
	desc = "A horrid abomination made from severed limbs."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	move_resist = MOVE_FORCE_OVERPOWERING+1
	movement_type = GROUND
	actions_to_add = list(/datum/action/cooldown/spell/worm_contract)
	ranged_cooldown_time = 5
	ranged = TRUE
	rapid = 1
	///Previous segment in the chain
	var/mob/living/simple_animal/hostile/eldritch/armsy/back
	///Next segment in the chain
	var/mob/living/simple_animal/hostile/eldritch/armsy/front
	///Your old location
	var/oldloc
	///Allow / disallow pulling
	var/allow_pulling = FALSE
	///How many arms do we have to eat to expand?
	var/stacks_to_grow = 5
	///Currently eaten arms
	var/current_stacks = 0

//I tried Initalize but it didnt work, like at all. This proc just wouldnt fire if it was Initalize instead of New
/mob/living/simple_animal/hostile/eldritch/armsy/Initialize(mapload,spawn_more = TRUE,len = 6)
	. = ..()
	if(len < 3)
		stack_trace("Eldritch Armsy created with invalid len ([len]). Reverting to 3.")
		len = 3 //code breaks below 3, let's just not allow it.
	oldloc = loc
	RegisterSignal(src,COMSIG_MOVABLE_MOVED, PROC_REF(update_chain_links))
	if(!spawn_more)
		return
	allow_pulling = TRUE
	///next link
	var/mob/living/simple_animal/hostile/eldritch/armsy/next
	///previous link
	var/mob/living/simple_animal/hostile/eldritch/armsy/prev
	///current link
	var/mob/living/simple_animal/hostile/eldritch/armsy/current
	for(var/i in 0 to len)
		prev = current
		//i tried using switch, but byond is really fucky and it didnt work as intended. Im sorry
		if(i == 0)
			current = new type(drop_location(),FALSE)
			current.icon_state = "armsy_mid"
			current.icon_living = "armsy_mid"
			current.front = src
			current.AIStatus = AI_OFF
			back = current
		else if(i < len)
			current = new type(drop_location(),FALSE)
			prev.back = current
			prev.icon_state = "armsy_mid"
			prev.icon_living = "armsy_mid"
			prev.front = next
			prev.AIStatus = AI_OFF
		else
			prev.icon_state = "armsy_end"
			prev.icon_living = "armsy_end"
			prev.front = next
			prev.AIStatus = AI_OFF
		next = prev

//we are literally a vessel of otherworldly destruction, we bring our own gravity unto this plane
/mob/living/simple_animal/hostile/eldritch/armsy/has_gravity(turf/T)
	return TRUE


/mob/living/simple_animal/hostile/eldritch/armsy/can_be_pulled()
	return FALSE

///Updates chain links to force move onto a single tile
/mob/living/simple_animal/hostile/eldritch/armsy/proc/contract_next_chain_into_single_tile()
	if(back)
		back.forceMove(loc)
		back.contract_next_chain_into_single_tile()
	return

///Updates the next mob in the chain to move to our last location, fixed the worm if somehow broken.
/mob/living/simple_animal/hostile/eldritch/armsy/proc/update_chain_links()
	gib_trail()
	if(back && back.loc != oldloc)
		back.Move(oldloc)
	// self fixing properties if somehow broken
	if(front && loc != front.oldloc)
		forceMove(front.oldloc)
	oldloc = loc

/mob/living/simple_animal/hostile/eldritch/armsy/proc/gib_trail()
	if(front) // head makes gibs
		return
	var/chosen_decal = pick(typesof(/obj/effect/decal/cleanable/blood/tracks))
	var/obj/effect/decal/cleanable/blood/gibs/decal = new chosen_decal(drop_location())
	decal.setDir(dir)

/mob/living/simple_animal/hostile/eldritch/armsy/Destroy()
	if(front)
		front.icon_state = "armsy_end"
		front.icon_living = "armsy_end"
		front.back = null
	if(back)
		QDEL_NULL(back) // chain destruction baby
	return ..()

/mob/living/simple_animal/hostile/eldritch/armsy/proc/heal()
	if(health == maxHealth)
		if(QDELETED(back))
			back = null
		if(back)
			back.heal()
			return
		current_stacks++
		if(current_stacks >= stacks_to_grow)
			var/mob/living/simple_animal/hostile/eldritch/armsy/prev = new type(drop_location(),FALSE)
			icon_state = "armsy_mid"
			icon_living =  "armsy_mid"
			back = prev
			prev.icon_state = "armsy_end"
			prev.icon_living = "armsy_end"
			prev.front = src
			prev.AIStatus = AI_OFF
			current_stacks = 0

	heal_bodypart_damage(maxHealth * 0.5)

/mob/living/simple_animal/hostile/eldritch/armsy/Shoot(atom/targeted_atom)
	target = targeted_atom
	AttackingTarget()


/mob/living/simple_animal/hostile/eldritch/armsy/AttackingTarget()
	if(istype(target,/obj/item/bodypart/r_arm) || istype(target,/obj/item/bodypart/l_arm))
		heal()
		qdel(target)
		return
	if(target == back || target == front)
		return
	if(back)
		back.target = target
		back.AttackingTarget()
	if(!Adjacent(target))
		return
	do_attack_animation(target)
	//have fun
	if(istype(target,/turf/closed/wall))
		var/turf/closed/wall = target
		wall.ScrapeAway()

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(!HAS_TRAIT(C, TRAIT_NODISMEMBER))
			var/list/parts = list()
			for(var/X in C.bodyparts)
				var/obj/item/bodypart/bodypart = X
				if(bodypart.body_part != HEAD && bodypart.body_part != CHEST && bodypart.body_part != LEG_LEFT && bodypart.body_part != LEG_RIGHT)
					if(bodypart.dismemberable)
						parts += bodypart
			if(length(parts) && prob(10))
				var/obj/item/bodypart/bodypart = pick(parts)
				bodypart.dismember()

	return ..()

/mob/living/simple_animal/hostile/eldritch/armsy/prime
	name = "Thirstly Serpent"
	real_name = "Decadent Devourer"
	maxHealth = 400
	health = 400
	melee_damage_lower = 30
	melee_damage_upper = 50

/mob/living/simple_animal/hostile/eldritch/armsy/prime/Initialize(mapload,spawn_more = TRUE,len = 9)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(1.4,1.4)
	transform = matrix_transformation

/mob/living/simple_animal/hostile/eldritch/rust_spirit
	name = "Rustwalker"
	real_name = "Rusty"
	desc = "A massive skull supported by a machination of deteriorating machinery. It actively seeps life out of its environment."
	icon_state = "rust_walker_s"
	status_flags = CANPUSH
	icon_living = "rust_walker_s"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	actions_to_add = list(
		/datum/action/cooldown/spell/aoe/rust_conversion/small,
		/datum/action/cooldown/spell/basic_projectile/rust_wave/short,
	)

/mob/living/simple_animal/hostile/eldritch/rust_spirit/setDir(newdir)
    . = ..()
    if(newdir == NORTH)
        icon_state = "rust_walker_n"
    else if(newdir == SOUTH)
        icon_state = "rust_walker_s"
    //update_icon()

/mob/living/simple_animal/hostile/eldritch/rust_spirit/Moved()
	. = ..()
	playsound(src, 'sound/effects/footstep/rustystep1.ogg', 100, TRUE)

/mob/living/simple_animal/hostile/eldritch/rust_spirit/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(stat == DEAD)
		return ..()
	var/turf/T = get_turf(src)
	if(istype(T,/turf/open/floor/plating/rust))
		adjustBruteLoss(-3, FALSE)
		adjustFireLoss(-3, FALSE)
	return ..()

/mob/living/simple_animal/hostile/eldritch/ash_spirit
	name = "Ashman"
	real_name = "Ashy"
	desc = "A strange, floating mass of ash and hunger."
	icon_state = "ash_walker"
	status_flags = CANPUSH
	icon_living = "ash_walker"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	actions_to_add = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash,
		/datum/action/cooldown/spell/pointed/cleave,
		/datum/action/cooldown/spell/fire_sworn,
	)

/mob/living/simple_animal/hostile/eldritch/stalker
	name = "Stalker"
	real_name = "Stalker"
	desc = "A horrid entity made from severed limbs. Its form shifts as it moves."
	icon_state = "stalker"
	status_flags = CANPUSH
	icon_living = "stalker"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS
	actions_to_add = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash,
		/datum/action/cooldown/spell/shapeshift/eldritch,
		/datum/action/cooldown/spell/emp/eldritch,
	)
