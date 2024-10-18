///Minimum stamina damage where trying to block results in you being knocked down.
#define STAGGER_THRESHOLD 75
///Penalty for blocking too many things in quick succession.
#define CONSECUTIVE_BLOCK_PENALTY 0.1
///Multiplier for block force when parrying.
#define PARRY_BONUS 2
///How much to reduce block force by for each armor penetration.
#define AP_TO_FORCE 0.2
///Used to prevent blocking an attack multiple times.
#define BLOCK_COOLDOWN "block_cooldown"
///How long right click needs to be held for mouse up to be overridden.
#define MOUSEUP_OVERRIDE_TIME 0.25 SECONDS

/datum/component/blocking
	///The client attached to the mob that is currently holding the item.
	var/client/active_client
	///The mob that is currently holding the item.
	var/mob/active_mob
	///Current mouse parameters, used to make the user face the direction they're blocking.
	var/mouse_params
	///How much damage this can block without penalty.
	var/block_force
	///What type of attacks this can block, among other things.
	var/block_flags
	///Slowdown while actively blocking.
	var/active_slowdown
	///Whether blocking is currently active.
	var/blocking = FALSE
	///The last time the mouse was held down.
	var/last_mousedown = 0
	///The last time this item has blocked or attempted to block.
	var/last_block = 0
	///Number of consecutive blocks.
	var/consecutive_blocks = 0
	// Parry cooldown.
	COOLDOWN_DECLARE(parry_cd)

/datum/component/blocking/Initialize(block_force = 10, block_flags = WEAPON_BLOCK_FLAGS, active_slowdown = 0.5, ...)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.block_force = block_force
	src.block_flags = block_flags
	src.active_slowdown = active_slowdown

/datum/component/blocking/InheritComponent(datum/component/C, i_am_original, block_force, block_flags, active_slowdown)
	if(!i_am_original)
		return
	if(block_force)
		src.block_force = block_force
	if(block_flags)
		src.block_flags = block_flags
	if(active_slowdown)
		src.active_slowdown = active_slowdown

/datum/component/blocking/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignals(parent, list(COMSIG_PREQDELETED, COMSIG_ITEM_DROPPED), PROC_REF(on_drop))

/datum/component/blocking/UnregisterFromParent()
	if(active_mob)
		UnregisterSignal(active_mob, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_LOGIN, COMSIG_HUMAN_CHECK_SHIELDS, COMSIG_HUMAN_AFTER_BLOCK, COMSIG_ATOM_PRE_DIR_CHANGE))
		REMOVE_TRAIT(active_mob, TRAIT_NO_BLOCKING, BLOCK_COOLDOWN)
	if(active_client)
		UnregisterSignal(active_client, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEDRAG, COMSIG_CLIENT_MOUSEUP))
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ATOM_EXAMINE, COMSIG_PREQDELETED, COMSIG_ITEM_DROPPED))

/datum/component/blocking/Destroy(force, silent)
	set_blocking(FALSE)
	if(active_mob)
		REMOVE_TRAIT(active_mob, TRAIT_NO_BLOCKING, BLOCK_COOLDOWN)
	REMOVE_TRAIT(parent, TRAIT_PARRYING, BLOCK_COOLDOWN)
	return ..()

/datum/component/blocking/proc/on_examine(obj/item/source, mob/user, list/examine_list)
	examine_list += span_notice("<b>Hold right click with combat mode ON to block incoming attacks.</b>")

/datum/component/blocking/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	set_blocking(FALSE) // would be very silly if you could equip an item to an inventory slot and still block with it
	if(!user)
		CRASH("An item with blocking component ([parent]) was just picked up without a user. What the fuck? Who did this?")
	active_mob = user
	active_client = active_mob.client
	RegisterSignal(active_mob, COMSIG_MOB_LOGOUT, PROC_REF(on_drop), override = TRUE)
	RegisterSignal(active_mob, COMSIG_MOB_LOGIN, PROC_REF(on_equip), override = TRUE)
	RegisterSignal(active_mob, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_block), override = TRUE)
	RegisterSignal(active_mob, COMSIG_HUMAN_AFTER_BLOCK, PROC_REF(after_block), override = TRUE)
	RegisterSignal(active_mob, COMSIG_ATOM_PRE_DIR_CHANGE, PROC_REF(on_dir_change), override = TRUE)
	if(active_client)
		RegisterSignal(active_client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(on_mousedown), override = TRUE)
		RegisterSignal(active_client, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(on_mousedrag), override = TRUE)
		RegisterSignal(active_client, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_mouseup), override = TRUE)

/datum/component/blocking/proc/on_drop()
	SIGNAL_HANDLER
	set_blocking(FALSE)
	if(active_client)
		UnregisterSignal(active_client, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEDRAG, COMSIG_CLIENT_MOUSEUP))
		active_client = null
	if(active_mob)
		UnregisterSignal(active_mob, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_LOGIN, COMSIG_HUMAN_CHECK_SHIELDS, COMSIG_HUMAN_AFTER_BLOCK, COMSIG_ATOM_PRE_DIR_CHANGE))
		REMOVE_TRAIT(active_mob, TRAIT_NO_BLOCKING, BLOCK_COOLDOWN)
		active_mob = null

/datum/component/blocking/proc/can_block(mob/living/defender, atom/movable/incoming, damage, attack_type)
	SHOULD_BE_PURE(TRUE)
	if(HAS_TRAIT(defender, TRAIT_NO_BLOCKING)) // the best defense is a good offense after all
		return FALSE
	if(SEND_SIGNAL(parent, COMSIG_ITEM_PRE_BLOCK, defender, incoming, damage, attack_type) & COMPONENT_CANCEL_BLOCK) // INTERCEPTED
		return FALSE
	if(!(block_flags & attack_type)) // "nuh uh" - the incoming attack
		return FALSE
	if(!(block_flags & OMNIDIRECTIONAL_BLOCK) && (get_dir(defender, incoming) & turn(defender.dir, 180))) // can't block behind you
		return FALSE
	if((block_flags & TRANSPARENT_BLOCK) && (incoming.pass_flags & PASSGLASS)) // they can see right through your defenses
		return FALSE
	if((block_flags & PARRYING_BLOCK) && HAS_TRAIT(incoming, TRAIT_UNPARRIABLE)) // parry this you filthy casual
		return FALSE
	if((block_flags & WIELD_TO_BLOCK) && !HAS_TRAIT(parent, TRAIT_WIELDED))
		return FALSE
	return TRUE

/datum/component/blocking/proc/on_block(mob/living/defender, atom/movable/incoming, damage, attack_text, attack_type, armour_penetration, damage_type)
	SIGNAL_HANDLER
	if(!blocking && !(block_flags & ALWAYS_BLOCK)) // not even trying
		return NONE
	
	last_block = world.time
	if(HAS_TRAIT(parent, TRAIT_PARRYING)) // timing it just right reduces incoming damage
		damage *= 0.5

	var/obj/item/used_item = parent
	var/effective_block_force = get_block_force(parent, defender, incoming, damage, attack_type, armour_penetration)
	for(var/obj/item/held_item in defender.held_items)
		if(held_item == parent) // already checked
			continue
		var/new_block_force = get_block_force(held_item, defender, incoming, damage, attack_type, armour_penetration)
		if(new_block_force <= effective_block_force)
			continue
		used_item = held_item
		effective_block_force = new_block_force

	if(HAS_TRAIT(incoming, TRAIT_SHIELDBUSTER))
		if(block_flags & DAMAGE_ON_BLOCK)
			used_item.take_damage(damage * 2, damage_type)
			if(QDELETED(used_item)) // return early and give a special message if it got destroyed
				defender.visible_message(
					span_danger("[incoming] shatters [used_item]!"),
					span_userdanger("[incoming] shatters [used_item] with devastating force!"),
				)
				return NONE
		defender.visible_message(
			span_danger("[incoming] knocks [used_item] out of [defender]'s hands!"),
			span_userdanger("[incoming] knocks your [used_item.name] out of your hands!"),
		)
		defender.dropItemToGround(used_item)
		var/atom/throw_target = get_edge_target_turf(defender, get_dir(incoming, get_step_away(defender, incoming)))
		used_item.safe_throw_at(throw_target, rand(1, 2), 2)
		return NONE

	if(effective_block_force <= 0 || armour_penetration >= 100) // PENETRATED
		if(block_flags & DAMAGE_ON_BLOCK)
			used_item.take_damage(damage, damage_type)
		return NONE

	ADD_TRAIT(defender, TRAIT_NO_BLOCKING, BLOCK_COOLDOWN) // prevents blocking the same thing more than once
	SEND_SIGNAL(parent, COMSIG_ITEM_POST_BLOCK, defender, incoming, damage, attack_type)

	var/is_parrying = HAS_TRAIT(used_item, TRAIT_PARRYING)
	if(is_parrying)
		used_item.balloon_alert_to_viewers("parried!")
		playsound(defender, 'sound/weapons/ricochet.ogg', 75, TRUE) // +PARRY
		COOLDOWN_RESET(src, parry_cd)
	else
		consecutive_blocks++
		addtimer(VARSET_CALLBACK(src, consecutive_blocks, 0), 1.5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) // blocking resets the cooldown
	defender.visible_message(span_danger("[defender] [is_parrying ? "parries" : "blocks"] [attack_text] with [used_item]!"))

	var/effective_damage = max((damage * (1 + consecutive_blocks * CONSECUTIVE_BLOCK_PENALTY)) - effective_block_force, 0)
	if(damage_type == STAMINA)
		effective_damage *= 0.5 // stamina weapons are easier to block to compensate for being far stronger
	if(HAS_TRAIT(defender, TRAIT_STUNIMMUNE)) // in case of nitrium users (me)
		if(damage_type != STAMINA) // no don't kill people with stun weapons what the hell
			defender.adjustOxyLoss(effective_damage * 0.25, TRUE) // reduced because it takes a lot less to down and goes away much slower
	else
		defender.adjustStaminaLoss(effective_damage, TRUE)
		if(defender.getStaminaLoss() >= STAGGER_THRESHOLD)
			to_chat(defender, span_userdanger("You're knocked off-balance by [attack_text]!"))
			defender.Knockdown(3 SECONDS, TRUE)

	if(attack_type & PROJECTILE_ATTACK)
		if(!isprojectile(incoming))
			CRASH("[incoming] was not a projectile but had PROJECTILE_ATTACK attack type!")
		var/obj/projectile/reflected = incoming
		if(is_parrying || ((block_flags & REFLECTIVE_BLOCK) && (reflected.reflectable & REFLECT_NORMAL))) // perfect parry can reflect ANY projectile
			playsound(defender, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 50, 1)
			return SHIELD_REFLECT
		playsound(defender, 'sound/weapons/ricochet.ogg', 50, TRUE)
	if(attack_type & MELEE_ATTACK) // melee attacks get a cool sound
		playsound(defender, 'sound/weapons/parry.ogg', 50, TRUE)
	if(attack_type & (UNARMED_ATTACK|THROWN_PROJECTILE_ATTACK|LEAP_ATTACK))
		playsound(defender, 'sound/weapons/smash.ogg', 50, TRUE)

	if((block_flags & DAMAGE_ON_BLOCK) && !is_parrying)
		used_item.take_damage(damage, damage_type)

	return SHIELD_BLOCK

/datum/component/blocking/proc/get_block_force(obj/item/weapon, mob/living/defender, atom/movable/incoming, damage, attack_type, armour_penetration)
	var/force_returned = 0
	if(weapon == parent)
		if(!can_block(defender, incoming, damage, attack_type))
			return 0
		force_returned = block_force
	else
		var/datum/component/blocking/blocking_component = weapon.GetComponent(/datum/component/blocking)
		if(!blocking_component)
			return 0
		if(!blocking_component.can_block(defender, incoming, damage, attack_type))
			return 0
		force_returned = blocking_component.block_force
	if(attack_type & (MELEE_ATTACK|UNARMED_ATTACK|THROWN_PROJECTILE_ATTACK|LEAP_ATTACK)) // being stronger provides a small increase to melee blocking
		force_returned += defender.get_skill(SKILL_FITNESS)
	if(HAS_TRAIT(weapon, TRAIT_PARRYING))
		force_returned *= PARRY_BONUS
	return max(force_returned - max(armour_penetration - weapon.armour_penetration, 0) * AP_TO_FORCE, 0)

/datum/component/blocking/proc/after_block(mob/living/defender, block_result)
	SIGNAL_HANDLER
	REMOVE_TRAIT(defender, TRAIT_NO_BLOCKING, BLOCK_COOLDOWN)

/datum/component/blocking/proc/on_mousedown(client/source, atom/target, turf/location, control, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(modifiers[LEFT_CLICK] || modifiers[MIDDLE_CLICK]) // only block on right click
		// end blocking so you can attack normally
		set_blocking(FALSE)
		return
	if(modifiers[SHIFT_CLICK] || modifiers[CTRL_CLICK] || modifiers[ALT_CLICK]) // trying to do something else
		return
	if(!source.mob.combat_mode) // require combat mode to block so you can still do certain right-click alt actions with it off
		return
	if(source.mob.in_throw_mode) // trying to throw
		return
	if(isnull(location)) // clicking on something in the UI
		if(!istype(target, /atom/movable/screen/click_catcher))
			return
		location = params2turf(modifiers[SCREEN_LOC], get_turf(source.eye), source)
		if(!location) // you clicked the void, but we couldn't figure out a turf to face towards
			return
		target = location
	if(!source.mob.is_holding(parent)) // not holding it
		return
	if(HAS_TRAIT(source.mob, TRAIT_NO_BLOCKING))
		return
	if((block_flags & WIELD_TO_BLOCK) && !HAS_TRAIT(parent, TRAIT_WIELDED))
		if(source.mob.get_active_held_item() == parent) // only show a warning if you're holding it
			source.mob.balloon_alert(source.mob, "wield it first!")
		return
	mouse_params = params
	source.mob.face_atom(target, forced = TRUE)
	last_mousedown = world.time
	set_blocking(TRUE)

/datum/component/blocking/proc/on_mousedrag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(!blocking)
		return
	mouse_params = params
	if(isnull(over_location)) // UI element, can't face it
		var/list/modifiers = params2list(params)
		var/turf/backup_turf = params2turf(modifiers[SCREEN_LOC], get_turf(source.eye), source)
		if(backup_turf)
			source.mob.face_atom(backup_turf, forced = TRUE)
		return
	source.mob.face_atom(over_object, forced = TRUE)

/datum/component/blocking/proc/on_mouseup(client/source, atom/target, turf/location, control, params)
	SIGNAL_HANDLER
	if(!blocking) // not blocking, don't intercept
		return NONE
	set_blocking(FALSE)
	mouse_params = params
	if((world.time < (last_mousedown + MOUSEUP_OVERRIDE_TIME)) && (last_block < last_mousedown)) // you clicked too fast and didn't block anything, ignore
		return NONE
	if(!source.mob.get_active_held_item()) // you're probably trying to right click on something with your hand
		return NONE
	return COMPONENT_CLIENT_MOUSEUP_INTERCEPT

/datum/component/blocking/proc/set_blocking(enabled)
	if(blocking == enabled)
		return
	blocking = enabled
	if(!active_mob)
		return
	if(enabled)
		active_mob.add_movespeed_modifier("blocking", update = TRUE, priority = 100, multiplicative_slowdown = active_slowdown)
		if((block_flags & PARRYING_BLOCK) && COOLDOWN_FINISHED(src, parry_cd))
			COOLDOWN_START(src, parry_cd, CLICK_CD_MELEE)
			ADD_TRAIT(parent, TRAIT_PARRYING, BLOCK_COOLDOWN)
			addtimer(CALLBACK(src, PROC_REF(remove_parry)), 0.4 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	else
		active_mob.remove_movespeed_modifier("blocking", update = TRUE)

/datum/component/blocking/proc/remove_parry()
	REMOVE_TRAIT(parent, TRAIT_PARRYING, BLOCK_COOLDOWN)

/datum/component/blocking/proc/on_dir_change()
	if(!blocking) 
		return NONE // keep facing the same direction so you can block properly
	return COMPONENT_ATOM_BLOCK_DIR_CHANGE
