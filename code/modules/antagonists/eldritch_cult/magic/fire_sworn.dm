/// Creates a constant Ring of Fire around the caster for a set duration of time, which follows them.
/datum/action/cooldown/spell/fire_sworn
	name = "Oath of Fire"
	desc = "Engulf yourself in a cloak of flames for a minute. The flames are harmless to you, but dangerous to anyone else."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "fire_ring"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 70 SECONDS
	
	invocation = "FL'MS"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	/// The radius of the fire ring
	var/fire_radius = 1
	/// How long it the ring lasts
	var/duration = 1 MINUTES

/datum/action/cooldown/spell/fire_sworn/Remove(mob/living/remove_from)
	remove_from.remove_status_effect(/datum/status_effect/fire_ring)
	return ..()

/datum/action/cooldown/spell/fire_sworn/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/fire_sworn/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/fire_ring, duration, fire_radius)

/// Simple status effect for adding a ring of fire around a mob.
/datum/status_effect/fire_ring
	id = "fire_ring"
	tick_interval = 0.1 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The radius of the ring around us.
	var/ring_radius = 1

/datum/status_effect/fire_ring/on_creation(mob/living/new_owner, duration = 1 MINUTES, radius = 1)
	src.duration = duration
	src.ring_radius = radius
	return ..()

/datum/status_effect/fire_ring/tick(delta_time, times_fired)
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return

	if(!isturf(owner.loc))
		return

	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, owner))
		new /obj/effect/hotspot(nearby_turf)
		nearby_turf.hotspot_expose(750, 25 * delta_time, 1)
		for(var/mob/living/fried_living in nearby_turf.contents - owner)
			fried_living.apply_damage(2.5 * delta_time, BURN)
