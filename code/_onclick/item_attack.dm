
/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	var/is_right_clicking = params2list(params)[RIGHT_CLICK]

	if(tool_behaviour && (target.tool_act(user, src, tool_behaviour, params) & TOOL_ACT_MELEE_CHAIN_BLOCKING))
		return TRUE

	var/pre_attack_result
	if(is_right_clicking)
		switch(pre_attack_secondary(target, user, params))
			if(SECONDARY_ATTACK_CALL_NORMAL)
				pre_attack_result = pre_attack(target, user, params)
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				mark_target(target)
				return TRUE
			if(null)
				mark_target(target)
				CRASH("attackby_secondary must return a SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")
	else
		pre_attack_result = pre_attack(target, user, params)

	if(pre_attack_result)
		mark_target(target)
		return TRUE

	var/attackby_result
	if(is_right_clicking)
		switch(target.attackby_secondary(src, user, params))
			if(SECONDARY_ATTACK_CALL_NORMAL)
				attackby_result = target.attackby(src, user, params)
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				mark_target(target)
				return TRUE
			if(null)
				mark_target(target)
				CRASH("attackby_secondary must return a SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")
	else
		attackby_result = target.attackby(src, user, params)

	// attackby does not want afterattack to happen, or the target is gone, or the item is gone
	if(attackby_result || QDELETED(src) || QDELETED(target))
		mark_target(target)
		return TRUE

	if(is_right_clicking)
		var/after_attack_secondary_result = afterattack_secondary(target, user, TRUE, params)
		// There's no chain left to continue at this point, so CANCEL_ATTACK_CHAIN and CONTINUE_CHAIN are functionally the same.
		if(after_attack_secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || after_attack_secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
			mark_target(target)
			return TRUE

	. = afterattack(target, user, TRUE, params)
	mark_target(target)

/// Used to mark a target for the demo system during a melee attack chain, call this before return
/obj/item/proc/mark_target(atom/target)
	SSdemo.mark_dirty(src)
	if(isturf(target))
		SSdemo.mark_turf(target)
	else
		SSdemo.mark_dirty(target)

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user, modifiers)
	if(HAS_TRAIT(user, TRAIT_NOINTERACT)) //sorry no using grenades
		to_chat(user, span_notice("You can't use things!"))
		return
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user, modifiers) & COMPONENT_NO_INTERACT)
		return
	interact(user)
	SSdemo.mark_dirty(src)

/// Called when the item is in the active hand, and right-clicked. Intended for alternate or opposite functions, such as lowering reagent transfer amount. At the moment, there is no verb or hotkey.
/obj/item/proc/attack_self_secondary(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF_SECONDARY, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CALL_NORMAL

/obj/item/proc/pre_attack(atom/target, mob/living/user, params) //do stuff before attackby!
	if(SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK, target, user, params) & COMPONENT_NO_ATTACK)
		return TRUE
	return FALSE //return TRUE to avoid calling attackby after this proc does stuff

/**
 * Called on the item before it hits something, when right clicking.
 *
 * Arguments:
 * * atom/target - The atom about to be hit
 * * mob/living/user - The mob doing the htting
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/obj/item/proc/pre_attack_secondary(atom/target, mob/living/user, params)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK_SECONDARY, target, user, params)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

// No comment
/atom/proc/attackby(obj/item/attacking_item, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY, attacking_item, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/atom/proc/attackby_secondary(obj/item/weapon, mob/user, params)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY_SECONDARY, weapon, user, params)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/attackby(obj/item/I, mob/living/user, params)
	return ..() || ((obj_flags & CAN_BE_HIT) && I.attack_atom(src, user))

/mob/living/attackby(obj/item/I, mob/living/user, params)
	var/list/modifiers = params2list(params)
	for(var/datum/surgery/S in surgeries)
		if(!(mobility_flags & MOBILITY_STAND) || !S.lying_required)
			if((S.self_operable || user != src) && !user.combat_mode)
				if(S.next_step(user, modifiers))
					return TRUE
	var/dist = get_dist(src,user)
	if(..())
		return TRUE
	user.changeNext_move(CLICK_CD_MELEE * I.weapon_stats[SWING_SPEED] * (I.range_cooldown_mod ? (dist > 0 ? min(dist, I.weapon_stats[REACH]) * I.range_cooldown_mod : I.range_cooldown_mod) : 1)) //range increases attack cooldown by swing speed
	user.weapon_slow(I)
	if(user.combat_mode && stat == DEAD && (butcher_results || guaranteed_butcher_results)) //can we butcher it?
		var/datum/component/butchering/butchering = I.GetComponent(/datum/component/butchering)
		if(I.is_sharp() && !butchering)
			I.AddComponent(/datum/component/butchering, 80 * I.toolspeed) //give sharp objects butchering functionality, for consistency
			butchering = I.GetComponent(/datum/component/butchering)
		if(butchering && butchering.butchering_enabled && !HAS_TRAIT(I, TRAIT_CLEAVING))
			to_chat(user, span_notice("You begin to butcher [src]..."))
			playsound(loc, butchering.butcher_sound, 50, TRUE, -1)
			if(do_after(user, butchering.speed, src) && Adjacent(I))
				butchering.Butcher(user, src)
			return TRUE
	return I.attack(src, user, params)

/mob/living/attackby_secondary(obj/item/weapon, mob/living/user, params)
	var/result = weapon.attack_secondary(src, user, params)

	// Normal attackby updates click cooldown, so we have to make up for it
	if(result != SECONDARY_ATTACK_CALL_NORMAL)
		user.changeNext_move(CLICK_CD_MELEE)
	
	return result

/**
 * Called from [/mob/living/proc/attackby]
 *
 * Arguments:
 * * mob/living/target - The mob being hit by this item
 * * mob/living/user - The mob hitting with this item
 * * params - Click params of this attack
 */
/obj/item/proc/attack(mob/living/target, mob/living/user, params)
	var/signal_return = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, target, user, params)
	if(signal_return & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	if(signal_return & COMPONENT_SKIP_ATTACK)
		return

	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, target, user, params)
	if(item_flags & NOBLUDGEON)
		return

	if(tool_behaviour && !user.combat_mode) // checks for combat mode with surgery tool
		var/list/modifiers = params2list(params)
		if(attempt_initiate_surgery(src, target, user, modifiers))
			return TRUE
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			for(var/i in C.all_wounds)
				var/datum/wound/W = i
				if(W.try_treating(src, user))
					return TRUE
		to_chat(user, span_warning("You can't perform any surgeries on [target]'s [parse_zone(user.zone_selected)]!")) //yells at you
		return TRUE

	if(force && !synth_check(user, SYNTH_ORGANIC_HARM))
		return TRUE
	if(force && HAS_TRAIT(user, TRAIT_PACIFISM) && (damtype != STAMINA))
		to_chat(user, span_warning("You don't want to harm other living beings!"))
		return TRUE

	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	target.lastattacker = user.real_name
	target.lastattackerckey = user.ckey

	if(force)
		target.last_damage = name

	user.do_attack_animation(target)
	user.add_exp(SKILL_FITNESS, target.stat == CONSCIOUS ? force : force / 5) // attacking things that can't move isn't very good experience
	target.attacked_by(src, user)

	log_combat(user, target, "attacked", src.name, "(COMBAT MODE: [user.combat_mode ? "ON" : "OFF"]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)
	var/force_multiplier = 1
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		force_multiplier = H.physiology.force_multiplier
	
	take_damage(rand(weapon_stats[DAMAGE_LOW] * force_multiplier, weapon_stats[DAMAGE_HIGH] * force_multiplier), sound_effect = FALSE)

/// The equivalent of [/obj/item/proc/attack] but for alternate attacks, AKA right clicking
/obj/item/proc/attack_secondary(mob/living/victim, mob/living/user, params)
	return SECONDARY_ATTACK_CALL_NORMAL

//the equivalent of the standard version of attack() but for non-mob targets.
/obj/item/proc/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_OBJ, attacked_atom, user) & COMPONENT_NO_ATTACK_OBJ)
		return
	if(item_flags & NOBLUDGEON)
		return
	var/dist = get_dist(attacked_atom,user)
	if(!synth_check(user, SYNTH_OBJ_DAMAGE))
		return
	user.changeNext_move(CLICK_CD_MELEE * weapon_stats[SWING_SPEED] * (range_cooldown_mod ? (dist > 0 ? min(dist, weapon_stats[REACH]) * range_cooldown_mod : range_cooldown_mod) : 1)) //range increases attack cooldown by swing speed
	user.do_attack_animation(attacked_atom)
	attacked_atom.attacked_by(src, user)
	user.add_exp(SKILL_FITNESS, force / 5)
	user.weapon_slow(src)
	var/force_multiplier = 1
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		force_multiplier = H.physiology.force_multiplier
	if(!QDELETED(src))
		take_damage(rand(weapon_stats[DAMAGE_LOW] * force_multiplier, weapon_stats[DAMAGE_HIGH] * force_multiplier), sound_effect = FALSE)

/atom/proc/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!uses_integrity)
		CRASH("attacked_by() was called on [type], which doesn't use integrity!")

	if(!attacking_item.force)
		return
	
	var/damage = take_damage(attacking_item.force * attacking_item.demolition_mod, attacking_item.damtype, MELEE, 1, armour_penetration = attacking_item.armour_penetration)
	var/damage_verb = "hit"
	if(attacking_item.demolition_mod > 1 && damage)
		damage_verb = "pulverized"
	if(attacking_item.demolition_mod < 1)
		damage_verb = "ineffectively pierced"

	visible_message(span_danger("[user] [damage_verb] [src] with [attacking_item][damage ? "" : ", without leaving a mark"]!"), null, null, COMBAT_MESSAGE_RANGE)
	//only witnesses close by and the victim see a hit message.
	log_combat(user, src, "attacked", attacking_item)

/area/attacked_by(obj/item/attacking_item, mob/living/user)
	CRASH("areas are NOT supposed to have attacked_by() called on them!")

/mob/living/attacked_by(obj/item/I, mob/living/user)
	send_item_attack_message(I, user)
	if(I.force)
		apply_damage(I.force, I.damtype)
		if(I.damtype == BRUTE)
			if(prob(33))
				I.add_mob_blood(src)
				var/turf/location = get_turf(src)
				add_splatter_floor(location)
				if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(src)
		return TRUE //successful attack

/mob/living/simple_animal/attacked_by(obj/item/I, mob/living/user)
	if(I.force < force_threshold || I.damtype == STAMINA)
		playsound(loc, 'sound/weapons/tap.ogg', I.get_clamped_volume(), 1, -1)
	else
		return ..()

/mob/living/proc/weapon_slow(obj/item/I)
	add_movespeed_modifier(I.name, priority = 101, multiplicative_slowdown = I.weapon_stats[ENCUMBRANCE])
	addtimer(CALLBACK(src, PROC_REF(remove_movespeed_modifier), I.name), I.weapon_stats[ENCUMBRANCE_TIME], TIMER_UNIQUE|TIMER_OVERRIDE)

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)

/**
 * Called at the end of the attack chain if the user right-clicked.
 *
 * Arguments:
 * * atom/target - The thing that was hit
 * * mob/user - The mob doing the hitting
 * * proximity_flag - is 1 if this afterattack was called on something adjacent, in your square, or on your person.
 * * click_parameters - is the params string from byond [/atom/proc/Click] code, see that documentation.
 */
/obj/item/proc/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	return SECONDARY_ATTACK_CALL_NORMAL

/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area, obj/item/bodypart/hit_bodypart)
	var/message_verb = "attacked"
	if(length(I.attack_verb))
		message_verb = "[pick(I.attack_verb)]"
	else if(!I.force)
		return
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message = "[src] has been [message_verb][message_hit_area] with [I]."
	if(user in viewers(src, null))
		attack_message = "[user] has [message_verb] [src][message_hit_area] with [I]!"
	visible_message(span_danger("[attack_message]"),\
		span_userdanger("[attack_message]"), null, COMBAT_MESSAGE_RANGE)
	return 1
