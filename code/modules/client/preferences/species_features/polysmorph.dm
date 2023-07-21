/datum/preference/choiced/polysmorph_tail
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_polysmorph_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Polysmorph tail"
	relevant_mutant_bodypart = "tail_polysmorph"

/datum/preference/choiced/polysmorph_tail/init_possible_values()
	return GLOB.tails_list_polysmorph

/datum/preference/choiced/polysmorph_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_polysmorph"] = value


/datum/preference/choiced/polysmorph_teeth
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_polysmorph_teeth"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Polysmorph teeth"
	relevant_mutant_bodypart = "teeth"

/datum/preference/choiced/polysmorph_teeth/init_possible_values()
	return GLOB.teeth_list

/datum/preference/choiced/polysmorph_teeth/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["teeth"] = value


/datum/preference/choiced/polysmorph_dome
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_polysmorph_dome"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Polysmorph dome"
	relevant_mutant_bodypart = "dome"

/datum/preference/choiced/polysmorph_dome/init_possible_values()
	return GLOB.dome_list

/datum/preference/choiced/polysmorph_dome/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["dome"] = value


/datum/preference/choiced/polysmorph_dorsal_tubes
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_polysmorph_dorsal_tubes"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Polysmorph dorsal tubes"
	relevant_mutant_bodypart = "dorsal_tubes"

/datum/preference/choiced/polysmorph_dorsal_tubes/init_possible_values()
	return GLOB.dorsal_tubes_list

/datum/preference/choiced/polysmorph_dorsal_tubes/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["dorsal_tubes"] = value
