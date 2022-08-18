/obj/machinery/turnstile
	name = "turnstile"
	desc = "A mechanical door that permits one-way access to an area."
	icon = 'icons/obj/objects.dmi'
	icon_state = "turnstile_map"
	power_channel = ENVIRON
	density = TRUE
	obj_integrity = 250
	max_integrity = 250
	//Robust! It'll be tough to break...
	armor = list(MELEE = 50, BULLET = 20, LASER = 0, ENERGY = 80, BOMB = 10, BIO = 100, RAD = 100, FIRE = 90, ACID = 50)
	anchored = TRUE
	use_power = FALSE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER
	climbable = FALSE
	CanAtmosPass = ATMOS_PASS_NO



/obj/machinery/turnstile/brig
	name = "Brig turnstile"
	//Seccies and brig phys may always pass, either way.
	req_one_access = list(ACCESS_SEC_DOORS)
	max_integrity = 400 /// Made of damn good steel
	damage_deflection = 21 /// Same as airlocks!
	
/obj/machinery/turnstile/Initialize()
	. = ..()
	icon_state = "turnstile"

/obj/machinery/turnstile/CanAtmosPass(turf/T)
	return TRUE

/obj/machinery/turnstile/Cross(atom/movable/mover)
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
	var/is_handcuffed = FALSE
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		is_handcuffed = C.handcuffed
	if((get_dir(loc, mover.loc) == dir && !is_handcuffed) || allowed) //Make sure looking at appropriate border, loc is first so the turnstyle faces the mover
		flick("operate", src)
		playsound(src,'sound/items/ratchet.ogg',50,0,3)
		return TRUE
	else
		flick("deny", src)
		playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
		return FALSE
