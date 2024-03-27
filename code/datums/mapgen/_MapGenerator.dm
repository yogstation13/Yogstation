///This type is responsible for any map generation behavior that is done in areas, override this to allow for area-specific map generation. This generation is ran by areas in initialize.
/datum/map_generator

///This proc will be ran by areas on Initialize, and provides the areas turfs as argument to allow for generation.
/datum/map_generator/proc/generate_terrain(list/turfs, area/generate_in)
	return

///This proc will aggregate areas on the same z-level to share turfs for the purpose of generating the area. Currently just for procedural generation with maints
/datum/map_generator/proc/combine_local_areas()
	return

/turf/open/genturf
	name = "ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders"
	icon = 'icons/turf/debug.dmi'
	icon_state = "genturf"
