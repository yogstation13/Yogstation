/datum/map_generator/cave_generator/lavaland
	open_turf_types = list(/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1)
	closed_turf_types = list(/turf/closed/mineral/random/volcanic = 1)


	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50, /obj/structure/spawner/lavaland/goliath = 3, \
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 40, /obj/structure/spawner/lavaland = 2, \
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30, /obj/structure/spawner/lavaland/legion = 3, \
		SPAWN_MEGAFAUNA = 4, /mob/living/simple_animal/hostile/asteroid/goldgrub = 10
	)
	flora_spawn_list = list(/obj/structure/flora/ash/leaf_shroom = 2 , /obj/structure/flora/ash/cap_shroom = 2 , /obj/structure/flora/ash/stem_shroom = 2 , /obj/structure/flora/ash/cacti = 1, /obj/structure/flora/ash/tall_shroom = 2)
	///Note that this spawn list is also in the icemoon generator
	//feature_spawn_list = list(/obj/structure/geyser/wittel = 6, /obj/structure/geyser/random = 2, /obj/structure/geyser/plasma_oxide = 10, /obj/structure/geyser/protozine = 10, /obj/structure/geyser/hollowwater = 10)
	feature_spawn_list = list(/obj/structure/geyser/random = 1)

	initial_closed_chance = 45
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3

	var/initial_basalt_chance = 40
	var/basalt_smoothing_interations = 100
	var/basalt_turf = /turf/closed/mineral/random/volcanic/hard

/datum/map_generator/cave_generator/lavaland/generate_terrain(list/turfs)
	. = ..()
	var/basalt_gen = rustg_cnoise_generate("[initial_basalt_chance]", "[basalt_smoothing_interations]", "[birth_limit]", "[death_limit]", "[world.maxx]", "[world.maxy]")

	for(var/i in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = i

		var/area/A = gen_turf.loc
		if(!(A.area_flags & CAVES_ALLOWED))
			continue

		var/hardened = text2num(basalt_gen[world.maxx * (gen_turf.y - 1) + gen_turf.x])

		if(!hardened)
			continue
		if(!istype(gen_turf,/turf/closed/mineral/random/volcanic))
			continue

		var/stored_flags
		if(gen_turf.flags_1 & NO_RUINS_1)
			stored_flags |= NO_RUINS_1

		var/turf/new_turf = basalt_turf

		new_turf = gen_turf.ChangeTurf(new_turf, initial(new_turf.baseturfs), CHANGETURF_DEFER_CHANGE)

		new_turf.flags_1 |= stored_flags
