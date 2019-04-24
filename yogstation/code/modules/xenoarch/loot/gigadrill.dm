/obj/vehicle/ridden/gigadrill
	name = "Giga Drill"
	desc = "This looks like any normal drill,except not,it is a giga drill!"
	icon = 'yogstation/icons/obj/xenoarch/artifacts.dmi'
	icon_state = "gigadrill"
	key_type = null //maybe add a key in the future

	var/obj/structure/ore_box/OB

/obj/vehicle/ridden/gigadrill/Destroy(force)
	OB = null
	..()	

/obj/vehicle/ridden/gigadrill/after_add_occupant(mob/M)
	. = ..()
	update_icon()
	
/obj/vehicle/ridden/gigadrill/after_remove_occupant(mob/M)
	. = ..()
	update_icon()

/obj/vehicle/ridden/gigadrill/update_icon()
	. = ..()
	if(occupant_amount())
		icon_state = "gigadrill_mov"
	else
		icon_state = "gigadrill"

/obj/vehicle/ridden/gigadrill/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 7), TEXT_SOUTH = list(0, 18), TEXT_EAST = list(-18, 9), TEXT_WEST = list( 18, 9)))
	D.set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)
	
