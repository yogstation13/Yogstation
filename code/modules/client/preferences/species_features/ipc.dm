/datum/preference/choiced/ipc_screen
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_ipc_screen"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "IPC screen"
	relevant_mutant_bodypart = "ipc_screen"

/datum/preference/choiced/ipc_screen/init_possible_values()
	return GLOB.ipc_screens_list

/datum/preference/choiced/ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_screen"] = value


/datum/preference/color_legacy/ipc_screen_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "eye_color"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_mutant_bodypart = "ipc_screen"

/datum/preference/color_legacy/ipc_screen_color/apply_to_human(mob/living/carbon/human/target, value)
	target.eye_color = value

	var/obj/item/organ/eyes/eyes_organ = target.getorgan(/obj/item/organ/eyes)
	if (istype(eyes_organ))
		if (!initial(eyes_organ.eye_color))
			eyes_organ.eye_color = value
		eyes_organ.old_eye_color = value


/datum/preference/choiced/ipc_antenna
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_ipc_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "IPC antenna"
	relevant_mutant_bodypart = "ipc_antenna"

/datum/preference/choiced/ipc_antenna/init_possible_values()
	return GLOB.ipc_antennas_list

/datum/preference/choiced/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_antenna"] = value


/datum/preference/color_legacy/ipc_antenna_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_mutant_bodypart = "ipc_antenna"

/datum/preference/color_legacy/ipc_antenna_color/apply_to_human(mob/living/carbon/human/target, value)
	target.hair_color = value


/datum/preference/choiced/ipc_chassis
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_ipc_chassis"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "IPC chassis"
	relevant_mutant_bodypart = "ipc_chassis"

/datum/preference/choiced/ipc_chassis/init_possible_values()
	return GLOB.ipc_chassis_list

/datum/preference/choiced/ipc_chassis/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_chassis"] = value
