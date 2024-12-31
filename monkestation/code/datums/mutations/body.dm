// you can't become double-giant
/datum/mutation/human/gigantism/on_acquiring(mob/living/carbon/human/acquirer)
	if(acquirer && HAS_TRAIT_FROM(acquirer, TRAIT_GIANT, QUIRK_TRAIT))
		return TRUE
	return ..()
