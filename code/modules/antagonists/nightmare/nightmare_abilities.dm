/datum/action/cooldown/spell/jaunt/shadow_walk
	check_flags = AB_CHECK_PHASED

/datum/action/cooldown/spell/jaunt/shadow_walk/IsAvailable(feedback)
	if(!..())
		return FALSE
	if(owner.stat >= UNCONSCIOUS)
		if(feedback)
			owner.balloon_alert(owner, "unconscious!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/jaunt/shadow_walk/enter_jaunt(mob/living/jaunter, turf/loc_override)
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/action/cooldown/spell/jaunt/shadow_walk/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	. = ..()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

/datum/action/cooldown/spell/jaunt/shadow_walk/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER
	exit_jaunt(owner)
