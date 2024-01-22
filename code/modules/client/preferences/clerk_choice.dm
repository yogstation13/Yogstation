/// Which clerk shop to spawn on boxstation
/datum/preference/choiced/clerk_choice
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "clerk_choice"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/clerk_choice/create_default_value()
	return "Random"

/datum/preference/choiced/clerk_choice/init_possible_values()
	return GLOB.potential_box_clerk + "Random"

/datum/preference/choiced/clerk_choice/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	
	// Job needs to be medium or high for the preference to show up
	return preferences.job_preferences["Clerk"] >= JP_MEDIUM

/datum/preference/choiced/clerk_choice/apply_to_human(mob/living/carbon/human/target, value)
	return

