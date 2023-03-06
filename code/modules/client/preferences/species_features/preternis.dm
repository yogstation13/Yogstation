/datum/preference/choiced/preternis_color
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_key = "feature_pretcolor"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Preternis color"
	should_generate_icons = TRUE

/datum/preference/choiced/preternis_color/init_possible_values()
	var/list/values = list()

	var/icon/preternis_base = icon('icons/mob/human_parts_greyscale.dmi', "preternis_head_m")
	preternis_base.Blend(icon('icons/mob/human_parts_greyscale.dmi', "preternis_chest_m"), ICON_OVERLAY)
	preternis_base.Blend(icon('icons/mob/human_parts_greyscale.dmi', "preternis_l_arm"), ICON_OVERLAY)
	preternis_base.Blend(icon('icons/mob/human_parts_greyscale.dmi', "preternis_r_arm"), ICON_OVERLAY)

	var/icon/eyes = icon('icons/mob/human_face.dmi', "eyes")
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
