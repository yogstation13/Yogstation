/datum/map_generator/cave_generator/lavaland
	open_turf_types = list(/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1)
	closed_turf_types = list(/turf/closed/mineral/random/volcanic = 1)


	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50, /obj/structure/spawner/lavaland/goliath = 3, \
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 40, /obj/structure/spawner/lavaland = 2, \
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30, /obj/structure/spawner/lavaland/legion = 3, \
		/mob/living/simple_animal/hostile/asteroid/marrowweaver = 30,
		SPAWN_MEGAFAUNA = 4, /mob/living/simple_animal/hostile/asteroid/goldgrub = 10
	)
	flora_spawn_list = list(/obj/structure/flora/ash/leaf_shroom = 2 , /obj/structure/flora/ash/cap_shroom = 2 , /obj/structure/flora/ash/stem_shroom = 2 , /obj/structure/flora/ash/cacti = 1, /obj/structure/flora/ash/tall_shroom = 2)
	///Note that this spawn list is also in the icemoon generator
	feature_spawn_list = list(/obj/structure/geyser/ash = 10, /obj/structure/geyser/random = 2, /obj/structure/geyser/stable_plasma = 6, /obj/structure/geyser/oil = 8,/obj/structure/geyser/protozine = 10,/obj/structure/geyser/holywater = 2) //yogs, yes geysers

	initial_closed_chance = 45
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3

	var/initial_basalt_chance = 40
	var/basalt_smoothing_interations = 100
	var/basalt_birth_limit = 4
	var/basalt_death_limit = 3
	var/basalt_turf = /turf/closed/mineral/random/volcanic/hard

	var/big_node_min = 25
	var/big_node_max = 55

	var/min_offset = 0
	var/max_offset = 5

/datum/map_generator/cave_generator/lavaland/generate_terrain(list/turfs)
	. = ..()
	var/start_time = REALTIMEOFDAY
	var/node_amount = rand(6,10)

	var/list/possible_turfs = turfs.Copy()
	for(var/node=1 to node_amount)
		var/turf/picked_turf = pick_n_take(possible_turfs)
		if(!picked_turf)
			continue
		//time for bounds
		var/size_x = rand(big_node_min,big_node_max)
		var/size_y = rand(big_node_min,big_node_max)

		//time for noise
		var/node_gen = rustg_cnoise_generate("[initial_basalt_chance]", "[basalt_smoothing_interations]", "[basalt_birth_limit]", "[basalt_death_limit]", "[size_x + 1]", "[size_y + 1]")
		var/list/changing_turfs = block(locate(picked_turf.x - round(size_x/2),picked_turf.y - round(size_y/2),picked_turf.z),locate(picked_turf.x + round(size_x/2),picked_turf.y + round(size_y/2),picked_turf.z))
		for(var/turf/T in changing_turfs) //shitcode
			if(!ismineralturf(T))
				continue
			var/index = changing_turfs.Find(T)
			var/hardened = text2num(node_gen[index])
			if(!hardened)
				continue
			var/hard_path = text2path("[T.type]/hard")
			if(!ispath(hard_path)) //erm what the shit we dont have a hard type
				continue
			var/turf/new_turf = hard_path
			new_turf = T.ChangeTurf(new_turf, initial(new_turf.baseturfs), CHANGETURF_DEFER_CHANGE)

	var/message = "Basalt generation finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, span_boldannounce("[message]"))
	log_world(message)
