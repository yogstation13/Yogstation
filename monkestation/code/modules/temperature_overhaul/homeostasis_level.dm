/**
 * Changes the level to which the mob homeostasises to, while optionally providing a buff to the rate at which they do so.
 *
 * Additional buff to homeostasis rate does not affecte nutrition drain of homeostasis.
 *
 * Args
 * * source: String key source of this effect
 * * to_value: The target value to homeostasise to
 * * delta_change: Optional, additional rate of change to the mob's body temperature
 * * while_stasis: Optional, if delta change is supplied, it will tick while the mob is in stasis
 * * while_dead: Optional, if delta change is supplied, it will tick while the mob is dead
 * * update_species: Optional, if TRUE, and if the mob's species changes, we will update the target temp. to accomodate
 * (via the difference in new species vs old species standard_body_temperature)
 */
/mob/living/proc/add_homeostasis_level(
	source,
	to_value,
	delta_change = 0 KELVIN,
	while_stasis = FALSE,
	while_dead = FALSE,
	update_species = TRUE
)
	ASSERT(source)
	ASSERT(to_value)
	apply_status_effect(/datum/status_effect/homeostasis_level, source, to_value, delta_change, while_stasis, while_dead, update_species)

/**
 * Removes a source of homeostasis level change from a mob.
 *
 * Args
 * * source: String key source to remove
 */
/mob/living/proc/remove_homeostasis_level(
	source,
)
	ASSERT(source)
	remove_status_effect(/datum/status_effect/homeostasis_level, source)

/**
 * Updates an existing change to the mob's homeostasis levels
 *
 * Args
 * * source: String key source to update
 * * to_value: Change the level to homeostasise to
 * * delta_change: Change the rate of change to the mob's body temperature
 */
/mob/living/proc/update_homeostasis_level(
	source,
	to_value,
	delta_change = 0 KELVIN,
)
	ASSERT(source)
	ASSERT(to_value)
	apply_status_effect(/datum/status_effect/homeostasis_level, source, to_value, delta_change)

/**
 * Attempts to stabilize a mob's body temperature to a set value.
 */
/datum/status_effect/homeostasis_level
	id = "temp_change"
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = 2 SECONDS
	alert_type = null
	var/source
	var/to_value
	var/delta_change
	var/while_stasis
	var/while_dead
	var/update_species

/datum/status_effect/homeostasis_level/on_creation(
	mob/living/new_owner,
	source,
	to_value,
	delta_change = 0 KELVIN,
	while_stasis = FALSE,
	while_dead = FALSE,
	update_species = TRUE
)
	src.source = source
	src.to_value = to_value
	src.delta_change = abs(delta_change)
	src.while_stasis = while_stasis
	src.while_dead = while_dead
	src.update_species = update_species

	return ..()

/datum/status_effect/homeostasis_level/on_apply()
	if(isnull(src.source))
		stack_trace("Temperature change status effect applied without a source")
		return FALSE
	if(isnull(src.to_value))
		stack_trace("Temperature change status effect applied without a set temperature")
		return FALSE

	for(var/datum/status_effect/homeostasis_level/effect in owner.status_effects)
		if(effect.source == src.source)
			effect.to_value = src.to_value
			effect.delta_change = src.delta_change
			LAZYSET(owner.homeostasis_targets, REF(effect), effect.to_value)
			return FALSE

	RegisterSignal(owner, COMSIG_SPECIES_GAIN, PROC_REF(species_update))
	LAZYSET(owner.homeostasis_targets, REF(src), src.to_value)
	return TRUE

/datum/status_effect/homeostasis_level/before_remove(source)
	return src.source == source

/datum/status_effect/homeostasis_level/on_remove()
	UnregisterSignal(owner, COMSIG_SPECIES_GAIN)
	LAZYREMOVE(owner.homeostasis_targets, REF(src))

/datum/status_effect/homeostasis_level/tick(seconds_between_ticks)
	if(!delta_change)
		return
	if(!while_stasis && HAS_TRAIT(owner, TRAIT_STASIS))
		return
	if(!while_dead && owner.stat == DEAD)
		return

	if(to_value < owner.standard_body_temperature)
		owner.adjust_bodytemperature(-delta_change, min_temp = to_value)

	else
		owner.adjust_bodytemperature(delta_change, max_temp = to_value)

/datum/status_effect/homeostasis_level/proc/species_update(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER

	if(!update_species || isnull(new_species) || isnull(old_species) || new_species.type == old_species.type)
		return

	to_value += UNLINT(new_species.bodytemp_normal - old_species.bodytemp_normal)
