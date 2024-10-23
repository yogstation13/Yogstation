//Strained Muscles: Temporary speed boost at the cost of rapid damage
//Limited because of space suits and such; ideally, used for a quick getaway

//////////////////////
// MONKE REFACTORED //
//////////////////////

/datum/action/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "We evolve the ability to reduce the acid buildup in our muscles, allowing us to move much faster. Costs 10 chemicals to activate."
	helptext = "Causes us to become fatigued over time. Cannot be used in lesser form or while unconscious. Overuse will lead to us collapsing."
	button_icon_state = "strained_muscles"
	chemical_cost = 10
	dna_cost = 1
	req_human = TRUE
	active = FALSE //Whether or not you are a hedgehog
	disabled_by_fire = FALSE

	/// How long this has been on in seconds.
	var/accumulation = 0

	/// Whether we've warned the user about their exhaustion.
	var/warning_given = FALSE

/datum/action/changeling/strained_muscles/can_sting(mob/living/user, mob/living/target)
	var/has_effect = user.has_status_effect(/datum/status_effect/changeling_muscles)
	chemical_cost = has_effect ? 0 : 10
	return ..()

/datum/action/changeling/strained_muscles/sting_action(mob/living/user)
	..()
	var/has_effect = user.has_status_effect(/datum/status_effect/changeling_muscles)
	if(has_effect)
		user.remove_status_effect(/datum/status_effect/changeling_muscles)
	else
		user.apply_status_effect(/datum/status_effect/changeling_muscles)
	return TRUE

/datum/action/changeling/strained_muscles/Remove(mob/living/user)
	user.remove_status_effect(/datum/status_effect/changeling_muscles)
	return ..()
