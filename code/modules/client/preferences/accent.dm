/datum/preference/choiced/accent
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "accent"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/accent/create_default_value()
	return ACCENT_NONE

/datum/preference/choiced/accent/init_possible_values()
	return GLOB.accents_names + ACCENT_NONE
