/datum/preference/choiced/plasmaman_helmet
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_key = "feature_plasmaman_helmet"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Plasmaman helmet"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "plasmaman_helmet"

/datum/preference/choiced/plasmaman_helmet/init_possible_values()
	var/list/values = list()

	for (var/helmet_name as anything in GLOB.plasmaman_helmet_list)
		var/icon/helmet_icon = icon('icons/obj/clothing/hats.dmi', "purple_envirohelm")
		var/icon/overlay_to_blend
		if (helmet_name != "None")
			overlay_to_blend = icon('icons/obj/clothing/hats.dmi', "enviro[GLOB.plasmaman_helmet_list[helmet_name]]")
		if(overlay_to_blend)
			helmet_icon.Blend(overlay_to_blend, ICON_OVERLAY)
		

		values[helmet_name] = helmet_icon

	return values

/datum/preference/choiced/plasmaman_helmet/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["plasmaman_helmet"] = value
