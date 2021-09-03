/datum/biome/jungleland
	var/cellular_noise_map_id = MED_DENSITY
	var/turf/closed_turf = /turf/closed/mineral/random

/datum/biome/jungleland/generate_turf(turf/gen_turf,list/density_map)
	
	var/closed = text2num(density_map[cellular_noise_map_id][world.maxx * (gen_turf.y - 1) + gen_turf.x])
	if(closed)
		turf_type = closed_turf
	else
		turf_type = initial(turf_type)
	return ..()

/datum/biome/jungleland/barren_rocks
	turf_type = /turf/open/floor/plating/dirt/jungleland/barren_rocks
	cellular_noise_map_id = LOW_DENSITY

/datum/biome/jungleland/toxic_rocks
	turf_type = /turf/open/floor/plating/dirt/jungleland/toxic_rocks
	cellular_noise_map_id = LOW_DENSITY

/datum/biome/jungleland/dry_swamp
	turf_type = /turf/open/floor/plating/dirt/jungleland/dry_swamp

/datum/biome/jungleland/toxic_pit
	turf_type = /turf/open/floor/plating/dirt/jungleland/toxic_pit

/datum/biome/jungleland/dying_forest
	turf_type = /turf/open/floor/plating/dirt/jungleland/dying_forest

/datum/biome/jungleland/jungle
	turf_type = /turf/open/floor/plating/dirt/jungleland/jungle
	cellular_noise_map_id = HIGH_DENSITY
