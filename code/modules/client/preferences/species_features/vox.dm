#define VOX_HAIR_COLOR "#614f19"

/proc/generate_vox_side_shots(list/sprite_accessories, key, accessory_color = VOX_HAIR_COLOR)
	var/list/values = list()
	var/icon/vox_head = icon('icons/mob/species/vox/bodyparts.dmi', "vox_head_green")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	var/icon/eyes = icon('icons/mob/species/vox/eyes.dmi', "eyes")
	eyes.Blend(COLOR_CYAN, ICON_MULTIPLY)
	vox_head.Blend(eyes, ICON_OVERLAY)
	var/icon/beak = icon('icons/mob/species/vox/bodyparts.dmi', "vox_head_static")
	vox_head.Blend(beak, ICON_OVERLAY)
	for(var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]
		var/icon/final_icon = icon(vox_head)
		var/icon/accessory_icon = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ")
		accessory_icon.Blend(accessory_color, sprite_accessory.color_blend_mode == "add" ? ICON_ADD : ICON_MULTIPLY)
		final_icon.Blend(accessory_icon, ICON_OVERLAY)
		final_icon.Crop(10, 19, 22, 31)
		final_icon.Scale(32, 32)
		values[name] = final_icon
	return values

/datum/preference/choiced/vox_skin_tone
	savefile_key = "feature_vox_skin_tone"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "vox_tail"
	main_feature_name = "Skin Tone"

/datum/preference/choiced/vox_skin_tone/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_skin_tone"] = value

/datum/preference/choiced/vox_skin_tone/init_possible_values()
	return GLOB.vox_skin_tones

/datum/preference/choiced/vox_skin_tone/compile_constant_data()
	var/list/data = ..()
	var/list/capitalized_skin_tones = list()
	for(var/skin_tone in GLOB.vox_skin_tones)
		capitalized_skin_tones[skin_tone] = capitalize(skin_tone)
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = capitalized_skin_tones
	var/list/skin_tones_to_hex = list(
		"green" = "#00ff00",
		"crimson" = "#ff0000"
	)
	var/list/to_hex = list()
	for (var/choice in get_choices())
		var/hex_value = skin_tones_to_hex[choice]
		var/list/hsl = rgb2num(hex_value, COLORSPACE_HSL)
		to_hex[choice] = list(
			"lightness" = hsl[3],
			"value" = hex_value,
		)
	data["to_hex"] = to_hex
	return data

/datum/preference/choiced/vox_tail_markings
	savefile_key = "feature_vox_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "vox_tail_markings"

/datum/preference/choiced/vox_tail_markings/init_possible_values()
	return assoc_to_keys(GLOB.vox_tail_markings_list)

/datum/preference/choiced/vox_tail_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_tail_markings"] = value

/datum/preference/choiced/vox_body_markings
	savefile_key = "feature_vox_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "vox_body_markings"

/datum/preference/choiced/vox_body_markings/init_possible_values()
	return assoc_to_keys(GLOB.vox_body_markings_list)

/datum/preference/choiced/vox_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_body_markings"] = value

/datum/preference/choiced/vox_hair
	savefile_key = "feature_vox_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE
	relevant_mutant_bodypart =  "vox_quills"
	main_feature_name = "Quillstyle"

/datum/preference/choiced/vox_hair/init_possible_values()
	return generate_vox_side_shots(GLOB.vox_quills_list, "vox_hair")

/datum/preference/choiced/vox_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_quills"] = value

/datum/preference/choiced/vox_facial_hair
	savefile_key = "feature_vox_facial_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "vox_facial_quills"
	main_feature_name = "Facial Quillstyle"


/datum/preference/choiced/vox_facial_hair/init_possible_values()
	return generate_vox_side_shots(GLOB.vox_facial_quills_list, "vox_facial_hair")

/datum/preference/choiced/vox_facial_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_facial_quills"] = value

/datum/preference/color/hair_color/quill_color
	savefile_key = "feature_quill_color"
	relevant_species_traits = null
	relevant_mutant_bodypart = "vox_quills"

/datum/preference/color/facial_hair_color/facial_quill_color
	savefile_key = "feature_facial_quill_color"
	relevant_species_traits = null
	relevant_mutant_bodypart = "vox_facial_quills"

/datum/preference/color/mutant_color/vox_body_markings_color
	savefile_key = "feature_body_markings_color"
	relevant_mutant_bodypart = "vox_body_markings"
	relevant_species_traits = null
	blacklisted_species = null

/datum/preference/color/mutant_color/vox_body_markings_color/is_valid(value)
	return findtext(value, GLOB.is_color)

/datum/preference/color/mutant_color_secondary/vox_tail_markings_color
	savefile_key = "feature_tail_markings_color"
	relevant_mutant_bodypart = "vox_tail_markings"
	relevant_species_traits = null
	blacklisted_species = null
