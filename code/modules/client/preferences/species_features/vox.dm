/proc/generate_vox_side_shots(list/sprite_accessories, accessory_color = COLOR_DARKER_BROWN)
	var/list/values = list()
	var/icon/vox_head = icon('icons/mob/species/vox/bodyparts.dmi', "vox_head_green")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	var/icon/eyes = icon('icons/mob/species/vox/eyes.dmi', "eyes")
	var/icon/eyes_static = icon('icons/mob/species/vox/eyes.dmi', "eyes_static_green")
	eyes.Blend(COLOR_CYAN, ICON_MULTIPLY)
	vox_head.Blend(eyes, ICON_OVERLAY)
	vox_head.Blend(eyes_static, ICON_OVERLAY)
	var/icon/beak = icon('icons/mob/species/vox/bodyparts.dmi', "vox_head_static")
	vox_head.Blend(beak, ICON_OVERLAY)
	for(var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]
		var/icon/final_icon = icon(vox_head)
		if(name != "None")
			var/icon/accessory_icon = icon(sprite_accessory.icon, sprite_accessory.icon_state)
			accessory_icon.Blend(accessory_color, sprite_accessory.color_blend_mode == COLOR_BLEND_ADD ? ICON_ADD : ICON_MULTIPLY)
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
		"crimson" = "#ff0000",
		"plum" = "#5B3256",
		"azure" = "#0b322a",
		"emerald" = "#024716",
		"brown" = "#592810",
		"grey" = "#2b3326",
		"nebula" = "#282b63",
		"mossy" = "#407436"
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

/datum/preference/choiced/vox_quills
	savefile_key = "feature_vox_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE
	relevant_mutant_bodypart =  "vox_quills"
	main_feature_name = "Quillstyle"

/datum/preference/choiced/vox_quills/init_possible_values()
	return generate_vox_side_shots(GLOB.vox_quills_list)

/datum/preference/choiced/vox_quills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_quills"] = value

/datum/preference/choiced/vox_facial_quiils
	savefile_key = "feature_vox_facial_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "vox_facial_quills"
	main_feature_name = "Facial Quillstyle"


/datum/preference/choiced/vox_facial_quiils/init_possible_values()
	return generate_vox_side_shots(GLOB.vox_facial_quills_list)

/datum/preference/choiced/vox_facial_quiils/apply_to_human(mob/living/carbon/human/target, value)
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

/datum/preference/choiced/underwear/vox
	savefile_key = "feature_vox_underwear"
	relevant_mutant_bodypart = "vox_tail"
	blacklisted_species = null

/datum/preference/choiced/underwear/vox/init_possible_values()
	return generate_values_for_underwear('icons/mob/clothing/species/vox/underwear.dmi', GLOB.underwear_list, list("vox_chest_green", "vox_r_leg_green", "vox_l_leg_green", "vox_r_leg_static", "vox_l_leg_static"), 'icons/mob/species/vox/bodyparts.dmi')

/datum/preference/choiced/socks/vox
	savefile_key = "feature_vox_socks"
	relevant_mutant_bodypart = "vox_tail"
	blacklisted_species = null

/datum/preference/choiced/socks/vox/init_possible_values()
	return generate_values_for_underwear('icons/mob/clothing/species/vox/socks.dmi', GLOB.socks_list, list("vox_r_leg_green", "vox_l_leg_green", "vox_r_leg_static", "vox_l_leg_static"), 'icons/mob/species/vox/bodyparts.dmi')

/datum/preference/choiced/undershirt/vox
	savefile_key = "feature_vox_undershirt"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "vox_tail"
	blacklisted_species = null

/datum/preference/choiced/undershirt/vox/init_possible_values()
	var/bodyparts_icon = 'icons/mob/species/vox/bodyparts.dmi'
	var/icon/body = icon(bodyparts_icon, "vox_r_leg_green")
	body.Blend(icon(bodyparts_icon, "vox_l_leg_green"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_r_arm_green"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_l_arm_green"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_r_hand"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_l_hand"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_chest_green"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_l_arm_static"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_r_arm_static"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_l_leg_static"), ICON_OVERLAY)
	body.Blend(icon(bodyparts_icon, "vox_r_leg_static"), ICON_OVERLAY)
	var/vox_undershirt_icon = 'icons/mob/clothing/species/vox/undershirt.dmi'
	var/list/values = list()
	var/list/undershirt_list = GLOB.undershirt_list.Copy()
	for(var/undershirt in undershirt_list)
		if(undershirt == "Nude")
			continue
		var/datum/sprite_accessory/undershirt_accessory = undershirt_list[undershirt]
		if(!icon_exists(vox_undershirt_icon, undershirt_accessory.icon_state))
			undershirt_list -= undershirt
	for(var/accessory_name in undershirt_list)
		var/icon/icon_with_undershirt = icon(body)
		if(accessory_name != "Nude")
			var/datum/sprite_accessory/accessory = undershirt_list[accessory_name]
			icon_with_undershirt.Blend(icon(vox_undershirt_icon, accessory.icon_state), ICON_OVERLAY)
		icon_with_undershirt.Crop(9, 9, 23, 23)
		icon_with_undershirt.Scale(32, 32)
		values[accessory_name] = icon_with_undershirt
	return values

/datum/preference/choiced/vox_tank_type
	savefile_key = "feature_vox_tank_type"
	relevant_mutant_bodypart = "vox_tail"
	main_feature_name = "N² Tank"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/vox_tank_type/init_possible_values()
	return list("Large N² Tank", "Specialized N² Tank")

/datum/preference/choiced/vox_tank_type/create_default_value()
	return "Specialized N² Tank"

/datum/preference/choiced/vox_tank_type/apply_to_human()
	return
