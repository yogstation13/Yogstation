/obj/item/zombie_hand
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/obj/zombie.dmi'
	icon_state = "blood_hand_l"
	var/icon_left = "blood_hand_l"
	var/icon_right = "blood_hand_r"
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21 // Just enough to break airlocks with melee attacks
	sharpness = SHARP_EDGED
	wound_bonus = -30
	bare_wound_bonus = 15
	damtype = "brute"
	var/inserted_organ = /obj/item/organ/zombie_infection
	var/infect_chance = 100 //Before armor calculations
	var/scaled_infect_chance = FALSE //Do we use steeper armor infection block chance or linear?

/obj/item/zombie_hand/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/zombie_hand/ComponentInitialize()
	AddComponent(/datum/component/zombie_infection, scaled_infect_chance, infect_chance, inserted_organ)

/obj/item/zombie_hand/equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = icon_left
	else
		icon_state = icon_right

/obj/item/zombie_hand/attack(mob/living/M, mob/living/user)//overrides attack command to allow blocking of zombie claw to prevent infection
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)
	if(item_flags & NOBLUDGEON)
		return

	//"uh yes, i only eat vegan brain alternatives" Get out of here with that pacifism bullshit!

	//only the finest brain surgery tool, doesn't even need to check for surgical

	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey
	if(force)
		M.last_damage = name
	user.do_attack_animation(M)
	var/blocked = M.attacked_by(src, user)

	log_combat(user, M, "attacked", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)

	take_damage(rand(weapon_stats[DAMAGE_LOW], weapon_stats[DAMAGE_HIGH]), sound_effect = FALSE)

	if(blocked)
		return

/proc/try_to_zombie_infect(mob/living/carbon/human/target, organ)
	CHECK_DNA_AND_SPECIES(target)

	if(NOZOMBIE in target.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning
		// zombies)
		return

	var/obj/item/organ/zombie_infection/infection
	infection = target.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new organ()
		infection.Insert(target)



/obj/item/zombie_hand/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(isliving(user))
		var/mob/living/L = user
		var/obj/item/bodypart/O = L.get_bodypart(BODY_ZONE_HEAD)
		if(O)
			O.dismember()
	return (BRUTELOSS)

/obj/item/zombie_hand/gamemode
	desc = "A zombie's claw is its primary tool, capable of infecting \n\
			humans, butchering all other living things to \n\
			sustain the zombie, smashing open airlock doors and opening \n\
			child-safe caps on bottles."
	inserted_organ = /obj/item/organ/zombie_infection/gamemode
	///See code\modules\mob\living\carbon\human\species_types\zombies.dm
	infect_chance = 0
	force = 15
	var/door_open_modifier = 1

/obj/item/zombie_hand/gamemode/examine()
	. = ..()
	if(!isliving(loc))
		return
	var/mob/living/holder = loc
	if(IS_SPECIALINFECTED(holder))
		. += span_boldnotice("You can release spores into people with <font size 4>Alt-click</font>, infecting them.")

/obj/item/zombie_hand/gamemode/runner
	force = 10
	door_open_modifier = 1.5

/obj/item/zombie_hand/gamemode/runner/afterattack(atom/target, mob/user, proximity) //sharp bone and stuff
	. = ..()
	if(!proximity)
		return

	if(!isliving(target))
		return

	var/mob/living/victim = target
	var/datum/status_effect/saw_bleed/bloodletting/bleed_stack = victim.has_status_effect(STATUS_EFFECT_BLOODLETTING)
	if(!bleed_stack)
		bleed_stack = victim.apply_status_effect(STATUS_EFFECT_BLOODLETTING)
	else
		bleed_stack.add_bleed(2) //5 times

/obj/item/zombie_hand/gamemode/necro
	force = 7
	infect_chance = 30

/obj/item/zombie_hand/gamemode/tank // see /obj/item/melee/flesh_maul
	name = "zombie maul"
	desc = "A marvelous show of craftsmanship.\n\
			Made from your host's other appendages, this monster of a claw is sturdy but also very able."
	icon_state = "jugger_hand"
	icon_left = "jugger_hand"
	icon_right = "jugger_stub"
	lefthand_file = 'icons/mob/inhands/antag/zombie_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/zombie_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	tool_behaviour = TOOL_MINING
	weapon_stats = list(SWING_SPEED = 2, ENCUMBRANCE = 1, ENCUMBRANCE_TIME = 20, REACH = 2, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	force = 30
	armour_penetration = -20
	wound_bonus = 30
	hitsound = "swing_hit"
	attack_verb = list("smashed", "slammed", "crushed", "whacked")
	sharpness = SHARP_NONE
	var/is_stub = FALSE
	var/defensive_mode = FALSE
	door_open_modifier = 0.5

/obj/item/zombie_hand/gamemode/tank/examine()
	. = ..()
	if(is_stub)
		. = "A remnant of what once was a feeble arm remains. Though its sacrifice wasn't in vain."
		return
	. += span_bold("It is currently on [defensive_mode ? "defense, defending your upper body from damage, but also slowing you down." : "offense, reducing your protection but allowing more movement."]")

/obj/item/zombie_hand/gamemode/tank/equipped(mob/user)
	. = ..()
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		return
	var/obj/item/zombie_hand/gamemode/tank/stub = src
	stub.name = "zombie stub"
	stub.is_stub = TRUE
	stub.force = 5
	stub.armour_penetration = 30
	stub.weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	stub.w_class = WEIGHT_CLASS_SMALL
	stub.tool_behaviour = NONE

/obj/item/zombie_hand/gamemode/tank/afterattack(atom/target, mob/user, proximity)	
	. = ..()
	if(!proximity)
		return
	
	if(is_stub)
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.add_movespeed_modifier("zombie maul", update = TRUE, priority = 101, multiplicative_slowdown = 1)
		addtimer(CALLBACK(C, /mob.proc/remove_movespeed_modifier, "zombie maul"), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)	
		to_chat(target, span_danger("You are staggered from the blow!"))

	if(iscyborg(target))
		var/mob/living/silicon/robot/R = target
		R.Paralyze(1 SECONDS)

	if(isstructure(target) || ismachinery(target))	
		var/obj/structure/S = target
		var/structure_damage = S.max_integrity		
		var/make_sound = TRUE
		if(istype(target, /obj/structure/window) || istype(target, /obj/structure/grille))
			structure_damage *= 2
			make_sound = FALSE
		if(ismachinery(target) || istype(target, /obj/structure/door_assembly))
			structure_damage *= 0.5
		if(istype(target, /obj/machinery/door/airlock))
			structure_damage = 29
		if(istype(target, /obj/structure/table))
			var/obj/structure/table/T = target
			T.deconstruct(FALSE)
			return
		if(!isnull(target))
			S.take_damage(structure_damage, BRUTE, MELEE, FALSE)
		if(make_sound)
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/item/zombie_hand/gamemode/tank/attack_self(mob/user)
	. = ..()
	if(is_stub)
		return

	var/mob/living/carbon/human/zombie = user
	var/datum/antagonist/zombie/zombie_owner = user.mind?.has_antag_datum(/datum/antagonist/zombie)
	defensive_mode = !defensive_mode
	if(defensive_mode)
		var/damage_mod = 0.75
		if(locate("strong_arm") in zombie_owner.zombie_abilities)
			damage_mod = 0.6
		zombie.physiology.brute_mod = damage_mod
		zombie.physiology.burn_mod = damage_mod
		zombie.add_movespeed_modifier("zombie defense", update = TRUE, priority = 101, multiplicative_slowdown = 1)
	else
		zombie.physiology.brute_mod = initial(zombie.physiology.brute_mod)	
		zombie.physiology.burn_mod = initial(zombie.physiology.burn_mod)
		zombie.remove_movespeed_modifier("zombie defense")
	update_icon()

/obj/item/zombie_hand/gamemode/tank/update_icon()
	if(is_stub)
		return
	icon_state = defensive_mode ? "jugger_hand_d" : initial(icon_state)

/obj/effect/ebeam/smokertongue
	name = "rotten tongue"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "A gross, slimy tongue. It's sticky to the touch."

/obj/effect/ebeam/smokertongue/stickier/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		L.Paralyze(1 SECONDS)

/obj/effect/ebeam/smokertongue/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM			
		if(isinfectedzombie(L))
			return
		L.Paralyze(1.5 SECONDS)
		to_chat(L, span_warning("You get caught in the smoker's tongue!"))

/obj/item/zombie_hand/gamemode/smoker
	desc = "The smoker's claw has an unique ability to incapacitate targets, \
		clicking on a far away mob will tongue them and bring them closer to you slowly. \
		You can't damage someone until you fully incapacitate then, \
		but you deal more damage and can quickly tear someone down."
	force = 25
	var/datum/beam/tongue = null
	var/tongue_range = 6
	var/obj/item/zombie_hand/gamemode/smoker/sister_hand = null

/obj/item/zombie_hand/gamemode/smoker/Initialize()
	. = ..()
	for(var/obj/item/zombie_hand/gamemode/smoker/S in loc)
		if(S != src)
			sister_hand = S
			S.sister_hand = src

/obj/item/zombie_hand/gamemode/smoker/attack(mob/living/target, mob/living/user)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.getStaminaLoss() >= 100)
			damtype = BRUTE
		else
			damtype = STAMINA //choke them out, please
	else
		damtype = BRUTE
	. = ..()

/obj/item/zombie_hand/gamemode/smoker/afterattack(atom/target, mob/user, proximity)	
	if(proximity || tongue)
		return ..()
	if(iscarbon(target))
		var/datum/antagonist/zombie/zombie_owner = user?.mind?.has_antag_datum(/datum/antagonist/zombie)
		if(zombie_owner.zombie_mutations["big_tongue"])
			tongue_range = initial(tongue_range) + 2
		tongue = user.Beam(target, "smokertongue", time = INFINITY, maxdistance = tongue_range, beam_type = \
			(zombie_owner.zombie_mutations["stickier_tongue"]) ? /obj/effect/ebeam/smokertongue/stickier : /obj/effect/ebeam/smokertongue)
		sister_hand?.tongue = TRUE //only one tongue! //i messed up
		RegisterSignal(user, COMSIG_LIVING_BIOLOGICAL_LIFE, .proc/pull_tongue_to, TRUE)

/obj/item/zombie_hand/gamemode/smoker/proc/pull_tongue_to()
	if(!tongue?.target && !tongue?.origin)
		QDEL_NULL(tongue)
		return
	if(istype(tongue.target, /atom/movable))
		var/atom/movable/AM = tongue.target
		if(!AM.anchored)
			step(AM, get_dir(AM, tongue.origin))
	if(get_dist(tongue.origin, tongue.target) <= 1)
		QDEL_NULL(tongue)

/obj/item/zombie_hand/gamemode/spitter
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles." ///// <-------------------------
	icon_state = "spitter_hand_l_on"
	icon_left = "spitter_hand_l_on"
	icon_right = "spitter_hand_r_on"
	COOLDOWN_DECLARE(acid_splatter_cooldown)
	var/cooldown = 30 SECONDS

/obj/item/zombie_hand/gamemode/spitter/examine()
	. = ..()
	. += COOLDOWN_FINISHED(src, acid_splatter_cooldown) ? span_notice("It is dripping with acid!") : span_warning("Requires [COOLDOWN_TIMELEFT(src, acid_splatter_cooldown) / 10] more seconds to refill.")

/obj/item/zombie_hand/gamemode/spitter/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(!COOLDOWN_FINISHED(src, acid_splatter_cooldown))
		return

	if(isclosedturf(target) || isobj(target))
		var/acid_ratio_to_use = 250
		var/datum/antagonist/zombie/zombie_owner = user.mind?.has_antag_datum(/datum/antagonist/zombie)
		if(zombie_owner.zombie_mutations["stronger_acid"])
			acid_ratio_to_use = 300
		if(!target.acid_act(acid_ratio_to_use, 150))
			to_chat(user, span_warning("You can't dissolve [target]."))
			return
		user.visible_message(span_danger("[user] smears acid onto [target], causing it to melt!"))
		COOLDOWN_START(src, acid_splatter_cooldown, cooldown)
		addtimer(CALLBACK(src, .proc/on_cooldown_end, user), cooldown)
		update_icon(user)

/obj/item/zombie_hand/gamemode/spitter/update_icon(mob/user)
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = acid_splatter_cooldown <= world.time ? initial(icon_left) : "spitter_hand_l"  // o
	else																						   //  )
		icon_state = acid_splatter_cooldown <= world.time ? initial(icon_right) : "spitter_hand_r" // o

/obj/item/zombie_hand/gamemode/spitter/proc/on_cooldown_end(mob/user)
	update_icon(user)
	to_chat(user, span_notice("Acid drips down your fingertips, you are ready to melt something again!"))

/obj/item/gun/brainy //where we go crazy
	name = "pulsating mass"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles." //// <------------------------
	item_flags = DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/obj/zombie.dmi'
	lefthand_file = 'icons/mob/inhands/antag/zombie_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/zombie_righthand.dmi'
	icon_state = "mass"
	item_state = "mass"
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21
	sharpness = SHARP_EDGED
	wound_bonus = -30
	bare_wound_bonus = 15
	damtype = BRUTE
	pin = null
	no_pin_required = TRUE
	var/obj/item/gun/current_copy = null

/obj/item/gun/brainy/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/gun/brainy/ComponentInitialize()
	AddComponent(/datum/component/zombie_infection, FALSE, 0, /obj/item/organ/zombie_infection/gamemode)

/obj/item/gun/brainy/equipped(mob/user, slot)
	. = ..()
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = initial(icon_state) + !(i % 2) ? "_l" : "_r"

/obj/item/gun/brainy/proc/mimic(obj/item/gun/target)
	if(!target)
		reset()
		return
	current_copy = new target.type(loc)
	fire_sound = target.fire_sound
	vary_fire_sound = target.vary_fire_sound
	fire_sound_volume = target.fire_sound_volume
	dry_fire_sound = target.dry_fire_sound
	update_icon()

/obj/item/gun/brainy/proc/reset()
	QDEL_NULL(current_copy)
	fire_sound = initial(fire_sound)
	vary_fire_sound = initial(vary_fire_sound)
	fire_sound_volume = initial(fire_sound_volume)
	dry_fire_sound = initial(dry_fire_sound)
	update_icon()

/obj/item/gun/brainy/update_icon()
	icon_state = initial(icon_state)
	if(!current_copy)
		return
	if(istype(current_copy, /obj/item/gun/energy))
		icon_state = initial(icon_state) + "_laser"
	if(istype(current_copy, /obj/item/gun/ballistic))
		icon_state = initial(icon_state) + "_ballistic"

/obj/item/gun/brainy/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!user.mind?.has_antag_datum(/datum/antagonist/zombie))
		to_chat(user, span_warning("You have no idea how this works."))
		// REMEMBER TO ADD RETURN
	var/datum/antagonist/zombie/zombie_owner = user.mind.has_antag_datum(/datum/antagonist/zombie)
	if(!zombie_owner.manage_infection(5))
		to_chat(user, span_warning("You don't have enough points to fire this!"))
		return
	return current_copy?.process_fire(target, user, TRUE, null, "", 0)

/obj/item/gun/brainy/process_chamber()
	if(ismob(loc))
		var/mob/M = loc
		if(M?.mind?.has_antag_datum(/datum/antagonist/zombie))
			var/datum/antagonist/zombie/zombie_owner = M.mind.has_antag_datum(/datum/antagonist/zombie)
			zombie_owner?.infection -= 5
	return current_copy?.process_chamber()
