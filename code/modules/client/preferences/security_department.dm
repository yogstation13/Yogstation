/// Which department to put security officers in
/datum/preference/choiced/security_department
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "prefered_security_department"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/security_department/create_default_value()
	return SEC_DEPT_NONE

/datum/preference/choiced/security_department/init_possible_values()
	return GLOB.security_depts_prefs

/datum/preference/choiced/security_department/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.security_depts_prefs))
		return SEC_DEPT_NONE

	return ..(input, preferences)

/datum/preference/choiced/security_department/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	
	// Job needs to be medium or high for the preference to show up
	return preferences.job_preferences["Security Officer"] >= JP_MEDIUM

/datum/preference/choiced/security_department/apply_to_human(mob/living/carbon/human/target, value)
	return
