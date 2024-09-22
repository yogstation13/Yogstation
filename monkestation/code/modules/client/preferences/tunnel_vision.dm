GLOBAL_LIST_INIT(tunnel_vision_fovs, list("Minor (90 Degrees)","Moderate (180 Degrees)","Severe (270 Degrees)"))

/datum/preference/choiced/tunnel_vision_fov
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "tunnel_vision_fov"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/tunnel_vision_fov/init_possible_values()
	return GLOB.tunnel_vision_fovs

/datum/preference/choiced/tunnel_vision_fov/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Tunnel Vision" in preferences.all_quirks

/datum/preference/choiced/tunnel_vision_fov/apply_to_human(mob/living/carbon/human/target, value)
	return
