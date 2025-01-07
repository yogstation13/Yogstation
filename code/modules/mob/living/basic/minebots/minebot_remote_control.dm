#define BOMB_COOLDOWN 20 SECONDS
/obj/item/minebot_remote_control
	name = "Remote Control"
	desc = "Requesting stratagem!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "minebot_bomb_control"
	item_flags = NOBLUDGEON
	///are we currently primed to drop a bomb?
	var/primed = FALSE
	///our last user
	var/datum/weakref/last_user
	///cooldown till we can drop the next bomb
	COOLDOWN_DECLARE(bomb_timer)

/obj/item/minebot_remote_control/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	clear_priming()

/obj/item/minebot_remote_control/proc/clear_priming()
	var/mob/living/living_user = last_user?.resolve()
	last_user = null
	primed = FALSE
	if(isnull(living_user))
		return
	living_user.client?.mouse_override_icon = initial(living_user.client?.mouse_override_icon)
	living_user.update_mouse_pointer()

/obj/item/minebot_remote_control/attack_self(mob/user)
	. = ..()
	if(.)
		return .

	if(!COOLDOWN_FINISHED(src, bomb_timer))
		balloon_alert(user, "on cooldown!")
		return TRUE

	prime_bomb(user)
	return TRUE

/obj/item/minebot_remote_control/proc/prime_bomb(mob/user)
	primed = TRUE
	last_user = WEAKREF(user)
	user.client?.mouse_override_icon = 'icons/effects/mouse_pointers/weapon_pointer.dmi'
	user.update_mouse_pointer()

/**
 * Called when this item is being used to interact with an atom,
 * IE, a mob is clicking on an atom with this item.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/obj/item/proc/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return NONE

/**
 * Called when this item is being used to interact with an atom WITH RIGHT CLICK,
 * IE, a mob is right clicking on an atom with this item.
 *
 * Default behavior has it run the same code as left click.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/obj/item/proc/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/**
 * ## Ranged item interaction
 *
 * Handles non-combat ranged interactions of a tool on this atom,
 * such as shooting a gun in the direction of someone*,
 * having a scanner you can point at someone to scan them at any distance,
 * or pointing a laser pointer at something.
 *
 * *While this intuitively sounds combat related, it is not,
 * because a "combat use" of a gun is gun-butting.
 */
/atom/proc/base_ranged_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	var/is_right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/is_left_clicking = !is_right_clicking
	var/early_sig_return = NONE
	if(is_left_clicking)
		// See [base_item_interaction] for defails on why this is using `||` (TL;DR it's short circuiting)
		early_sig_return = SEND_SIGNAL(src, COMSIG_ATOM_RANGED_ITEM_INTERACTION, user, tool, modifiers) \
			|| SEND_SIGNAL(tool, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM, user, src, modifiers)
	else
		// See above
		early_sig_return = SEND_SIGNAL(src, COMSIG_ATOM_RANGED_ITEM_INTERACTION_SECONDARY, user, tool, modifiers) \
			|| SEND_SIGNAL(tool, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY, user, src, modifiers)
	if(early_sig_return)
		return early_sig_return

	var/self_interaction = is_left_clicking \
		? ranged_item_interaction(user, tool, modifiers) \
		: ranged_item_interaction_secondary(user, tool, modifiers)
	if(self_interaction)
		return self_interaction

	var/interact_return = is_left_clicking \
		? tool.ranged_interact_with_atom(src, user, modifiers) \
		: tool.ranged_interact_with_atom_secondary(src, user, modifiers)
	if(interact_return)
		return interact_return

	return NONE

/**
 * Called when this atom has an item used on it from a distance.
 * IE, a mob is clicking on this atom with an item and is not adjacent.
 *
 * Does NOT include Telekinesis users, they are considered adjacent generally.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 */
/atom/proc/ranged_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return NONE

/**
 * Called when this atom has an item used on it from a distance WITH RIGHT CLICK,
 * IE, a mob is right clicking on this atom with an item and is not adjacent.
 *
 * Default behavior has it run the same code as left click.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 */
/atom/proc/ranged_item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	return ranged_item_interaction(user, tool, modifiers)

/**
 * Called when this item is being used to interact with an atom from a distance,
 * IE, a mob is clicking on an atom with this item and is not adjacent.
 *
 * Does NOT include Telekinesis users, they are considered adjacent generally
 * (so long as this item is adjacent to the atom).
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 */
/obj/item/proc/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return NONE

/**
 * Called when this item is being used to interact with an atom from a distance WITH RIGHT CLICK,
 * IE, a mob is right clicking on an atom with this item and is not adjacent.
 *
 * Default behavior has it run the same code as left click.
 */
/obj/item/proc/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/// Back to Minebot after shitcoding all over this file.
/obj/item/minebot_remote_control/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/minebot_remote_control/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!primed)
		user.balloon_alert(user, "not primed!")
		return ITEM_INTERACT_BLOCKING
	var/turf/target_turf = get_turf(interacting_with)
	if(isnull(target_turf) || isclosedturf(target_turf) || isgroundlessturf(target_turf))
		user.balloon_alert(user, "invalid target!")
		return ITEM_INTERACT_BLOCKING
	playsound(src, 'sound/machines/beep.ogg', 30)
	clear_priming()
	new /obj/effect/temp_visual/minebot_target(target_turf)
	COOLDOWN_START(src, bomb_timer, BOMB_COOLDOWN)
	return ITEM_INTERACT_SUCCESS

/obj/effect/temp_visual/minebot_target
	name = "Rocket Target"
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	duration = 5 SECONDS

#undef BOMB_COOLDOWN
