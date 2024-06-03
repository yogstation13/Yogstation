/datum/dungeon_room/maintenance
	min_doors = 2

/datum/dungeon_room/maintenance/generate_room_theme()

	if(!room_type)
		var/list/room_types = generator_ref.probability_room_types

		//if the room is a completed room, decide what special room type it should roll
		if(completed_room)
			for(var/type_check in room_types) //go through all types that the generator allows
				if(type_check == ROOM_TYPE_RUIN && !is_ruin_compatible()) //the ruin type is special and needs to have a specific shape of room to work
					continue
				if(prob(room_types[type_check])) //get the probability of that ruin type from the list
					room_type = type_check

		if(!room_type) //if a room type wasn't picked, default to random
			room_type = ROOM_TYPE_RANDOM
	
	if(!room_danger_level)
		if(completed_room && prob(50))
			room_danger_level = ROOM_RATING_HOSTILE
		else
			room_danger_level = ROOM_RATING_SAFE

	var/list/possible_themes = list()
	for(var/datum/dungeon_room_theme/potential_theme as anything in typecacheof(list(generator_ref.room_theme_path), TRUE))
		if((room_type == initial(potential_theme.room_type)) && (room_danger_level & (initial(potential_theme.room_danger_level))))
			possible_themes |= potential_theme
	
	var/new_theme_path = pick(possible_themes)
	room_theme = new new_theme_path(src)
	room_theme.Initialize()

/datum/dungeon_room/maintenance/is_ruin_compatible()
	var/width_without_walls = width-2
	var/height_without_walls = height-2
	var/compatible = FALSE
	switch("[width_without_walls]x[height_without_walls]")
		if("3x3")
			compatible = TRUE
		if("3x5")
			compatible = TRUE
		if("5x3")
			compatible = TRUE
		if("5x4")
			compatible = TRUE
		if("10x5")
			compatible = TRUE
		if("10x10")
			compatible = TRUE
	return (compatible && completed_room)
