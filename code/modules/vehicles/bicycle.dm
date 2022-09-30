/obj/vehicle/ridden/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"
	fall_off_if_missing_arms = TRUE

/obj/vehicle/ridden/bicycle/Initialize()
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/bicycle)

/obj/vehicle/ridden/bicycle/tesla_act() // :::^^^)))
	name = "fried bicycle"
	desc = "Well spent."
	color = rgb(63, 23, 4)
	can_buckle = FALSE
	for(var/m in buckled_mobs)
		unbuckle_mob(m,1)
