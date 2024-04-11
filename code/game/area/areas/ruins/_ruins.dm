//Parent types

/area/ruin
	name = "\improper Unexplored Location"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	hidden = FALSE
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1
	mining_speed = TRUE


/area/ruin/unpowered
	always_unpowered = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

/area/ruin/unpowered/no_grav
	has_gravity = FALSE

/area/ruin/powered
	requires_power = FALSE
	lights_always_start_on = TRUE
