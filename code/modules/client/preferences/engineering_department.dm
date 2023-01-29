/// Which department to put station engineers in
/datum/preference/choiced/engineering_department
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "prefered_engineering_department"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/engineering_department/create_default_value()
	return ENG_DEPT_NONE

/datum/preference/choiced/engineering_department/init_possible_values()
	return GLOB.engineering_depts_prefs

/datum/preference/choiced/engineering_department/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.engineering_depts_prefs))
		return ENG_DEPT_NONE

	return ..(input, preferences)

/datum/preference/choiced/engineering_department/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	
	// Job needs to be medium or high for the preference to show up
	return preferences.job_preferences["Station Engineer"] >= JP_MEDIUM

/datum/preference/choiced/engineering_department/apply_to_human(mob/living/carbon/human/target, value)
	return

