/proc/generate_possible_values_for_sprite_accessories_on_head(accessories)
	var/list/values = possible_values_for_sprite_accessory_list(accessories)

	var/icon/head_icon = icon('icons/mob/human_parts_greyscale.dmi', "human_head_m")
	head_icon.Blend("#[skintone2hex("caucasian1")]", ICON_MULTIPLY)

	for (var/name in values)
		var/datum/sprite_accessory/accessory = accessories[name]
		if (accessory == null || accessory.icon_state == null)
			continue

		var/icon/final_icon = new(head_icon)

		var/icon/beard_icon = values[name]
		beard_icon.Blend(COLOR_DARK_BROWN, ICON_MULTIPLY)
		final_icon.Blend(beard_icon, ICON_OVERLAY)

		final_icon.Crop(10, 19, 22, 31)
		final_icon.Scale(32, 32)

		values[name] = final_icon

	return values


/datum/preference/color_legacy/eye_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "eye_color"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_species_trait = EYECOLOR
	unique = TRUE

/datum/preference/color_legacy/eye_color/apply_to_human(mob/living/carbon/human/target, value)
	target.eye_color = value

	var/obj/item/organ/eyes/eyes_organ = target.getorgan(/obj/item/organ/eyes)
	if (istype(eyes_organ))
		if (!initial(eyes_organ.eye_color))
			eyes_organ.eye_color = value
		eyes_organ.old_eye_color = value

/datum/preference/color_legacy/eye_color/create_default_value()
	return random_eye_color()


/datum/preference/choiced/hairstyle
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_key = "hair_style_name"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Hair style"
	should_generate_icons = TRUE
	relevant_species_trait = HAIR

/datum/preference/choiced/hairstyle/init_possible_values()
	return generate_possible_values_for_sprite_accessories_on_head(GLOB.hair_styles_list)

/datum/preference/choiced/hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.hair_style = value


/datum/preference/color_legacy/hair_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_species_trait = HAIR
	unique = TRUE

/datum/preference/color_legacy/hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.hair_color = value


/datum/preference/choiced/facial_hairstyle
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_key = "facial_style_name"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Facial hair"
	should_generate_icons = TRUE
	relevant_species_trait = FACEHAIR

/datum/preference/choiced/facial_hairstyle/init_possible_values()
	return generate_possible_values_for_sprite_accessories_on_head(GLOB.facial_hair_styles_list)

/datum/preference/choiced/facial_hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.facial_hair_style = value


/datum/preference/color_legacy/facial_hair_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "facial_hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_species_trait = FACEHAIR
	unique = TRUE

/datum/preference/color_legacy/facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.facial_hair_color = value


/datum/preference/choiced/hair_gradient
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_gradientstyle"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_species_trait = HAIR

/datum/preference/choiced/hair_gradient/init_possible_values()
	return assoc_to_keys(GLOB.hair_gradients_list)

/datum/preference/choiced/hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.grad_style = value

/datum/preference/choiced/hair_gradient/create_default_value()
	return "None"


/datum/preference/color_legacy/hair_gradient
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "feature_gradientcolor"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_species_trait = HAIR

/datum/preference/color_legacy/hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.grad_color = value
