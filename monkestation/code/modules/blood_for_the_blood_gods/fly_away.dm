/// Called on drop_organs for the organ to "fly away" using movable physics
/obj/item/organ/proc/fly_away(turf/open/owner_location, fly_angle = rand(0, 360), horizontal_multiplier = 1, vertical_multiplier = 1)
	if(QDELETED(src) || !istype(owner_location) || QDELING(owner_location))
		return
	return AddComponent(/datum/component/movable_physics, \
		physics_flags = MPHYSICS_QDEL_WHEN_NO_MOVEMENT, \
		angle = fly_angle, \
		horizontal_velocity = rand(2.5 * 100, 6 * 100) * horizontal_multiplier * 0.01, \
		vertical_velocity = rand(4 * 100, 4.5 * 100) * vertical_multiplier * 0.01, \
		horizontal_friction = rand(0.24 * 100, 0.3 * 100) * 0.01, \
		vertical_friction = 10 * 0.05, \
		horizontal_conservation_of_momentum = 0.5, \
		vertical_conservation_of_momentum = 0.5, \
		z_floor = 0, \
)

/// Proc called to initialize movable physics when a bodypart gets dismembered
/obj/item/bodypart/proc/fly_away(turf/open/owner_location, fly_angle = rand(0, 360), horizontal_multiplier = 1, vertical_multiplier = 1)
	if(QDELETED(src) || !istype(owner_location) || QDELING(owner_location))
		return
	pixel_x = -px_x
	pixel_y = -px_y
	forceMove(owner_location)
	return AddComponent(/datum/component/movable_physics, \
		physics_flags = MPHYSICS_QDEL_WHEN_NO_MOVEMENT, \
		angle = fly_angle, \
		horizontal_velocity = rand(2.5 * 100, 6 * 100) * horizontal_multiplier * 0.01, \
		vertical_velocity = rand(4 * 100, 4.5 * 100) * vertical_multiplier * 0.01, \
		horizontal_friction = rand(0.24 * 100, 0.3 * 100) * 0.01, \
		vertical_friction = 10 * 0.05, \
		horizontal_conservation_of_momentum = 0.5, \
		vertical_conservation_of_momentum = 0.5, \
		z_floor = 0, \
	)

/obj/item/proc/launch_item(turf/open/owner_location, fly_angle = rand(0, 360), horizontal_multiplier = 1, vertical_multiplier = 1)
	if(QDELETED(src) || !istype(owner_location) || QDELING(owner_location))
		return
	forceMove(owner_location)
	return AddComponent(/datum/component/movable_physics, \
		physics_flags = MPHYSICS_QDEL_WHEN_NO_MOVEMENT, \
		angle = fly_angle, \
		horizontal_velocity = rand(2.5 * 100, 6 * 100) * horizontal_multiplier * 0.01, \
		vertical_velocity = rand(4 * 100, 4.5 * 100) * vertical_multiplier * 0.01, \
		horizontal_friction = rand(0.24 * 100, 0.3 * 100) * 0.01, \
		vertical_friction = 10 * 0.05, \
		horizontal_conservation_of_momentum = 0.5, \
		vertical_conservation_of_momentum = 0.5, \
		z_floor = 0, \
	)
