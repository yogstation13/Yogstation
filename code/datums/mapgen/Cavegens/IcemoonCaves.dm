/datum/map_generator/cave_generator/icemoon
	open_turf_types = list(/turf/open/floor/plating/asteroid/snow/icemoon = 19, /turf/open/floor/plating/ice/icemoon = 1)
	closed_turf_types = list(/turf/closed/mineral/random/snow = 1)


	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/wolf = 50, /obj/structure/spawner/ice_moon = 3, \
						  /mob/living/simple_animal/hostile/asteroid/polarbear = 30, /obj/structure/spawner/ice_moon/polarbear = 3, \
						  /mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50, 
						  /mob/living/simple_animal/hostile/asteroid/marrowweaver/ice = 30,
						  /mob/living/simple_animal/hostile/asteroid/goldgrub = 10)
	flora_spawn_list = list(/obj/structure/flora/tree/pine = 2, /obj/structure/flora/rock/icy = 2, /obj/structure/flora/rock/pile/icy = 2, /obj/structure/flora/grass/both = 6)
	///Note that this spawn list is also in the lavaland generator
	feature_spawn_list = list()

/datum/map_generator/cave_generator/icemoon/surface
	flora_spawn_chance = 4
	mob_spawn_list = null
	initial_closed_chance = 53
	birth_limit = 5
	_limit = 4
	smoothing_iterations = 10


/* WE DONT HAVE A LOT OF THIS STUFF SO IT SHOULD BE PORTED WHEN WE DECIDE TO DO ICEMOON AGAIN
/datum/map_generator/cave_generator/icemoon/deep
	closed_turf_types = list(/turf/closed/mineral/random/snow/underground = 1)
	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/ice_demon = 50, /obj/structure/spawner/ice_moon/demonic_portal = 3, \
						  /mob/living/simple_animal/hostile/asteroid/ice_whelp = 30, /obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 3, \
						  /mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50, /obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 3, \
						  SPAWN_MEGAFAUNA = 2)
	megafauna_spawn_list = list(/mob/living/simple_animal/hostile/megafauna/colossus = 1)
	flora_spawn_list = list(/obj/structure/flora/rock/icy = 6, /obj/structure/flora/rock/pile/icy = 6, /obj/structure/flora/ash/chilly = 1)
*/
