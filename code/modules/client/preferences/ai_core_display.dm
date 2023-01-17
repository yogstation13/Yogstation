/// What to show on the AI screen
/datum/preference/choiced/ai_core_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "preferred_ai_core_display"
	savefile_identifier = PREFERENCE_CHARACTER
	should_generate_icons = TRUE
	can_randomize = FALSE

/datum/preference/choiced/ai_core_display/create_default_value()
	return "Random"

/datum/preference/choiced/ai_core_display/init_possible_values()
	var/list/values = list()

	values["Random"] = icon('icons/mob/ai.dmi', "ai-empty")

	for (var/screen in GLOB.ai_core_display_screens - "Portrait" - "Random")
		values[screen] = icon('icons/mob/ai.dmi', resolve_ai_icon_sync(screen))

	return values

/datum/preference/choiced/ai_core_display/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.ai_core_display_screens))
		return "Random"

	return ..(input, preferences)

/datum/preference/choiced/ai_core_display/apply_to_human(mob/living/carbon/human/target, value)
	return
