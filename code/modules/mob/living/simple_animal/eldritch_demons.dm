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
	// Sort of greenish brown, to match the vibeTM
	lighting_cutoff_red = 20
	lighting_cutoff_green = 25
	lighting_cutoff_blue = 5
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

/mob/living/simple_animal/hostile/eldritch/Initialize(mapload)
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

/mob/living/simple_animal/hostile/eldritch/raw_prophet/Initialize(mapload)
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
				if(!(bodypart.body_part & HEAD|CHEST|LEG_LEFT|LEG_RIGHT))
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

/mob/living/simple_animal/hostile/eldritch/rust_spirit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_RUST)

/mob/living/simple_animal/hostile/eldritch/rust_spirit/setDir(newdir)
	. = ..()
	if(newdir == NORTH)
		icon_state = "rust_walker_n"
	else if(newdir == SOUTH)
		icon_state = "rust_walker_s"
	update_appearance(UPDATE_ICON)

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

/mob/living/simple_animal/hostile/eldritch/star_gazer
	name = "Star Gazer"
	desc = "A creature that has been tasked to watch over the stars."
	icon = 'icons/mob/96x96eldritch_mobs.dmi'
	icon_state = "star_gazer"
	icon_living = "star_gazer"
	pixel_x = -32
	base_pixel_x = -32
	mob_biotypes = MOB_HUMANOID | MOB_SPECIAL
	speed = -0.2
	maxHealth = 750
	health = 750

	obj_damage = 400
	armour_penetration = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	sentience_type = SENTIENCE_BOSS
	attack_vis_effect = ATTACK_EFFECT_SLASH
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("growls")
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	deathsound = 'sound/magic/cosmic_expansion.ogg'
	loot = list(/obj/effect/temp_visual/cosmic_domain)

	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

	actions_to_add = list(
		/datum/action/cooldown/spell/conjure/cosmic_expansion/large,
		/datum/action/cooldown/spell/pointed/projectile/star_blast/ascended
	)

/mob/living/simple_animal/hostile/eldritch/star_gazer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_explosion, 3, 6, 12)
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
	AddComponent(/datum/component/regenerator, outline_colour = "#b97a5d")
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_TELEPORT, MEGAFAUNA_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	set_light(4, l_color = "#dcaa5b")

/mob/living/simple_animal/hostile/eldritch/fire_shark
	name = "Fire Shark"
	real_name = "Ignis"
	desc = "It is a eldritch dwarf space shark, also known as a fire shark."
	icon = 'icons/mob/eldritch_mobs.dmi'
	icon_state = "fire_shark"
	icon_living = "fire_shark"
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speed = -0.5
	health = 16
	maxHealth = 16
	melee_damage_lower = 8
	melee_damage_upper = 8
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attacktext = "bites"
	obj_damage = 0
	damage_coeff = list(BRUTE = 1, BURN = 0.25, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	mob_size = MOB_SIZE_TINY
	speak_emote = list("screams")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	pressure_resistance = 200
	var/poison_per_bite = 2
	var/poison_type = /datum/reagent/phlogiston
	var/death_cloud_size = 1 //size of cloud produced from a dying shark

/mob/living/simple_animal/hostile/eldritch/fire_shark/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming)
	AddComponent(/datum/component/regenerator, outline_colour = COLOR_DARK_RED)

/mob/living/simple_animal/hostile/eldritch/fire_shark/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents && poison_per_bite)
			L.reagents.add_reagent(poison_type, poison_per_bite)
	return .

/mob/living/simple_animal/hostile/eldritch/fire_shark/death(gibbed)
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect_system/fluid_spread/smoke/chem/S = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air
	create_reagents(10)
	reagents.add_reagent(/datum/reagent/toxin/plasma, 40)

	// Attach the smoke spreader and setup/start it.
	S.attach(location)
	S.set_up(death_cloud_size, location = location, carry = reagents, silent = TRUE)
	S.start()
	
	..()
