/**
 * Space Initialize
 *
 * Doesn't call parent, see [/atom/proc/Initialize].
 * When adding new stuff to /atom/Initialize, /turf/Initialize, etc
 * don't just add it here unless space actually needs it.
 *
 * There is a lot of work that is intentionally not done because it is not currently used.
 * This includes stuff like smoothing, blocking camera visibility, etc.
 * If you are facing some odd bug with specifically space, check if it's something that was
 * intentionally ommitted from this implementation.
 */
/turf/open/space/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	icon_state = SPACE_ICON_STATE
	if(!space_gas)
		space_gas = new
	air = space_gas
	update_air_ref(0)
	vis_contents.Cut() //removes inherited overlays
	visibilityChanged()

	if (PERFORM_ALL_TESTS(focus_only/multiple_space_initialization))
		if(flags_1 & INITIALIZED_1)
			stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	var/area/our_area = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(our_area))
		add_overlay(/obj/effect/fullbright)

	if (light_system == STATIC_LIGHT && light_power && light_range)
		update_light()

	if (opacity)
		directional_opacity = ALL_CARDINALS
	
	if (!mapload)
		// if(requires_activation)
		// 	SSair.add_to_active(src, TRUE)

		if(SSmapping.max_plane_offset)
			var/turf/T = GET_TURF_ABOVE(src)
			if(T)
				T.multiz_turf_new(src, DOWN)
			T = GET_TURF_BELOW(src)
			if(T)
				T.multiz_turf_new(src, UP)

	return INITIALIZE_HINT_NORMAL
