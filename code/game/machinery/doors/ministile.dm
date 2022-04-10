/obj/machinery/ministile
	name = "ministile"
	desc = "A mechanical door that permits one-way access to an area."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ministile_map"
	power_channel = ENVIRON
	density = TRUE
	obj_integrity = 150
	max_integrity = 150
	//Smaller turnstile easier to smash
	armor = list("melee" = 30, "bullet" = 20, "laser" = 0, "energy" = 60, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50)
	anchored = TRUE
	use_power = FALSE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER
	climbable = TRUE

/obj/machinery/ministile/hop
	name = "HOP line turnstile"
	req_one_access = list(ACCESS_HEADS)
	
/obj/machinery/ministile/Initialize()
	. = ..()
	icon_state = "ministile"

/obj/machinery/ministile/CanAtmosPass(turf/T)
	return TRUE

/obj/machinery/ministile/Cross(atom/movable/mover)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return TRUE
	if(istype(mover, /mob/living/simple_animal/bot))
		flick("operate", src)
		playsound(src,'sound/items/ratchet.ogg',50,0,3)
		return TRUE
	else if (!isliving(mover) && !istype(mover, /obj/vehicle/ridden/wheelchair))
		flick("deny", src)
		playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
		return FALSE
	var/allowed = allowed(mover)
	//Sec can drag you out unceremoniously.
	if(!allowed && mover.pulledby)
		allowed = allowed(mover.pulledby)

	if(istype(mover, /obj/vehicle/ridden/wheelchair))
		for(var/mob/living/rider in mover.buckled_mobs)
			if(allowed(rider) && !mover.pulledby) //defer to the above dragging code if we are being dragged
				allowed = TRUE

	if(get_dir(loc, mover.loc) == dir || allowed || mover==machineclimber) //Make sure looking at appropriate border, loc is first so the turnstyle faces the mover
		flick("ministile_operate", src)
		playsound(src,'sound/items/ratchet.ogg',50,0,3)
		return TRUE
	else
		flick("ministile_deny", src)
		playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
		return FALSE
