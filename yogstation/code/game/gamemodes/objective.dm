GLOBAL_LIST_INIT(infiltrator_objective_areas, typecacheof(list(/area/yogs/infiltrator_base, /area/syndicate_mothership, /area/shuttle/yogs/stealthcruiser)))

/datum/objective/assassinate/internal/check_completion()
	if(..())
		return TRUE
	return !considered_alive(target)



/datum/objective/protect_mindless_living
	name = "protect living"
	var/mob/living/protect_target

/datum/objective/protect_mindless_living/proc/set_target(mob/living/L)
	protect_target = L
	update_explanation_text()

/datum/objective/protect_mindless_living/update_explanation_text()
	. = ..()
	if(protect_target)
		explanation_text = "Protect \the [protect_target] at all costs."
	else
		explanation_text = "Free Objective"

/datum/objective/protect_mindless_living/check_completion()

	if(..())
		return TRUE

	if(!protect_target)
		return TRUE

	if(QDELETED(protect_target))
		return FALSE

	if(protect_target.stat == DEAD)
		return FALSE

	return TRUE //All good!