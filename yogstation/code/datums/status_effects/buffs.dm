/datum/status_effect/dodging
	id = "dodging"
	duration = 0.5 SECONDS
	examine_text = span_notice("They're deftly dodging all incoming attacks!")
	alert_type = /obj/screen/alert/status_effect/dodging

/datum/status_effect/dodging/on_apply()
	owner.visible_message(span_notice("[owner] dodges!"))
	owner.status_flags |= GODMODE
	return ..()

/datum/status_effect/dodging/on_remove()
	owner.status_flags &= ~GODMODE
	owner.visible_message(span_warning("[owner] returns to a neutral stance."))

/obj/screen/alert/status_effect/dodging
	name = "Dodging"
	desc = "You're sure to win because your speed is superior!"
	icon_state = "evading"
