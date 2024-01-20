#define VOX_HAIR_COLOR "#FF9966"

/proc/generate_vox_side_shots(list/sprite_accessories, key, accessory_color = VOX_HAIR_COLOR)
	var/list/values = list()

	var/icon/vox_head = icon('icons/mob/species/vox/bodyparts.dmi', "vox_head_green")
	var/icon/eyes = icon('icons/mob/species/vox/eyes.dmi', "eyes_l")
	var/icon/eyes_r = icon('icons/mob/species/vox/eyes.dmi', "eyes_r")


	eyes.Blend(COLOR_CYAN, ICON_MULTIPLY)
	eyes_r.Blend(COLOR_CYAN, ICON_MULTIPLY)
	eyes.Blend(eyes_r, ICON_OVERLAY)
	vox_head.Blend(eyes, ICON_OVERLAY)

	var/icon/beak = icon('icons/mob/species/vox/beaks.dmi', "m_beak_vox_ADJ")
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

/datum/preference/choiced/vox_body
	savefile_key = "feature_vox_body"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	relevant_mutant_bodypart = "vox_body"
	should_generate_icons = TRUE
	main_feature_name = "Skin Tone"

/datum/preference/choiced/vox_body/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_body"] = value

/datum/preference/choiced/vox_body/init_possible_values()
	var/list/values = list()
	var/icon/eyes = icon('icons/mob/species/vox/eyes.dmi', "eyes_l", EAST)
	var/icon/eyes_r = icon('icons/mob/species/vox/eyes.dmi', "eyes_r", EAST)
	eyes.Blend(COLOR_CYAN, ICON_MULTIPLY)
	eyes_r.Blend(COLOR_CYAN, ICON_MULTIPLY)
	eyes.Blend(eyes_r, ICON_OVERLAY)
	var/icon/beak = icon('icons/mob/species/vox/beaks.dmi', "m_beak_vox_ADJ", EAST)
	for(var/body_vox in GLOB.vox_bodies_list)
		var/datum/sprite_accessory/vox_bodies/vox_body = GLOB.vox_bodies_list[body_vox]
		var/icon/vox_head_icon = icon('icons/mob/species/vox/bodyparts.dmi', "vox_head_[lowertext(vox_body.name)]", EAST)
		vox_head_icon.Blend(eyes, ICON_OVERLAY)
		vox_head_icon.Blend(beak, ICON_OVERLAY)
		vox_head_icon.Crop(14, 21, 27, 30)
		vox_head_icon.Scale(32, 32)
		//vox_head_icon.Blend(icon('icons/mob/species/vox/bodyparts.dmi', "vox_head_[skin_tone]", EAST), ICON_OVERLAY)
		values[body_vox] = vox_head_icon
	return values

/datum/preference/choiced/vox_body/create_default_value()
	return pick(GLOB.vox_bodies_list)

/datum/preference/choiced/vox_tail_markings
	savefile_key = "feature_vox_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "vox_tail_markings"
	main_feature_name = "Tail Markings"

/datum/preference/choiced/vox_tail_markings/init_possible_values()
	return assoc_to_keys(GLOB.vox_tail_markings_list)

/datum/preference/choiced/vox_tail_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_tail_markings"] = value

/datum/preference/choiced/vox_body_markings
	savefile_key = "feature_vox_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "vox_body_markings"
	main_feature_name = "Body markings"

/datum/preference/choiced/vox_body_markings/init_possible_values()
	return assoc_to_keys(GLOB.vox_body_markings_list)

/datum/preference/choiced/vox_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_body_markings"] = value

/datum/preference/choiced/vox_hair
	savefile_key = "feature_vox_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE
	main_feature_name = "Quillstyle"
	relevant_mutant_bodypart =  "vox_quills"

/datum/preference/choiced/vox_hair/init_possible_values()
	return generate_vox_side_shots(GLOB.vox_quills_list, "vox_hair")

/datum/preference/choiced/vox_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_quills"] = value

/datum/preference/choiced/vox_facial_hair
	savefile_key = "feature_vox_facial_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Facial Quillstyle"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "vox_facial_quills"

/datum/preference/choiced/vox_facial_hair/init_possible_values()
	return generate_vox_side_shots(GLOB.vox_facial_quills_list, "vox_facial_hair")

/datum/preference/choiced/vox_facial_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_facial_quills"] = value
