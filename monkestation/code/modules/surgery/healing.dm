/datum/surgery/healing
	requires_bodypart_type = BODYTYPE_ORGANIC //IPCs have robotic repair and their welders/coil

/datum/surgery/healing/can_start(mob/user, mob/living/patient)
	if(HAS_TRAIT(patient, TRAIT_NO_HEALS))
		return FALSE
	return ..()
