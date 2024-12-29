/datum/status_effect/no_gravity
	id = "no_gravity"
	alert_type = null
	duration = 2 SECONDS
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/no_gravity/on_apply()
	owner.AddElement(/datum/element/forced_gravity, 0)

/datum/status_effect/no_gravity/on_remove()
	owner.RemoveElement(/datum/element/forced_gravity, 0)



/datum/status_effect/amok/proc/exclusion_check(mob/living/potential_target)
	return IS_HERETIC_OR_MONSTER(potential_target)

/datum/status_effect/amok/tunnel_madness
	id = "tunnel_madness"

/datum/status_effect/amok/tunnel_madness/exclusion_check(mob/living/potential_target)
	return faction_check(potential_target.faction, list(FACTION_RAT))

