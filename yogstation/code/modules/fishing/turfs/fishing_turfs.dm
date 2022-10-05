/turf/open/water/safe
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE

/turf/open/water/safe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/fishable)
	
/turf/open/lava/smooth/lava_land_surface/Initialize(mapload)
	. = ..()
	if(prob(1))
		AddComponent(/datum/component/fishable, "lavaland")
