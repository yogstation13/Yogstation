/// Handler for pain from fire. Goes up the longer you're on fire, largely goes away when extinguished
/datum/status_effect/pain_from_fire
	id = "sharp_pain_from_fire"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN|HEAL_WOUNDS|HEAL_STATUS

	/// Amount of pain being given
	var/pain_amount = 0

/datum/status_effect/pain_from_fire/on_creation(mob/living/new_owner, pain_amount = 0)
	src.pain_amount = pain_amount
	return ..()

/datum/status_effect/pain_from_fire/refresh(mob/living/new_owner, added_pain_amount = 0)
	if(added_pain_amount <= 0)
		return
	pain_amount += added_pain_amount
	owner.cause_pain(BODY_ZONES_ALL, added_pain_amount, BURN)

/datum/status_effect/pain_from_fire/on_apply()
	if(isnull(owner.pain_controller) || pain_amount <= 0)
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_EXTINGUISHED, PROC_REF(remove_on_signal))
	owner.cause_pain(BODY_ZONES_ALL, pain_amount, BURN)
	return TRUE

/datum/status_effect/pain_from_fire/on_remove()
	if(QDELING(owner))
		return
	UnregisterSignal(owner, COMSIG_LIVING_EXTINGUISHED)
	owner.cause_pain(BODY_ZONES_ALL, -3 * pain_amount, BURN)

/// When signalled, terminate.
/datum/status_effect/pain_from_fire/proc/remove_on_signal(datum/source)
	SIGNAL_HANDLER

	if(QDELING(owner) || QDELING(src))
		return
	qdel(src)
