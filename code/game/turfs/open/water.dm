/turf/open/water
	gender = PLURAL
	name = "water"
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/chasm/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	turf_flags = NO_RUST

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/water/smooth
	icon = MAP_SWITCH('yogstation/icons/turf/floors/smoothwater.dmi', 'icons/turf/floors.dmi') //uses smoothwater during gameplay and floors.dmi in mapping tools
	icon_state = "riverwater_motion"
	base_icon_state = "smoothwater"
	layer = HIGH_TURF_LAYER //so it draws above other turf
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-6, -6), matrix()) //since smoothwater.dmi is a 44x44 size sprite, we shift it slightly down and to the left so it stays centered

	smoothing_groups = SMOOTH_GROUP_TURF_WATER
	canSmoothWith = SMOOTH_GROUP_TURF_WATER //so it only smooths with other water
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/open/water/safe
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE
	baseturfs = /turf/open/indestructible/grass/sand

/turf/open/water/safe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/fishable)
	
