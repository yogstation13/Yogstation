/// Blue eye effect, makes your screen a swirling blue
/datum/status_effect/blue_eye
	id = "blue_eye"
	alert_type = /atom/movable/screen/alert/status_effect/high
	remove_on_fullheal = TRUE

/datum/status_effect/blue_eye/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/blue_eye/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(remove_blue_eye))

	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, id, /datum/mood_event/high)
	owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/blue_eye)
	return TRUE

/datum/status_effect/blue_eye/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, id)
	owner.clear_fullscreen(id)

/// Removes all of our blue_eye (self delete) on signal
/datum/status_effect/blue_eye/proc/remove_blue_eye(datum/source, admin_revive)
	SIGNAL_HANDLER

	qdel(src)
