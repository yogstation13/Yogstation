/datum/preference/choiced/ethereal_mark
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_ethereal_mark"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_mutant_bodypart = "ethereal_mark"

/datum/preference/choiced/ethereal_mark/init_possible_values()
	return assoc_to_keys(GLOB.ethereal_mark_list)

/datum/preference/choiced/ethereal_mark/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ethereal_mark"] = value
