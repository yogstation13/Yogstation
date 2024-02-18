///Slowly drains HP from a living mob.
/datum/element/life_draining
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	///How much damage to deal overtime.
	var/damage_overtime
	///The callback we will use to cancel damage, if any
	var/datum/callback/check_damage_callback

/datum/element/life_draining/Attach(
	mob/living/target,
	damage_overtime = 1,
	datum/callback/check_damage_callback,
)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.damage_overtime = damage_overtime
	src.check_damage_callback = check_damage_callback
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_mob_life))

/datum/element/life_draining/Detach(mob/living/source, ...)
	UnregisterSignal(source, COMSIG_LIVING_LIFE)
	return ..()

///Handles removing HP from the mob, as long as they're not dead.
/datum/element/life_draining/proc/on_mob_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(source.stat == DEAD)
		return
	if(check_damage_callback?.Invoke())
		return
	source.adjustBruteLoss(damage_overtime)
