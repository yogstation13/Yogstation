/datum/preference/choiced/accent
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "accent"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/accent/create_default_value()
	return ACCENT_NONE

/datum/preference/choiced/accent/init_possible_values()
	return GLOB.accents_names

/datum/preference/choiced/accent/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.accents_names))
		return ACCENT_NONE

	return ..(input, preferences)

/datum/preference/choiced/accent/apply_to_human(mob/living/carbon/human/target, value)
	return
