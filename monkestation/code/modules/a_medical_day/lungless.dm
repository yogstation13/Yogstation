/datum/status_effect/lungless
	id = "no_lungs"
	alert_type = null
	duration = -1
	tick_interval = -1

/datum/status_effect/lungless/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(isnull(carbon_owner.dna?.species?.mutantlungs))
		return FALSE

	RegisterSignal(owner, COMSIG_CARBON_ATTEMPT_BREATHE, PROC_REF(block_breath))
	RegisterSignal(owner, COMSIG_SPECIES_GAIN, PROC_REF(check_new_species))
	return TRUE

/datum/status_effect/lungless/on_remove()
	UnregisterSignal(owner, list(COMSIG_CARBON_ATTEMPT_BREATHE, COMSIG_SPECIES_GAIN))

/datum/status_effect/lungless/proc/block_breath(...)
	SIGNAL_HANDLER
	owner.apply_damage(HUMAN_MAX_OXYLOSS, OXY)
	return BREATHE_SKIP_BREATH

/datum/status_effect/lungless/proc/check_new_species(...)
	SIGNAL_HANDLER
	var/mob/living/carbon/carbon_owner = owner
	if(isnull(carbon_owner.dna?.species?.mutantlungs))
		qdel(src)
