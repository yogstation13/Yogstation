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
