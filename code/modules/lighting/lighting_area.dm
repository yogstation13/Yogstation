/area
	luminosity           = TRUE
	var/dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	var/fullbright_type = FULLBRIGHT_DEFAULT

/area/proc/set_dynamic_lighting(new_dynamic_lighting = DYNAMIC_LIGHTING_ENABLED)
	if (new_dynamic_lighting == dynamic_lighting)
		return FALSE

	dynamic_lighting = new_dynamic_lighting

	if (IS_DYNAMIC_LIGHTING(src))
		cut_overlay(GLOB.fullbright_overlay)
		cut_overlay(GLOB.starlight_overlay)
		for(var/turf/T as anything in get_contained_turfs())
			if (!T.fullbright_type)
				T.lighting_build_overlay()

	else
		if (fullbright_type == FULLBRIGHT_STARLIGHT)
			add_overlay(GLOB.starlight_overlay)
		else
			add_overlay(GLOB.fullbright_overlay)
		for(var/turf/T as anything in get_contained_turfs())
			if (T.lighting_object)
				T.lighting_clear_overlay()

	return TRUE

/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("dynamic_lighting")
			set_dynamic_lighting(var_value)
			return TRUE
	return ..()
