/datum/preference/choiced/polysmorph_tail
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_polysmorph_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Polysmorph tail"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "tail_polysmorph"

/datum/preference/choiced/polysmorph_tail/init_possible_values()
	var/list/icon/values = possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.tails_list_polysmorph,
		"tail",
		list("BEHIND"),
	)

	return values

/datum/preference/choiced/polysmorph_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_polysmorph"] = value


/datum/preference/choiced/polysmorph_teeth
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_polysmorph_teeth"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Polysmorph teeth"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "teeth"

/datum/preference/choiced/polysmorph_teeth/init_possible_values()
	var/list/icon/values = possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.teeth_list,
		"teeth",
		list("ADJ"),
	)

	return values

/datum/preference/choiced/polysmorph_teeth/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["teeth"] = value


/datum/preference/choiced/polysmorph_dome
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_polysmorph_dome"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Polysmorph dome"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "dome"

/datum/preference/choiced/polysmorph_dome/init_possible_values()
	var/list/icon/values = possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.dome_list,
		"dome",
		list("ADJ"),
	)

	return values

/datum/preference/choiced/polysmorph_dome/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["dome"] = value


/datum/preference/choiced/polysmorph_dorsal_tubes
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_polysmorph_dorsal_tubes"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Polysmorph dorsal tubes"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "dorsal_tubes"

/datum/preference/choiced/polysmorph_dorsal_tubes/init_possible_values()
	var/list/icon/values = possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.dorsal_tubes_list,
		"dorsal_tubes",
		list("BEHIND"),
	)

	return values

/datum/preference/choiced/polysmorph_dorsal_tubes/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["dorsal_tubes"] = value
