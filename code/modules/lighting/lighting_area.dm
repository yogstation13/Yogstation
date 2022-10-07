GLOBAL_DATUM_INIT(fullbright_overlay, /mutable_appearance, create_fullbright_overlay())

/proc/create_fullbright_overlay()
	var/mutable_appearance/lighting_effect = mutable_appearance('icons/effects/alphacolors.dmi', "white")
	lighting_effect.plane = LIGHTING_PLANE
	lighting_effect.layer = LIGHTING_LAYER
	lighting_effect.blend_mode = BLEND_ADD
	return lighting_effect


/area
	luminosity           = TRUE
	var/dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/proc/set_dynamic_lighting(var/new_dynamic_lighting = DYNAMIC_LIGHTING_ENABLED)
	if (new_dynamic_lighting == dynamic_lighting)
		return FALSE

	dynamic_lighting = new_dynamic_lighting

	if (IS_DYNAMIC_LIGHTING(src))
		cut_overlay(/obj/effect/fullbright)
		for (var/turf/T in src)
			if (IS_DYNAMIC_LIGHTING(T))
				T.lighting_build_overlay()

	else
		add_overlay(/obj/effect/fullbright)
		for (var/turf/T in src)
			if (T.lighting_object)
				T.lighting_clear_overlay()

	return TRUE

/area/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("dynamic_lighting")
			set_dynamic_lighting(var_value)
			return TRUE
	return ..()
