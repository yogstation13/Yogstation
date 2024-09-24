/obj/machinery/turnstile
	name = "turnstile"
	desc = "A mechanical door that permits one-way access to an area."
	icon = 'icons/obj/objects.dmi'
	icon_state = "turnstile_map"
	power_channel = AREA_USAGE_ENVIRON
	density = TRUE
	max_integrity = 250
	//Robust! It'll be tough to break...
	armor = list(MELEE = 50, BULLET = 20, LASER = 0, ENERGY = 80, BOMB = 10, BIO = 100, RAD = 100, FIRE = 90, ACID = 50)
	anchored = TRUE
	use_power = FALSE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER
	var/forcefield = FALSE
	var/on = TRUE
	var/directional = TRUE //whether or not it actually permits one-way access.

/obj/machinery/turnstile/brig
	name = "Brig turnstile"
	//Seccies and brig phys may always pass, either way.
	req_access = list(ACCESS_SEC_BASIC)
	max_integrity = 500 /// Made of damn good steel
	damage_deflection = 21 /// Same as airlocks!

/obj/machinery/turnstile/Initialize(mapload)
	. = ..()
	if(forcefield)
		icon_state = "forcefield"
	else
		icon_state = "turnstile"

/obj/machinery/turnstile/can_atmos_pass(turf/target_turf, vertical = FALSE)
	return TRUE

/obj/machinery/turnstile/Cross(atom/movable/mover)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return TRUE
	if(!on) //you can pass freely if it is off...
		return TRUE
	if(istype(mover, /mob/living/simple_animal/bot))
		flick("operate", src)
		if(forcefield)
			playsound(src,'sound/halflifesounds/halflifeeffects/forcefieldbuzz.ogg',50,0,3)
		else
			playsound(src,'sound/items/ratchet.ogg',50,0,3)
		return TRUE
	else if (!isliving(mover) && !istype(mover, /obj/vehicle/ridden/wheelchair))
		flick("deny", src)
		if(forcefield)
			playsound(src,'sound/halflifesounds/halflifeeffects/forcefieldbuzz.ogg',50,0,3)
		else
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
	if((get_dir(loc, mover.loc) == dir && !is_handcuffed && directional) || allowed) //Make sure looking at appropriate border, loc is first so the turnstyle faces the mover
		flick("operate", src)
		if(forcefield)
			playsound(src,'sound/halflifesounds/halflifeeffects/forcefieldbuzz.ogg',50,0,3)
		else
			playsound(src,'sound/items/ratchet.ogg',50,0,3)
		return TRUE
	else
		flick("deny", src)
		if(forcefield)
			playsound(src,'sound/halflifesounds/halflifeeffects/forcefieldbuzz.ogg',50,0,3)
		else
			playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
		return FALSE

/obj/machinery/turnstile/brig/halflife/forcefield/AltClick(mob/user)
	if (allowed(user))
		if(on)
			on = !on
			icon_state = "forcefield_off"
		else
			on = !on
			icon_state = "forcefield"


//for semi-secure areas. Labor lead, city admin, metropolice, and perhaps trusted citizens may be allowed in.
/obj/machinery/turnstile/brig/halflife/forcefield
	name = "Combine Forcefield"
	desc = "A forcefield which only allows those to pass who have proper access, or if you enter from a certain side. You may be able to turn it off with the proper access."
	icon = 'icons/obj/halflife/forcefield.dmi'
	icon_state = "forcefield_map"
	forcefield = TRUE

/obj/machinery/turnstile/brig/halflife/forcefield/nodirectional
	desc = "A forcefield which only allows those to pass who have proper access. You may be able to turn it off with the proper access."
	directional = FALSE

//for high access areas, only civil protection and the city admin should access
/obj/machinery/turnstile/brig/halflife/forcefield/civilprotection
	req_access = list(ACCESS_SECURITY)

/obj/machinery/turnstile/brig/halflife/forcefield/civilprotection/nodirectional
	desc = "A forcefield which only allows those to pass who have proper access. You may be able to turn it off with the proper access."
	directional = FALSE

//highest security areas, only for the divisional lead and city admin
/obj/machinery/turnstile/brig/halflife/forcefield/armory
	req_access = list(ACCESS_ARMORY)

/obj/machinery/turnstile/brig/halflife/forcefield/armory/nodirectional
	desc = "A forcefield which only allows those to pass who have proper access. You may be able to turn it off with the proper access."
	directional = FALSE

/obj/machinery/turnstile/brig/halflife/forcefield/medical
	req_access = list(ACCESS_MEDICAL)

/obj/machinery/turnstile/brig/halflife/forcefield/medical/nodirectional
	desc = "A forcefield which only allows those to pass who have proper access. You may be able to turn it off with the proper access."
	directional = FALSE

/obj/machinery/turnstile/brig/halflife/forcefield/cargo
	req_access = list(ACCESS_CARGO)

/obj/machinery/turnstile/brig/halflife/forcefield/cargo/nodirectional
	desc = "A forcefield which only allows those to pass who have proper access. You may be able to turn it off with the proper access."
	directional = FALSE

/obj/machinery/turnstile/brig/halflife/forcefield/science
	req_access = list(ACCESS_SCIENCE)

/obj/machinery/turnstile/brig/halflife/forcefield/science/nodirectional
	desc = "A forcefield which only allows those to pass who have proper access. You may be able to turn it off with the proper access."
	directional = FALSE

/obj/machinery/turnstile/brig/halflife/forcefield/botany
	req_access = list(ACCESS_HYDROPONICS)

/obj/machinery/turnstile/brig/halflife/forcefield/botany/nodirectional
	desc = "A forcefield which only allows those to pass who have proper access. You may be able to turn it off with the proper access."
	directional = FALSE
