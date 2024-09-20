/datum/surgery/healing/can_start(mob/user, mob/living/patient)
	if(HAS_TRAIT(patient, TRAIT_NO_HEALS))
		return FALSE
	return ..()
