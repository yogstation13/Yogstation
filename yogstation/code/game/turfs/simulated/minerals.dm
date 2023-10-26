/turf/closed/mineral/dilithium
	mineralType = /obj/item/stack/ore/dilithium_crystal
	mineralAmt = 2
	spreadChance = 0
	spread = 0
	scan_state = "rock_Dilithium" 

/turf/closed/mineral/dilithium/volcanic // The OOP around this shit is dumb as all hell by the way. Every single mineral type has to copy-paste this shit.
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1

/turf/closed/mineral/dilithium/volcanic/hard
	smooth_icon = 'icons/turf/smoothrocks_hard.dmi'
	hardness = 2

/turf/closed/mineral/dilithium/volcanic/hard/harder
	smooth_icon = 'icons/turf/smoothrocks.dmi'
	mineralAmt = 5
	color = "#eb9877"
	hardness = 3

/turf/closed/mineral/dilithium/ice
	environment_type = "snow_cavern"
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/dilithium/ice/icemoon
	turf_type = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/dilithium/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1
