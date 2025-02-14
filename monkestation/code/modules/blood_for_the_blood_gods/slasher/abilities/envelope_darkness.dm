/datum/action/cooldown/slasher/envelope_darkness
	name = "Darkness Shroud"
	desc = "Become masked in the light and visible in the dark."
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS
	var/envelope_darkness_processing = FALSE

/datum/action/cooldown/slasher/envelope_darkness/PreActivate(atom/target)
	. = .. ()
	RegisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(break_envelope_by_damage))
	RegisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT,  PROC_REF(break_envelope_by_damage))


/datum/action/cooldown/slasher/envelope_darkness/Activate(atom/target)
	. = ..()
	if(envelope_darkness_processing == TRUE)
		break_envelope_manually()
		envelope_darkness_processing = FALSE
		return
	var/mob/living/owner_mob = owner
	owner_mob.apply_status_effect(/datum/status_effect/slasher/envelope_darkness)
	envelope_darkness_processing = TRUE

/atom/movable/screen/alert/status_effect/slasher/envelope_darkness
	name = "envelope darkness"
	desc = "The shadows cloak you, preventing you from being seen when in light."
	icon = 'goon/icons/mob/slasher.dmi'
	icon_state = "incorporealize"

/datum/status_effect/slasher/envelope_darkness
	id = "envelope_darkness"
	duration = STATUS_EFFECT_PERMANENT
	show_duration = FALSE
	tick_interval = 0.2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/slasher/envelope_darkness
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/slasher/envelope_darkness/on_apply()
	. = ..()
	to_chat(owner, span_notice("The shadows cloak you."))

/datum/status_effect/slasher/envelope_darkness/on_remove()
	. = ..()
	to_chat(owner, span_notice("The shadows are no longer on my side..."))

/datum/status_effect/slasher/envelope_darkness/tick(seconds_per_tick, times_fired)
	var/turf/below_turf = get_turf(owner)
	var/turf_light_level = below_turf.get_lumcount()
	// Convert light level to alpha inversely (darker = more visible)
	owner.alpha = clamp(200 * (1 - turf_light_level), 0, 200)

/datum/action/cooldown/slasher/envelope_darkness/Remove(mob/living/remove_from)
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
	remove_from.remove_status_effect(/datum/status_effect/slasher/envelope_darkness)
	remove_from.alpha = 255

/datum/action/cooldown/slasher/envelope_darkness/proc/break_envelope_by_damage(datum/source, damage_amount, damagetype)
	SIGNAL_HANDLER
	if(damage_amount < 50)
		return
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
	var/mob/living/owner_mob = owner
	for(var/i = 1 to 4)
		owner_mob.blood_particles(2, max_deviation = rand(-120, 120), min_pixel_z = rand(-4, 12), max_pixel_z = rand(-4, 12))

	var/datum/antagonist/slasher/slasher = owner_mob.mind?.has_antag_datum(/datum/antagonist/slasher)
	slasher?.reduce_fear_area(15, 4)
	break_envelope_manually()

/datum/action/cooldown/slasher/envelope_darkness/proc/break_envelope_manually(datum/source, damage_amount, damagetype)

	var/mob/living/owner_mob = owner
	owner_mob.alpha = 255
	owner_mob.remove_status_effect(/datum/status_effect/slasher/envelope_darkness)
	StartCooldown()


/datum/action/cooldown/slasher/envelope_darkness/proc/bullet_impact(mob/living/carbon/human/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER
	return COMPONENT_BULLET_PIERCED
