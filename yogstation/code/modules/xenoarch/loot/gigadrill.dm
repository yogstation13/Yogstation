/obj/vehicle/ridden/gigadrill
	name = "Giga Drill"
	desc = "This looks like any normal drill except not, it is a giga drill. Drag and drop an ore box on it to load the box on and drag and drop to a adjacant turf to unload the box."
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
	D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)
	
/obj/vehicle/ridden/gigadrill/MouseDrop(atom/over)
	. = ..()
	
	var/mob/user = usr

	if(!OB)
		return FALSE
	if(!over)
		return FALSE
	if(!isliving(usr))
		return FALSE
	if(user.incapacitated())
		return FALSE
	var/turf/target_turf

	if(isturf(over))
		target_turf = over
	else if(get_turf(over))
		target_turf = get_turf(over) //this could be optimised more to only require one get_turf call but that would sacrifice too much readability
	else
		return FALSE

	if(!isturf(target_turf)) //sanitation i guess,shouldnt ever be not a turf
		CRASH("Gigadrill attempted to offload to a non turf")

	if(!Adjacent(user))
		return FALSE
	if(!Adjacent(target_turf))
		return FALSE
	if(target_turf.density)
		return FALSE
	
	for(var/atom/A in target_turf.contents)
		if(A.density)
			if((A == src) || ismob(A))
				continue
			return FALSE

	to_chat(usr, "<span class = 'notice'>You offload \the [OB]</span>")
	OB.forceMove(target_turf)
	OB = null

/obj/vehicle/ridden/gigadrill/MouseDrop_T(atom/movable/AM, mob/user)
	. = ..()
	
	if(!isliving(user))
		return FALSE
	if(OB)
		return FALSE
	if(!istype(AM,/obj/structure/ore_box))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!Adjacent(AM))
		return FALSE
	if(!Adjacent(user))
		return FALSE
	
	to_chat(user, "<span class = 'notice'>You load \the [AM] onto \the [src].</span>")
	AM.forceMove(src)
	OB = AM

/obj/vehicle/ridden/gigadrill/Move(direction)
	. = ..()
	if(!.)
		return
	
	for(var/turf/closed/mineral/M in range(src,1))
		if(get_dir(src,M)&src.dir)
			M.attempt_drill()

	if(!QDELETED(OB))
		for(var/obj/item/stack/ore/ore in range(1, src))
			if(ore.Adjacent(src))
				ore.forceMove(OB)
