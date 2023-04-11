/// What to show on the AI screen
/datum/preference/choiced/ai_core_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "preferred_ai_core_display"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/ai_core_display/create_default_value()
	return "Random"

/datum/preference/choiced/ai_core_display/init_possible_values()
	return GLOB.ai_core_display_screens - "Portrait"

/datum/preference/choiced/ai_core_display/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.ai_core_display_screens))
		return "Random"

	return ..(input, preferences)

/datum/preference/choiced/ai_core_display/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	
	// Job needs to be medium or high for the preference to show up
	return preferences.job_preferences["AI"] >= JP_MEDIUM

/datum/preference/choiced/ai_core_display/apply_to_human(mob/living/carbon/human/target, value)
	return
