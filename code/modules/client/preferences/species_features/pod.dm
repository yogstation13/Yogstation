/datum/preference/choiced/pod_hair
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_key = "feature_pod_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Pod hair"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "pod_hair"

/datum/preference/choiced/pod_hair/init_possible_values()
	var/list/values = list()

	var/icon/pod_head = icon('icons/mob/human_parts_greyscale.dmi', "pod_head_m")

	for (var/pod_name in GLOB.pod_hair_list)
		var/datum/sprite_accessory/pod_hair = GLOB.pod_hair_list[pod_name]

		var/icon/icon_with_hair = new(pod_head)
		var/icon/icon = icon(pod_hair.icon, pod_hair.icon_state)
		icon_with_hair.Blend(icon, ICON_OVERLAY)
		icon_with_hair.Scale(64, 64)
		icon_with_hair.Crop(15, 64, 15 + 31, 64 - 31)
		icon_with_hair.Blend(COLOR_GREEN, ICON_MULTIPLY)

		values[pod_hair.name] = icon_with_hair

	return values

/datum/preference/choiced/pod_hair/create_default_value()
	return pick(assoc_to_keys(GLOB.pod_hair_list))

/datum/preference/choiced/pod_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pod_hair"] = value
	target.dna.features["pod_flower"] = value

/datum/preference/choiced/pod_hair/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_pod_hair_color"

	return data


/datum/preference/color_legacy/pod_hair_color
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	savefile_key = "feature_pod_hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_mutant_bodypart = "pod_hair"

/datum/preference/color_legacy/pod_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.hair_color = value

/datum/preference/color_legacy/pod_hair_color/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(expand_three_digit_color(value), 22))
		return FALSE

	return TRUE

/datum/preference/color_legacy/pod_flower_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_pod_flower_color"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_mutant_bodypart = "pod_flower"

/datum/preference/color_legacy/pod_flower_color/apply_to_human(mob/living/carbon/human/target, value)
	target.facial_hair_color = value

/datum/preference/color_legacy/pod_flower_color/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(expand_three_digit_color(value), 22))
		return FALSE

	return TRUE
