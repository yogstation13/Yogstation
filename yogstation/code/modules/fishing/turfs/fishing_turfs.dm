/turf/open/water/safe
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE

/turf/open/water/safe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/fishable)
	
