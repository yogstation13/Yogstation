/datum/quirk/tunnel_vision
	name = "Tunnel Vision"
	desc = "You spent too long scoped in. You cant see behind you!"
	value = -2
	gain_text = span_notice("You have trouble focusing on what you left behind.")
	lose_text = span_notice("You feel paranoid, constantly checking your back...")
	medical_record_text = "Patient had trouble noticing people walking up from behind during the examination."
	icon = FA_ICON_QUESTION

/datum/quirk/tunnel_vision/add(client/client_source)
	var/range_name = client_source?.prefs.read_preference(/datum/preference/choiced/tunnel_vision_fov) || "Minor (90 Degrees)"
	var/fov_range
	switch(range_name)
		if ("Severe (270 Degrees)")
			fov_range = FOV_270_DEGREES
		if ("Moderate (180 Degrees)")
			fov_range = FOV_180_DEGREES
		else
			fov_range = FOV_90_DEGREES
	quirk_holder.add_fov_trait(type, fov_range)

/datum/quirk/tunnel_vision/remove()
	quirk_holder.remove_fov_trait(type)
