
/obj/vehicle/ridden/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	icon_state = "atv"
	max_integrity = 150
	armor = list(MELEE = 50, BULLET = 25, LASER = 20, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 60, ACID = 60)
	key_type = /obj/item/key/atv
	integrity_failure = 0.5
	var/static/mutable_appearance/atvcover

/obj/vehicle/ridden/atv/Initialize()
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/atv)

/obj/vehicle/ridden/atv/post_buckle_mob(mob/living/M)
	add_overlay(atvcover)
	return ..()

/obj/vehicle/ridden/atv/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		cut_overlay(atvcover)
	return ..()

//TURRETS!
/obj/vehicle/ridden/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = null

/obj/machinery/porta_turret/syndicate/vehicle_turret
	name = "mounted turret"
	scan_range = 7
	density = FALSE

/obj/vehicle/ridden/atv/turret/Initialize()
	. = ..()
	turret = new(loc)
	turret.base = src

/obj/vehicle/ridden/atv/turret/Moved()
	. = ..()
	if(turret)
		turret.forceMove(get_turf(src))
		switch(dir)
			if(NORTH)
				turret.pixel_x = 0
				turret.pixel_y = 4
				turret.layer = ABOVE_MOB_LAYER
			if(EAST)
				turret.pixel_x = -12
				turret.pixel_y = 4
				turret.layer = OBJ_LAYER
			if(SOUTH)
				turret.pixel_x = 0
				turret.pixel_y = 4
				turret.layer = OBJ_LAYER
			if(WEST)
				turret.pixel_x = 12
				turret.pixel_y = 4
				turret.layer = OBJ_LAYER
