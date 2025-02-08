/datum/preference/choiced/blindness_choice
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "blindness"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/blindness_choice/create_default_value()
	return "Echolocation"

/datum/preference/choiced/blindness_choice/init_possible_values()
	return list(
		"Echolocation",
		"Complete blindness",
		"Random",
	)

/datum/preference/choiced/blindness_choice/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return preferences.all_quirks.Find("Blind")

/datum/preference/choiced/blindness_choice/apply_to_human(mob/living/carbon/human/target, value)
	return
