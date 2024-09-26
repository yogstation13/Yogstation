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
	name = "\improper Outdoors"
	static_lighting = TRUE
	outdoors = TRUE
	uses_daylight = TRUE
	daylight_multiplier = 0.7
	base_lighting_alpha = 0
	sound_environment = SOUND_ENVIRONMENT_CITY
	light_power = 0.1
	light_range = 2
	light_color = COLOR_STARLIGHT
	ambient_buzz = 'sound/ambience/plaza_amb.ogg'
	ambient_buzz_vol = 20

/area/halflife/outdoors/sewage_dump
	name = "\improper Sewage Dump"
	ambient_buzz = 'sound/ambience/toxic_ambience.ogg'

/area/halflife/outdoors/alley
	name = "\improper Alley Ways"
	ambient_buzz = 'sound/ambience/tone_alley.ogg'


/area/halflife/indoors
	name = "\improper Indoors"
	icon_state = "away"
	base_lighting_alpha = 15
	light_power = 0.1
	light_range = 2
	ambience_index = AMBIENCE_HLINSIDE
	sound_environment = SOUND_ENVIRONMENT_ROOM
	ambient_buzz = 'sound/ambience/town_ambience.ogg'

/area/halflife/indoors/townhall
	name = "\improper Town Hall"
	ambient_buzz = 'sound/ambience/citadel_ambience.ogg'

/area/halflife/indoors/bar
	name = "\improper Bar"

/area/halflife/indoors/restaurant
	name = "\improper Restaurant"

/area/halflife/indoors/trainstation
	name = "\improper Trainstation"

/area/halflife/indoors/slums
	name = "\improper Slums"

/area/halflife/indoors/sewer
	name = "\improper Sewer"
	base_lighting_alpha = 5
	max_ambience_cooldown = 90 SECONDS
	icon_state = "away"
	ambience_index = AMBIENCE_HLSEWERS
	sound_environment = SOUND_ENVIRONMENT_STONE_CORRIDOR
	ambient_buzz = 'sound/ambience/corridor.ogg'
	ambient_buzz_vol = 7
	mood_bonus = -2
	mood_message = "<span class='warning'>This place smells terrible.</span>\n"
