/obj/vehicle/ridden/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"
	fall_off_if_missing_arms = TRUE

/obj/vehicle/ridden/bicycle/Initialize(mapload)
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	D.vehicle_move_delay = 0

/obj/vehicle/ridden/bicycle/tesla_act(source, power, zap_range, tesla_flags, list/shocked_targets) // :::^^^)))
	. = ..()
	name = "fried bicycle"
	desc = "Well spent."
	color = rgb(63, 23, 4)
	can_buckle = FALSE
	tesla_buckle_check(power)
	for(var/m in buckled_mobs)
		unbuckle_mob(m,1)
