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
	armor = list("melee" = 50, "bullet" = 20, "laser" = 0, "energy" = 80, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50)
	anchored = TRUE
	use_power = FALSE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER

/obj/machinery/turnstile/hop
	name = "HOP line turnstile"
	req_one_access = list(ACCESS_HEADS)
/obj/machinery/turnstile/brig
	name = "Brig turnstile"
	//Seccies and brig phys may always pass, either way.
	req_one_access = list(ACCESS_BRIG)
	
/obj/machinery/turnstile/Initialize()
	. = ..()
	icon_state = "turnstile"

/obj/machinery/turnstile/CanAtmosPass(turf/T)
	return TRUE

/obj/machinery/turnstile/CanCross(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return TRUE
	if(!isliving(mover))
		return TRUE
	var/allowed = allowed(mover)
	//Sec can drag you out unceremoniously.
	if(!allowed && mover.pulledby)
		allowed = allowed(mover.pulledby)
	if(get_dir(loc, target) == dir || allowed) //Make sure looking at appropriate border
		flick("operate", src)
		playsound(src,'sound/items/ratchet.ogg',50,0,3)
		return TRUE
	else
		flick("deny", src)
		playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
		return FALSE
