/datum/dungeon_room_theme/maintenance/space
	room_type = ROOM_TYPE_SPACE
	weighted_possible_floor_types = list(/turf/open/space/basic = 1)
	//no doors to space rooms
	weighted_possible_door_types = list()
	weighted_possible_window_types = list(/obj/effect/spawner/structure/window/reinforced/shutter = 1)
	//no mobs in space, althought if i find a way to percent chance spawn a mob, i might make a space cat spawn
	weighted_mob_spawn_list = list()
	window_weight = 80

/datum/dungeon_room_theme/maintenance/space/pre_initialize()
	. = ..()
	for(var/turf/turf_between_space in dungeon_room_ref.exterior)
		var/turf/turf_outside_room = get_step(turf_between_space, get_dir(dungeon_room_ref.center, turf_between_space))
		if(isspaceturf(turf_outside_room))
			dungeon_room_ref.exterior -= turf_between_space
			

/datum/dungeon_room_theme/maintenance/space/post_generate()
	. = ..()
	for(var/turf/space_to_check in dungeon_room_ref.interior)
		var/needs_catwalk = FALSE

		if(locate(/obj/machinery/atmospherics/pipe) in space_to_check)	
			needs_catwalk = TRUE
		else if (locate(/obj/structure/cable) in space_to_check)	
			needs_catwalk = TRUE
		else
			continue
		if(needs_catwalk && !locate(/obj/structure/lattice/catwalk) in space_to_check)	
			for(var/obj/structure/lattice/existing_lattice in space_to_check)
				qdel(existing_lattice)
			new /obj/structure/lattice/catwalk(space_to_check)
	
/datum/dungeon_room_theme/maintenance/space/basic
	weighted_feature_spawn_list = list(
		/obj/structure/lattice = 10,
		/obj/item/stack/ore/glass = 3,
		/obj/item/tank/internals/emergency_oxygen = 1,
		)
	

/datum/dungeon_room_theme/maintenance/space/basic/pre_initialize()
	. = ..()
	switch(rand(1,10))
		if(1)
			//the blessed space cat
			weighted_feature_spawn_list += /mob/living/simple_animal/pet/cat/space
		if(2)
			//a "dolphin"
			weighted_feature_spawn_list += /mob/living/simple_animal/hostile/retaliate/dolphin/bouncer
		if(3 to 4)
			//TWO DOLPHS
			for(var/x in 1 to 3)
			weighted_feature_spawn_list += pick(/mob/living/simple_animal/hostile/retaliate/dolphin, /mob/living/simple_animal/hostile/retaliate/dolphin/manatee)
		if(5 to 6)
			//a dolphino
			weighted_feature_spawn_list += pick(/mob/living/simple_animal/hostile/retaliate/dolphin, /mob/living/simple_animal/hostile/retaliate/dolphin/manatee)
		else
			//you get nothing good day sir
		

/datum/dungeon_room_theme/maintenance/space/hostile
	room_type = ROOM_RATING_HOSTILE
	weighted_feature_spawn_list = list(
		/obj/structure/lattice = 10,
		/obj/item/stack/ore/glass = 3,
		/obj/item/tank/internals/emergency_oxygen = 1,
		/obj/effect/mob_spawn/human/corpse = 2,
		)
	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/carp = 1,
	)
	mob_spawn_chance = 50
