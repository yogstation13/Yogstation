/datum/dungeon_room/maintenance
	min_doors = 2

/datum/dungeon_room/maintenance/generate_room_theme()

	if(!room_type)
		if(completed_room && is_ruin_compatible() && prob(75))
			//because ruins are a special type we overwrite the previous flags so the only possible theme is the ruin type
			room_type = ROOM_TYPE_RUIN
		
		else if(completed_room && prob(20))
			room_type = ROOM_TYPE_SPACE
		else
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
