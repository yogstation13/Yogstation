/// Red eye effect, makes your screen a swirling red
/datum/status_effect/red_eye
	id = "red_eye"
	alert_type = /atom/movable/screen/alert/status_effect/red_eye
	remove_on_fullheal = TRUE
	examine_text = "Their eyes are bright red and bulging out their skull!"

/datum/status_effect/red_eye/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/red_eye/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(remove_red_eye))

	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, id, /datum/mood_event/high)
	owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/red_eye)
	return TRUE

/datum/status_effect/red_eye/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, id)
	owner.clear_fullscreen(id)

/// Removes all of our red_eye (self delete) on signal
/datum/status_effect/red_eye/proc/remove_red_eye(datum/source, admin_revive)
	SIGNAL_HANDLER

	qdel(src)

/atom/movable/screen/alert/status_effect/red_eye
	name = "Red-Eye"
	desc = "DRAKHARFR PLEGH-WE GALBARTOK USINAR"
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "red_eye" 
