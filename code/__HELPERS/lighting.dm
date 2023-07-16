/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EMISSIVE_COLOR].
/proc/emissive_appearance(icon, icon_state = "", atom/offset_spokesman, layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE, offset_const)
	// Note: alpha doesn't "do" anything, since it's overriden by the color set shortly after
	// Consider removing it someday? (I wonder if we made emissives blend right we could make alpha actually matter. dreams man, dreams)
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, /*offset_spokesman, */EMISSIVE_PLANE, 255, appearance_flags | EMISSIVE_APPEARANCE_FLAGS/*, offset_const*/)
	appearance.color = GLOB.emissive_color

	//Test to make sure emissives with broken or missing icon states are created
//	if(PERFORM_ALL_TESTS(focus_only/invalid_emissives))
//		if(icon_state && !icon_exists(icon, icon_state, scream = FALSE)) //Scream set to False so we can have a custom stack_trace
//			stack_trace("An emissive appearance was added with non-existant icon_state \"[icon_state]\" in [icon]!")

	return appearance
