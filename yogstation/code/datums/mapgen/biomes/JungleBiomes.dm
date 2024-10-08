/datum/biome/jungleland
	/// how dense the closed turf is relative to the open turf
	var/cellular_noise_map_id = MED_DENSITY
	var/turf/closed_turf = /turf/closed/mineral/random

	/// Spawns on closed_turf
	var/list/dense_flora = list()
	/// Probability of dense_flora
	var/dense_flora_density = 100

	/// Spawns on turf_type
	var/list/loose_flora = list()
	/// Probability of loose flora
	var/loose_flora_density = 0

	/// If mobs can be spawned on closed_turf tiles
	var/spawn_fauna_on_closed = FALSE
	var/area/jungleland/this_area = /area/jungleland

/datum/biome/jungleland/New()
	. = ..()
	this_area = new this_area()

/datum/biome/jungleland/generate_turf(turf/gen_turf,list/density_map)
	
	var/closed = text2num(density_map[cellular_noise_map_id][world.maxx * (gen_turf.y - 1) + gen_turf.x])
	var/turf/chosen_turf 
	if(closed)
		chosen_turf = closed_turf
		spawn_dense_flora(gen_turf)
	else
		chosen_turf = turf_type
		spawn_loose_flora(gen_turf)
	
	if((!closed || spawn_fauna_on_closed) && length(fauna_types) && prob(fauna_density))
		var/mob/fauna = pickweight(fauna_types)
		new fauna(gen_turf)
	. = gen_turf.ChangeTurf(chosen_turf, initial(chosen_turf.baseturfs), CHANGETURF_DEFER_CHANGE)

/datum/biome/jungleland/proc/spawn_dense_flora(turf/gen_turf)
	if(length(dense_flora)  && prob(dense_flora_density))
		var/obj/structure/flora = pickweight(dense_flora)
		new flora(gen_turf)
	
/datum/biome/jungleland/proc/spawn_loose_flora(turf/gen_turf)
	if(length(loose_flora) && prob(loose_flora_density))
		var/obj/structure/flora = pickweight(loose_flora)
		new flora(gen_turf)

/**
 * Tar wastes
 */
/datum/biome/jungleland/tar_wastes
	turf_type = /turf/open/floor/plating/dirt/jungleland/obsidian
	closed_turf = /turf/open/water/smooth/tar_basin

	loose_flora = list(
		/obj/structure/flora/rock = 2,
		/obj/structure/flora/rock/pile = 2
		)
	loose_flora_density = 10

	fauna_density = 0.5 
	fauna_types = list(
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 33,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast = 33,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 25,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver = 7,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister = 1,
		)

	this_area = /area/jungleland/tar_wastes

/**
 * Dry swamp
 */
/datum/biome/jungleland/dry_swamp
	turf_type = /turf/open/floor/plating/dirt/jungleland/deep_sand
	closed_turf = /turf/open/water/smooth/toxic_pit
	cellular_noise_map_id = LOW_DENSITY

	dense_flora = list(
		/obj/structure/flora/rock/pile = 10,
		/obj/structure/flora/rock/jungle = 5,
		/obj/structure/flora/rock = 5,
		/obj/structure/flora/ausbushes/stalkybush = 5,
		/obj/structure/herb/magnus_purpura = 1
		)
	dense_flora_density = 10

	loose_flora = list(
		/obj/structure/flora/rock = 20,
		/obj/structure/flora/rock/jungle = 20,
		/obj/structure/flora/rock/pile = 20,
		/obj/structure/flora/stump = 20,
		/obj/structure/flora/tree/jungle/small = 10,
		/obj/structure/herb/lantern = 2,
		/obj/structure/herb/cinchona = 1,
		/obj/structure/flytrap = 1
		)
	loose_flora_density = 10

	fauna_types = list(
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/emeraldspider = 15,
		/mob/living/simple_animal/hostile/asteroid/wasp/mosquito = 15, 
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby = 10,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha = 10,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister = 1
		)
	fauna_density = 0.4

	spawn_fauna_on_closed = TRUE
	this_area = /area/jungleland/dry_swamp

/**
 * Toxic pit
 */
/datum/biome/jungleland/toxic_pit
	turf_type = /turf/open/floor/plating/dirt/jungleland/shallow_mud
	closed_turf = /turf/open/water/smooth/toxic_pit

	dense_flora = list(
		/obj/structure/flora/ausbushes/stalkybush = 10,
		/obj/structure/flora/ausbushes/reedbush = 10,
		/obj/structure/herb/magnus_purpura = 1
		)
	dense_flora_density = 15

	loose_flora = list(
		/obj/structure/flora/rock/jungle = 30,
		/obj/structure/flora/rock = 15,
		/obj/structure/flora/ausbushes = 10,
		/obj/structure/flora/ausbushes/fernybush = 10,
		/obj/structure/herb/liberal_hats = 10,
		/obj/structure/flora/tree/jungle/small = 5,
		/obj/structure/herb/lantern = 4,
		/obj/structure/flytrap = 2,
		/obj/structure/herb/explosive_shrooms = 1,
		/obj/structure/flora/tree/jungle = 1
		)
	loose_flora_density = 20

	fauna_types = list(
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/meduracha = 50,
		/mob/living/simple_animal/hostile/asteroid/wasp/mosquito = 40,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/blobby = 25,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/emeraldspider = 2,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister = 1
		)
	fauna_density = 0.7

	spawn_fauna_on_closed = TRUE
	this_area = /area/jungleland/toxic_pit

/**
 * Dying forest
 */
/datum/biome/jungleland/dying_forest
	turf_type = /turf/open/floor/plating/dirt/jungleland/deep_sand
	closed_turf = /turf/open/floor/plating/dirt/jungleland/shallow_mud
	cellular_noise_map_id = LOW_DENSITY

	dense_flora = list(
		/obj/structure/flora/tree/dead/jungle = 8,
		/obj/structure/flora/tree/jungle/small = 4,
		/obj/structure/flora/stump=4,
		/obj/structure/herb/cinchona = 1
		)
	dense_flora_density = 90

	loose_flora = list(
		/obj/structure/flora/rock/jungle = 2,
		/obj/structure/flora/rock/pile = 2,
		/obj/structure/flora/rock = 1,
		)
	loose_flora_density = 20

	fauna_types = list(
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/corrupted_dryad = 60,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 30,
		/mob/living/simple_animal/hostile/asteroid/wasp/mosquito = 10,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister = 1
		)
	fauna_density = 0.8
	this_area = /area/jungleland/dying_forest

/**
 * Jungle
 */
/datum/biome/jungleland/jungle
	turf_type = /turf/open/floor/plating/dirt/jungleland/jungle
	closed_turf = /turf/open/floor/plating/dirt/jungleland/jungle
	cellular_noise_map_id = HIGH_DENSITY

	dense_flora = list(
		/obj/structure/flora/tree/jungle = 6, 
		/obj/structure/flora/junglebush/large = 2, 
		/obj/structure/flora/rock/pile/largejungle = 2,
		/obj/structure/flora/junglebush = 1, 
		/obj/structure/flora/junglebush/b = 1, 
		/obj/structure/flora/junglebush/c = 1
		)
	dense_flora_density = 70

	loose_flora = list(
		/obj/structure/flora/grass/jungle = 60,
		/obj/structure/flora/grass/jungle/b = 40,
		/obj/structure/flora/ausbushes = 40,
		/obj/structure/flora/ausbushes/leafybush = 20,
		/obj/structure/flora/ausbushes/sparsegrass = 20,
		/obj/structure/flora/ausbushes/fullgrass = 20,
		/obj/structure/flora/ausbushes/fernybush = 20,
		/obj/structure/herb/lantern = 5,
		/obj/structure/herb/fruit = 5,
		/obj/structure/flytrap = 2,
		/obj/structure/herb/explosive_shrooms = 1
		)
	loose_flora_density = 60

	fauna_types = list(
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/dryad = 65,
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/emeraldspider = 15,
		/mob/living/simple_animal/hostile/asteroid/wasp/mosquito = 10, 
		/mob/living/simple_animal/hostile/asteroid/wasp/yellowjacket = 10, 
		/mob/living/simple_animal/hostile/asteroid/yog_jungle/skin_twister = 1,
		)
	fauna_density = 0.65
	this_area = /area/jungleland/proper
