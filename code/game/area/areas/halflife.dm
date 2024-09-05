/area/halflife
	name = "\improper Unexplored Location"
	icon_state = "away"
	has_gravity = TRUE
	hidden = FALSE
	ambience_index = AMBIENCE_HLOUTSIDE
	flags_1 = CAN_BE_DIRTY_1
	requires_power = FALSE
	lights_always_start_on = TRUE

/area/halflife/outdoors
	name = "\improper Unexplored Location"
	static_lighting = TRUE
	outdoors = TRUE
	uses_daylight = TRUE
	base_lighting_alpha = 0
	sound_environment = SOUND_ENVIRONMENT_CITY
	light_power = 0.1
	light_range = 2
	light_color = COLOR_STARLIGHT

/area/halflife/indoors
	name = "\improper Indoors"
	icon_state = "away"
	base_lighting_alpha = 15
	light_power = 0.1
	light_range = 2
	ambience_index = AMBIENCE_HLINSIDE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/halflife/indoors/sewer
	name = "\improper Sewer"
	base_lighting_alpha = 5
	max_ambience_cooldown = 90 SECONDS
	icon_state = "away"
	ambience_index = AMBIENCE_HLSEWERS
	sound_environment = SOUND_ENVIRONMENT_STONE_CORRIDOR
