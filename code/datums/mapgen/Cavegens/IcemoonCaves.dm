/datum/map_generator/cave_generator/icemoon
	weighted_open_turf_types = list(/turf/open/floor/plating/asteroid/snow/icemoon = 19, /turf/open/floor/plating/ice/icemoon = 1)
	weighted_closed_turf_types = list(/turf/closed/mineral/random/snow = 1)


	weighted_mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/wolf = 50, /obj/structure/spawner/ice_moon = 3, \
						  /mob/living/simple_animal/hostile/asteroid/polarbear = 30, /obj/structure/spawner/ice_moon/polarbear = 3, \
						  /mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50, 
						  /mob/living/simple_animal/hostile/asteroid/marrowweaver/ice = 30,
						  /mob/living/simple_animal/hostile/asteroid/goldgrub = 10,
						  /mob/living/simple_animal/hostile/asteroid/ambusher = 10)
	weighted_flora_spawn_list = list(/obj/structure/flora/tree/pine = 2, /obj/structure/flora/rock/icy = 2, /obj/structure/flora/rock/pile/icy = 2, /obj/structure/flora/grass/both = 6)
	///Note that this spawn list is also in the lavaland generator
	weighted_feature_spawn_list = null

	var/initial_basalt_chance = 40
	var/basalt_smoothing_interations = 100
	var/basalt_birth_limit = 4
	var/basalt_death_limit = 3
	var/basalt_turf = /turf/closed/mineral/random/snow/hard/icemoon

	var/big_node_min = 25
	var/big_node_max = 55

	var/min_offset = 0
	var/max_offset = 5

/datum/map_generator/cave_generator/icemoon/generate_terrain(list/turfs) //literally just the lavaland one before it had granite i'll add something for granite later
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
		for(var/turf/T in changing_turfs) //ccopy and pasted shitcode
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

	var/message = "IceMoon Auxiliary generation finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, span_boldannounce("[message]"))
	log_world(message)


/datum/map_generator/cave_generator/icemoon/surface
	flora_spawn_chance = 4
	weighted_mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/wolf = 50, /obj/structure/spawner/ice_moon = 3, \
						  /mob/living/simple_animal/hostile/asteroid/polarbear = 30, /obj/structure/spawner/ice_moon/polarbear = 3, \
						  /mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50, 
						  /mob/living/simple_animal/hostile/asteroid/marrowweaver/ice = 30,
						  /mob/living/simple_animal/hostile/asteroid/goldgrub = 10,
						  /mob/living/simple_animal/hostile/asteroid/ambusher = 2)
	initial_closed_chance = 53
	birth_limit = 5
	death_limit = 4
	smoothing_iterations = 10

/datum/map_generator/cave_generator/icemoon/top_layer
	flora_spawn_chance = 4
	initial_closed_chance = 53
	birth_limit = 5
	death_limit = 4
	smoothing_iterations = 10
	weighted_open_turf_types = list(/turf/open/floor/plating/asteroid/snow/icemoon/top_layer = 19, /turf/open/floor/plating/ice/icemoon/top_layer = 1)
	weighted_closed_turf_types = list(/turf/closed/mineral/random/snow/top_layer = 1)

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
