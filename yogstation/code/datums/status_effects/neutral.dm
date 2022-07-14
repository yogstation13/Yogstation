/datum/status_effect/voided
	id = "Voided"
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/obj/effect/immortality_talisman/v 

/datum/status_effect/voided/on_apply()
	. = ..()
	v = new /obj/effect/immortality_talisman/void(get_turf(owner), owner)
	v.vanish(owner)	

/datum/status_effect/voided/on_remove()
	. = ..()
	v.unvanish(owner)
