/datum/preference/choiced/moth_wings
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_key = "feature_moth_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Moth wings"
	relevant_mutant_bodypart = "moth_wings"
	should_generate_icons = TRUE

/datum/preference/choiced/moth_wings/init_possible_values()
	var/list/icon/values = possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.moth_wings_list,
		"moth_wings",
		list("ADJ", "FRONT"),
	)

	// Moth wings are in a stupid dimension
	for (var/name in values)
		values[name].Crop(1, 1, 32, 32)

	return values

/datum/preference/choiced/moth_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_wings"] = value

