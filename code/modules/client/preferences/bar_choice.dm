/// Which bar to spawn on boxstation
/datum/preference/choiced/bar_choice
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	can_randomize = FALSE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "bar_choice"

/datum/preference/choiced/bar_choice/create_default_value()
	return "Random"

/datum/preference/choiced/bar_choice/init_possible_values()
	return GLOB.potential_box_bars

/datum/preference/choiced/bar_choice/apply_to_human(mob/living/carbon/human/target, value)
	return

