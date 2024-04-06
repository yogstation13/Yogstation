/datum/dungeon_room_theme/maintenance
	room_type = ROOM_TYPE_RANDOM
	room_danger_level = ROOM_RATING_SAFE | ROOM_RATING_HOSTILE

	weighted_possible_floor_types = list(/turf/open/floor/plasteel/dark = 5, /turf/open/floor/plating = 5)

	weighted_possible_window_types = list(/obj/effect/spawner/structure/window/reinforced = 2, /obj/effect/spawner/structure/window = 5)
	window_weight = 10

	weighted_possible_door_types = list(/obj/machinery/door/airlock/maintenance_hatch = 1)
	feature_weight = 80
	mob_spawn_chance = 50
