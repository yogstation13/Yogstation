/datum/biome/jungleland
	var/cellular_noise_map_id = MED_DENSITY
	var/turf/closed_turf = /turf/closed/mineral/random
	var/list/dense_flora = list()
	var/list/loose_flora = list()
	var/loose_flora_density = 0 // from 0 to 100
	var/dense_flora_density = 100
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

/datum/biome/jungleland/barren_rocks
	turf_type = /turf/open/floor/plating/dirt/jungleland/barren_rocks
	loose_flora = list(/obj/structure/flora/rock = 2,/obj/structure/flora/rock/pile = 2)
	loose_flora_density = 10
	cellular_noise_map_id = LOW_DENSITY
	fauna_density = 1 
	fauna_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 33,/mob/living/simple_animal/hostile/asteroid/goliath/beast = 33,/mob/living/simple_animal/hostile/asteroid/goldgrub = 32,/mob/living/simple_animal/hostile/yog_jungle/skin_twister = 1)
	this_area = /area/jungleland/barren_rocks

/datum/biome/jungleland/dry_swamp
	turf_type = /turf/open/floor/plating/dirt/jungleland/dry_swamp
	closed_turf = /turf/open/floor/plating/dirt/jungleland/dry_swamp1
	dense_flora = list(/obj/structure/flora/rock = 2,/obj/structure/flora/rock/jungle = 1,/obj/structure/flora/rock/pile = 2)
	loose_flora = list(/obj/structure/flora/ausbushes/stalkybush = 2,/obj/structure/flora/rock = 2,/obj/structure/flora/rock/jungle = 2,/obj/structure/flora/rock/pile = 2,/obj/structure/flora/stump=2,/obj/structure/flora/tree/jungle = 1,/obj/structure/herb/cinchona = 0.1)
	dense_flora_density = 10
	loose_flora_density = 10
	fauna_types = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast = 39,/mob/living/simple_animal/hostile/asteroid/goldgrub = 34,/mob/living/simple_animal/hostile/yog_jungle/meduracha = 10,/mob/living/simple_animal/hostile/yog_jungle/skin_twister = 1,/mob/living/simple_animal/hostile/yog_jungle/mosquito = 16)
	fauna_density = 0.8
	spawn_fauna_on_closed = TRUE
	this_area = /area/jungleland/dry_swamp

/datum/biome/jungleland/toxic_pit
	turf_type = /turf/open/floor/plating/dirt/jungleland/toxic_pit
	closed_turf = /turf/open/water/toxic_pit
	loose_flora = list(/obj/structure/flora/ausbushes/stalkybush = 2,/obj/structure/flora/rock = 2,/obj/structure/flora/rock/jungle = 2,/obj/structure/flora/rock/pile = 2,/obj/structure/flora/stump=2,/obj/structure/flora/tree/jungle = 1,/obj/structure/herb/explosive_shrooms = 0.2,/obj/structure/herb/cinchona = 0.2,/obj/structure/herb/liberal_hats = 0.2)
	dense_flora = list(/obj/structure/flora/ausbushes/stalkybush = 1)
	loose_flora_density = 15
	dense_flora_density = 10
	fauna_types = list(/mob/living/simple_animal/hostile/yog_jungle/blobby = 20,/mob/living/simple_animal/hostile/yog_jungle/meduracha = 50,/mob/living/simple_animal/hostile/yog_jungle/skin_twister = 2,/mob/living/simple_animal/hostile/yog_jungle/mosquito = 48)
	fauna_density = 1.5
	spawn_fauna_on_closed = TRUE
	this_area = /area/jungleland/toxic_pit

/datum/biome/jungleland/dying_forest
	turf_type = /turf/open/floor/plating/dirt/jungleland/dying_forest
	closed_turf = /turf/open/floor/plating/dirt/jungleland/dying_forest
	dense_flora = list(/obj/structure/flora/stump=1,/obj/structure/flora/tree/dead/jungle = 2,/obj/structure/flora/rock/jungle = 2,/obj/structure/flora/rock/pile = 2,/obj/structure/flora/rock = 2,/obj/structure/flora/tree/jungle/small = 1,/obj/structure/herb/cinchona = 0.1)
	dense_flora_density = 70
	fauna_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing = 39,/mob/living/simple_animal/hostile/yog_jungle/corrupted_dryad = 55,/mob/living/simple_animal/hostile/yog_jungle/skin_twister = 1,/mob/living/simple_animal/hostile/yog_jungle/mosquito = 5)
	fauna_density = 1.3
	this_area = /area/jungleland/dying_forest

/datum/biome/jungleland/jungle
	turf_type = /turf/open/floor/plating/dirt/jungleland/jungle
	closed_turf = /turf/open/floor/plating/dirt/jungleland/jungle
	cellular_noise_map_id = HIGH_DENSITY
	dense_flora = list(/obj/structure/flora/tree/jungle/small = 2,/obj/structure/flora/tree/jungle = 2, /obj/structure/flora/rock/jungle = 1, /obj/structure/flora/junglebush = 1, /obj/structure/flora/junglebush/b = 1, /obj/structure/flora/junglebush/c = 1, /obj/structure/flora/junglebush/large = 1, /obj/structure/flora/rock/pile/largejungle = 1)
	loose_flora = list(/obj/structure/flora/grass/jungle = 2,/obj/structure/flora/grass/jungle/b = 2,/obj/structure/flora/grass/brown = 1,/obj/structure/flora/bush = 1,/obj/structure/flora/ausbushes = 1,/obj/structure/flora/ausbushes/leafybush = 1,/obj/structure/flora/ausbushes/sparsegrass = 1,/obj/structure/flora/ausbushes/fullgrass = 1,/obj/structure/herb/explosive_shrooms = 0.1,/obj/structure/herb/cinchona = 0.1,/obj/structure/herb/liberal_hats = 0.1)
	loose_flora_density = 60
	fauna_types = list(/mob/living/simple_animal/hostile/yog_jungle/blobby = 10 ,/mob/living/simple_animal/hostile/yog_jungle/dryad = 69 ,/mob/living/simple_animal/hostile/yog_jungle/skin_twister = 1,/mob/living/simple_animal/hostile/yog_jungle/mosquito = 20)
	fauna_density = 1.4
	this_area = /area/jungleland/proper
