/datum/component/riding/crazy
	var/wallriding = FALSE
	var/atom/last_user = null
	override_allow_spacemove = TRUE

/datum/component/riding/crazy/proc/set_wallriding(mob/user, var/newV)
	wallriding = newV
	var/atom/movable/AM = parent
	if (wallriding)
		last_user = user
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		AM.density = 0
		user.density = 0
		animate(user, transform = matrix().Scale(0.8), pixel_y = 16, 5)
	else
		AM.density = 1
		if (istype(last_user))
			last_user.density = 1
			animate(last_user, transform = matrix(), pixel_y = 0, 5)

/datum/component/riding/crazy/keycheck(mob/user)
	return TRUE

/datum/component/riding/crazy/handle_ride(mob/user, direction)
	var/atom/movable/AM = parent
	if(user.incapacitated())
		Unbuckle(user)
		return

	if(world.time < last_vehicle_move + ((last_move_diagonal? 2 : 1) * vehicle_move_delay * CONFIG_GET(number/movedelay/run_delay))) //yogs - fixed this to work with movespeed
		return

	AM.set_glide_size((last_move_diagonal? 2 : 1) * DELAY_TO_GLIDE_SIZE(vehicle_move_delay) * CONFIG_GET(number/movedelay/run_delay))
	for(var/mob/M in AM.buckled_mobs)
		ride_check(M)
		M.set_glide_size(AM.glide_size)
	last_vehicle_move = world.time

	if(keycheck(user))
		var/turf/next = get_step(AM, direction)
		var/turf/current = get_turf(AM)
		if(!istype(next) || !istype(current))
			return	//not happening.
		if (!wallriding)
			if(!turf_check(next, current))
				to_chat(user, "Your \the [AM] can not go onto [next]!")
				return
		if(!Process_Spacemove(direction) || !isturf(AM.loc))
			return
		if (wallriding)
			AM.Move(next, direction)
		else
			step(AM, direction)
		if (isopenturf(next) && wallriding)
			set_wallriding(user, FALSE)
		if((direction & (direction - 1)) && (AM.loc == next))		//moved diagonally
			last_move_diagonal = TRUE
		else
			last_move_diagonal = FALSE
		AM.set_glide_size((last_move_diagonal? 2 : 1) * DELAY_TO_GLIDE_SIZE(vehicle_move_delay) * CONFIG_GET(number/movedelay/run_delay))
		for(var/mob/M in AM.buckled_mobs)
			ride_check(M)
			M.set_glide_size(AM.glide_size)

		handle_vehicle_layer(direction)
		handle_vehicle_offsets()
	else
		to_chat(user, span_notice("You'll need the keys in one of your hands to [drive_verb] [AM]."))

/datum/component/riding/crazy/vehicle_mob_unbuckle(datum/source, mob/living/M, force = FALSE)
	. = ..()
	set_wallriding(null, FALSE)
/obj/vehicle/ridden/mime_motorbike
	name = "Invisible Motorbike"
	desc = "Ding ding"
	icon_state = "atv"
	var/datum/component/riding/crazy/riding_comp
	riding_component_type = /datum/component/riding/crazy
	alpha = 127

/obj/vehicle/ridden/mime_motorbike/Initialize()
	. = ..()
	riding_comp = LoadComponent(/datum/component/riding/crazy)
	riding_comp.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	riding_comp.vehicle_move_delay = 0.4
	obj_flags |= INDESTRUCTIBLE
	var/datum/component/forced_gravity/grav = AddComponent(/datum/component/forced_gravity, 1)
	grav.ignore_space = TRUE


/obj/vehicle/ridden/mime_motorbike/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/ridden/wallriding, VEHICLE_CONTROL_DRIVE)

/datum/action/vehicle/ridden/wallriding
	name = "Start wallriding"
	desc = "Climb up walls"

/datum/action/vehicle/ridden/wallriding/Trigger()
	if(istype(vehicle_ridden_target, /obj/vehicle/ridden/mime_motorbike))
		var/obj/vehicle/ridden/mime_motorbike/M = vehicle_ridden_target
		M.riding_comp.set_wallriding(owner, TRUE)

