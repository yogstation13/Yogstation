/datum/preference/choiced/preternis_color
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_key = "feature_pretcolor"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Preternis color"
	should_generate_icons = TRUE

/datum/preference/choiced/preternis_color/init_possible_values()
	var/list/values = list()

	var/icon/preternis_base = icon('icons/mob/human_parts_greyscale.dmi', "preternis_head")
	preternis_base.Blend(icon('icons/mob/human_parts_greyscale.dmi', "preternis_chest"), ICON_OVERLAY)
	preternis_base.Blend(icon('icons/mob/human_parts_greyscale.dmi', "preternis_l_arm"), ICON_OVERLAY)
	preternis_base.Blend(icon('icons/mob/human_parts_greyscale.dmi', "preternis_r_arm"), ICON_OVERLAY)

	var/icon/eyes = icon('icons/mob/mutant_bodyparts.dmi', "m_preternis_eye_1_ADJ")
	eyes.Blend(COLOR_RED, ICON_MULTIPLY)
	preternis_base.Blend(eyes, ICON_OVERLAY)

	preternis_base.Scale(64, 64)
	preternis_base.Crop(15, 64, 15 + 31, 64 - 31)

	for (var/name in GLOB.color_list_preternis)
		var/color = GLOB.color_list_preternis[name]

		var/icon/icon = new(preternis_base)
		icon.Blend(color, ICON_MULTIPLY)
		values[name] = icon

	return values

/datum/preference/choiced/preternis_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pretcolor"] = GLOB.color_list_preternis[value]

//Weathering
/datum/preference/choiced/preternis_weathering
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_preternis_weathering"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_mutant_bodypart = "preternis_weathering"

/datum/preference/choiced/preternis_weathering/init_possible_values()
	return assoc_to_keys(GLOB.preternis_weathering_list)

/datum/preference/choiced/preternis_weathering/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["preternis_weathering"] = value

//Antenna
/datum/preference/choiced/preternis_antenna
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_preternis_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_mutant_bodypart = "preternis_antenna"

/datum/preference/choiced/preternis_antenna/init_possible_values()
	return assoc_to_keys(GLOB.preternis_antenna_list)

/datum/preference/choiced/preternis_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["preternis_antenna"] = value

//Eye
/datum/preference/choiced/preternis_eye
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_preternis_eye"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_mutant_bodypart = "preternis_eye"

/datum/preference/choiced/preternis_eye/init_possible_values()
	return assoc_to_keys(GLOB.preternis_eye_list)

/datum/preference/choiced/preternis_eye/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["preternis_eye"] = value
	target.dna.features["preternis_core"] = "Core" //core is reliant on eye colour and it needs to get added to features somewhere
