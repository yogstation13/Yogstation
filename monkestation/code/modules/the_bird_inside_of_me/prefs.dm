/**
 * Generates a basic body icon for a humanoid when given a list of bodyparts
 *
 * Arguments
 * * bodypart_list - list of bodyparts to put on the body.
 * The first bodypart in the list becomes the base of the icon, which in most cases doesn't matter, but may for layering.
 * * skintone - (optional) skintone of the body.
 * Not a hex color, but corresponds to human skintones.
 * * dir - (optional) direction of all the icons
 */
/proc/get_basic_body_icon(list/bodypart_list, skintone = "caucasian1", icon_dir = NORTH)
	var/icon/base_icon
	for(var/obj/item/bodypart/other_bodypart as anything in bodypart_list)
		var/icon/generated_icon = icon(
			icon = UNLINT(initial(other_bodypart.icon_greyscale)),
			icon_state = UNLINT("[initial(other_bodypart.limb_id)]_[initial(other_bodypart.body_zone)][initial(other_bodypart.is_dimorphic) ? "_m" : ""]"),
			dir = icon_dir,
		)
		generated_icon.Blend(skintone2hex(skintone), ICON_MULTIPLY)
		if(isnull(base_icon))
			base_icon = generated_icon
		else
			base_icon.Blend(generated_icon, ICON_OVERLAY)

	return base_icon

/proc/generate_ornithid_side_shots(list/sprite_accessories, key, list/sides)
	var/list/values = list()

	var/icon/ornithid = icon('icons/mob/species/human/human_face.dmi', "head", EAST)
	var/icon/eyes = icon('icons/mob/species/human/human_face.dmi', "eyes", EAST)
	eyes.Blend(COLOR_RED, ICON_MULTIPLY)

	ornithid.Blend(eyes, ICON_OVERLAY)

	for (var/name in sprite_accessories)

		var/icon/final_icon = icon(ornithid)


		final_icon.Crop(11, 20, 23, 32)
		final_icon.Scale(32, 32)
		final_icon.Blend(COLOR_BLUE_GRAY, ICON_MULTIPLY)

		values[name] = final_icon

	return values

/datum/preference/choiced/ornithid_wings
	main_feature_name = "Arm Wings"
	savefile_key = "feature_arm_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	relevant_external_organ = /obj/item/organ/external/wings/functional/arm_wings
	should_generate_icons = TRUE

/datum/preference/choiced/ornithid_wings/init_possible_values()
	return assoc_to_keys_features(GLOB.arm_wings_list)

/datum/preference/choiced/ornithid_wings/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.arm_wings_list,
		"arm_wings",
		list("FRONT"),
	)

/datum/preference/choiced/ornithid_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arm_wings"] = value

/datum/preference/choiced/ornithid_wings/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = list("feather_color", "feather_color_secondary", "feather_color_tri")
	return data

/datum/preference/color/feather_color
	savefile_key = "feather_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED

/datum/preference/color/feather_color_secondary
	savefile_key = "feather_color_secondary"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED
	allows_nulls = TRUE
	default_null = TRUE

/datum/preference/color/feather_color_tri
	savefile_key = "feather_color_tri"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED
	allows_nulls = TRUE
	default_null = TRUE

/datum/preference/color/plummage_color
	savefile_key = "plummage_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED
	allows_nulls = TRUE
	default_null = TRUE

/datum/preference/color/feather_tail_color
	savefile_key = "feather_tail_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED
	allows_nulls = TRUE
	default_null = TRUE

#define X_TAIL_CROP 16
#define Y_TAIL_CROP 5

/datum/preference/choiced/tail_avian
	main_feature_name = "Avian Tail"
	savefile_key = "feature_avian_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/external/tail/avian
	should_generate_icons = TRUE

/datum/preference/choiced/tail_avian/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feather_color_secondary"
	return data

/datum/preference/choiced/tail_avian/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.tails_list_avian,
		"tail_avian",
		list("FRONT", "BEHIND"),
		)

/datum/preference/choiced/tail_avian/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_avian"] = value

/datum/preference/choiced/tail_avian/create_default_value()
	return /datum/sprite_accessory/tails/avian::name

#undef X_TAIL_CROP
#undef Y_TAIL_CROP

/datum/preference/choiced/plumage
	main_feature_name = "Plumage"
	savefile_key = "feature_avian_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/external/plumage
	should_generate_icons = TRUE

/datum/preference/choiced/plumage/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.avian_ears_list,
		"ears_avian",
		list("FRONT"),
	)

/datum/preference/choiced/plumage/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ears_avian"] = value

/datum/preference/choiced/plumage/create_default_value()
	return /datum/sprite_accessory/plumage::name
