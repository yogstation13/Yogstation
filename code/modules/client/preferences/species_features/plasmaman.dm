/datum/preference/choiced/plasmaman_helmet
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_key = "feature_plasmaman_helmet"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Plasmaman helmet"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "plasmaman_helmet"

/datum/preference/choiced/plasmaman_helmet/init_possible_values()
	var/list/values = list()

	for (var/helmet_name in GLOB.plasmaman_helmet_list)
		var/datum/sprite_accessory/helmet_icon_suffix = GLOB.plasmaman_helmet_list[helmet_name]
		var/helmet_icon = "purple_envirohelm"
		if (helmet_name != "None")
			helmet_icon += "-[helmet_icon_suffix]"

		var/icon/icon = icon('icons/obj/clothing/hats.dmi', helmet_icon)
		values[helmet_name] = icon

	return values

/datum/preference/choiced/plasmaman_helmet/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["plasmaman_helmet"] = value
