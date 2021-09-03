/datum/biome/jungleland
	var/cellular_noise_map_id = MED_DENSITY
	var/turf/closed_turf = /turf/closed/mineral/random
	var/list/dense_flora = list()
	var/list/loose_flora = list()
	var/loose_flora_density = 0 // from 0 to 100

/datum/biome/jungleland/generate_turf(turf/gen_turf,list/density_map)
	
	var/closed = text2num(density_map[cellular_noise_map_id][world.maxx * (gen_turf.y - 1) + gen_turf.x])
	var/chosen_turf 
	if(closed)
		chosen_turf = closed_turf
		spawn_dense_flora(gen_turf)
	else
		chosen_turf = turf_type
		spawn_loose_flora(gen_turf)

	gen_turf.ChangeTurf(chosen_turf, null, CHANGETURF_DEFER_CHANGE)

/datum/biome/jungleland/proc/spawn_dense_flora(turf/gen_turf)
	if(length(dense_flora))
		var/obj/structure/flora = pick(dense_flora)
		new flora(gen_turf)
	
/datum/biome/jungleland/proc/spawn_loose_flora(turf/gen_turf)
	if(length(loose_flora) && prob(loose_flora_density))
		var/obj/structure/flora = pick(loose_flora)
		new flora(gen_turf)

/datum/biome/jungleland/barren_rocks
	turf_type = /turf/open/floor/plating/dirt/jungleland/barren_rocks
	cellular_noise_map_id = LOW_DENSITY

/datum/biome/jungleland/toxic_rocks
	turf_type = /turf/open/floor/plating/dirt/jungleland/toxic_rocks
	cellular_noise_map_id = LOW_DENSITY

/datum/biome/jungleland/dry_swamp
	turf_type = /turf/open/floor/plating/dirt/jungleland/dry_swamp

/datum/biome/jungleland/toxic_pit
	turf_type = /turf/open/floor/plating/dirt
	closed_turf = /turf/open/water
	loose_flora = list(/obj/structure/flora/ausbushes/stalkybush)
	loose_flora_density = 10

/datum/biome/jungleland/dying_forest
	turf_type = /turf/open/floor/plating/ironsand
	closed_turf = /turf/open/floor/plating/dirt
	dense_flora = list(/obj/structure/flora/tree/dead,/obj/structure/flora/rock/jungle,/obj/structure/flora/rock/pile,/obj/structure/flora/rock,/obj/structure/flora/tree/jungle)
	
/datum/biome/jungleland/jungle
	turf_type = /turf/open/floor/grass
	closed_turf = /turf/open/floor/plating/dirt
	cellular_noise_map_id = HIGH_DENSITY
	dense_flora = list(/obj/structure/flora/tree/jungle, /obj/structure/flora/rock/jungle, /obj/structure/flora/junglebush, /obj/structure/flora/junglebush/b, /obj/structure/flora/junglebush/c, /obj/structure/flora/junglebush/large, /obj/structure/flora/rock/pile/largejungle)
	loose_flora = list(/obj/structure/flora/grass/jungle,/obj/structure/flora/grass/jungle/b,/obj/structure/flora/grass/brown,/obj/structure/flora/bush,/obj/structure/flora/ausbushes,/obj/structure/flora/ausbushes/leafybush,/obj/structure/flora/ausbushes/reedbush,/obj/structure/flora/ausbushes/grassybush,/obj/structure/flora/ausbushes/sunnybush,/obj/structure/flora/ausbushes/pointybush,/obj/structure/flora/ausbushes/genericbush,/obj/structure/flora/ausbushes/ywflowers,/obj/structure/flora/ausbushes/brflowers,/obj/structure/flora/ausbushes/ppflowers,/obj/structure/flora/ausbushes/sparsegrass,/obj/structure/flora/ausbushes/fullgrass)
	loose_flora_density = 25
