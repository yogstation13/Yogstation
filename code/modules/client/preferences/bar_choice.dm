/// Which bar to spawn on boxstation
/datum/preference/choiced/bar_choice
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "bar_choice"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/bar_choice/create_default_value()
	return "Random"

/datum/preference/choiced/bar_choice/init_possible_values()
	return GLOB.potential_box_bars + "Random"

/datum/preference/choiced/bar_choice/apply_to_human(mob/living/carbon/human/target, value)
	return

