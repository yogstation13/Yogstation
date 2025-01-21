/*!
 * Contains the "Void Chill" status effect. Harmful debuff which freezes and slows down non-heretics
 * Cannot affect silicons (How are you gonna freeze a robot?)
 */
/datum/status_effect/void_chill
	id = "void_chill"
	duration = 20 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_chill
	status_type = STATUS_EFFECT_REFRESH //Custom code
	on_remove_on_mob_delete = TRUE
	remove_on_fullheal = TRUE
	///Current amount of stacks we have
	var/stacks
	///Maximum of stacks that we could possibly get
	var/stack_limit = 5
	///icon for the overlay
	var/mutable_appearance/stacks_overlay

/datum/status_effect/void_chill/on_creation(mob/living/new_owner, new_stacks, ...)
	. = ..()
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_stacks_overlay))
	set_stacks(new_stacks)
	stacks_overlay = mutable_appearance('icons/effects/effects.dmi', "void_chill_oh_fuck", ABOVE_MOB_LAYER)
	owner.update_icon(UPDATE_OVERLAYS)

/datum/status_effect/void_chill/Destroy()
	QDEL_NULL(stacks_overlay)
	return ..()

/datum/status_effect/void_chill/on_apply()
	if(issilicon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_stacks_overlay))
	owner.update_icon(UPDATE_OVERLAYS)
	return TRUE

/datum/status_effect/void_chill/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/void_chill)
	REMOVE_TRAIT(owner, TRAIT_HYPOTHERMIC, TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.update_icon(UPDATE_OVERLAYS)

/datum/status_effect/void_chill/tick(seconds_per_ticks)
	owner.adjust_bodytemperature(-12 KELVIN * stacks * seconds_per_ticks)

/datum/status_effect/void_chill/refresh(mob/living/new_owner, new_stacks, forced = FALSE)
	. = ..()
	if(forced)
		set_stacks(new_stacks)
	else
		adjust_stacks(new_stacks)
	owner.update_icon(UPDATE_OVERLAYS)

///Updates the overlay that gets applied on our victim
/datum/status_effect/void_chill/proc/update_stacks_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	overlays -= stacks_overlay

	linked_alert?.update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
	stacks_overlay = image('icons/effects/effects.dmi', owner, "void_chill_partial")
	if(stacks >= 5)
		stacks_overlay = image('icons/effects/effects.dmi', owner, "void_chill_oh_fuck")
	overlays += stacks_overlay

/**
 * Setter and adjuster procs for stacks
 *
 * Arguments:
 * - new_stacks
 *
 */

/datum/status_effect/void_chill/proc/set_stacks(new_stacks)
	stacks = max(0, min(stack_limit, new_stacks))
	update_movespeed(stacks)

/datum/status_effect/void_chill/proc/adjust_stacks(new_stacks)
	stacks = max(0, min(stack_limit, stacks + new_stacks))
	update_movespeed(stacks)
	if(stacks >= 5)
		ADD_TRAIT(owner, TRAIT_HYPOTHERMIC, TRAIT_STATUS_EFFECT(id))

///Updates the movespeed of owner based on the amount of stacks of the debuff
/datum/status_effect/void_chill/proc/update_movespeed(stacks)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/void_chill, update = TRUE)
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/void_chill, update = TRUE, multiplicative_slowdown = (0.5 * stacks))
	linked_alert.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align:center'>[stacks]</span>")

/datum/status_effect/void_chill/lasting
	id = "lasting_void_chill"
	duration = -1

/datum/movespeed_modifier/void_chill
	variable = TRUE
	multiplicative_slowdown = 0.1

//Screen alert
/atom/movable/screen/alert/status_effect/void_chill
	name = "Void Chill"
	desc = "There's something freezing you from within and without. You've never felt cold this oppressive before..."
	icon_state = "void_chill_minor"

/atom/movable/screen/alert/status_effect/void_chill/update_icon_state()
	. = ..()
	if(!istype(attached_effect, /datum/status_effect/void_chill))
		return
	var/datum/status_effect/void_chill/chill_effect = attached_effect
	if(chill_effect.stacks >= 5)
		icon_state = "void_chill_oh_fuck"

/atom/movable/screen/alert/status_effect/void_chill/update_desc(updates)
	. = ..()
	if(!istype(attached_effect, /datum/status_effect/void_chill))
		return
	var/datum/status_effect/void_chill/chill_effect = attached_effect
	if(chill_effect.stacks >= 5)
		desc = "You had your chance to run, now it's too late. You may never feel warmth again..."
