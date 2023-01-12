/// Which department to put station engineers in
/datum/preference/choiced/engineering_department
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	can_randomize = FALSE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "prefered_engineering_department"

/datum/preference/choiced/engineering_department/create_default_value()
	return ENG_DEPT_NONE

/datum/preference/choiced/engineering_department/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.engineering_depts_prefs))
		return ENG_DEPT_NONE

	return ..(input, preferences)

/datum/preference/choiced/engineering_department/init_possible_values()
	return GLOB.engineering_depts_prefs

/datum/preference/choiced/engineering_department/apply_to_human(mob/living/carbon/human/target, value)
	return

