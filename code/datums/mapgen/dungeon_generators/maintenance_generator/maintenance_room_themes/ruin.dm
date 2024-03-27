/datum/dungeon_room_theme/maintenance/ruin
	room_type = ROOM_TYPE_RUIN
	
/datum/dungeon_room_theme/maintenance/ruin/pre_initialize()
	. = ..()
	var/width_without_walls = dungeon_room_ref.width-2
	var/height_without_walls = dungeon_room_ref.height-2
	
	switch("[width_without_walls]x[height_without_walls]")
		if("3x3")
			special_feature = /obj/effect/landmark/stationroom/maint/threexthree
		if("3x5")
			special_feature = /obj/effect/landmark/stationroom/maint/threexfive
		if("5x3")
			special_feature = /obj/effect/landmark/stationroom/maint/fivexthree
		if("5x4")
			special_feature = /obj/effect/landmark/stationroom/maint/fivexfour
		if("10x5")
			special_feature = /obj/effect/landmark/stationroom/maint/tenxfive
		if("10x10")
			special_feature = /obj/effect/landmark/stationroom/maint/tenxten

/datum/dungeon_room_theme/maintenance/ruin/post_generate()
	. = ..()
	for(var/datum/weakref/spawner_ref as anything in dungeon_room_ref.features)
		var/obj/effect/landmark/stationroom/spawner = spawner_ref.resolve()
		if(spawner)
			spawner.unique = FALSE
			spawner.load()
			// if(spawner.load())
			// 	dungeon_room_ref.features -= spawner
