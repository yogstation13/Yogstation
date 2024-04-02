//WATER EFFECTS

/obj/effect/particle_effect/water
	name = "water"
	icon_state = "extinguish"
	pass_flags = PASSTABLE | PASSMACHINES | PASSCOMPUTER | PASSSTRUCTURE | PASSGRILLE | PASSBLOB | PASSMECH | PASSMOB
	var/life = 15
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/turf/target_turf
	var/transfer_methods = TOUCH

/obj/effect/particle_effect/water/New(loc, turf/target, methods, ...)
	if(!isnull(target))
		target_turf = target
	if(!isnull(methods))
		transfer_methods = methods
	return ..()

/obj/effect/particle_effect/water/Initialize(mapload)
	. = ..()
	create_reagents(5)
	QDEL_IN(src, 70)
	if(target_turf)
		addtimer(CALLBACK(src, PROC_REF(move_particle)), 2)

/obj/effect/particle_effect/water/proc/move_particle()
	if(!target_turf)
		return
	var/starting_loc = loc
	step_towards(src, target_turf)
	if(starting_loc == loc)
		if(reagents) // react again if it got stuck
			reagents.reaction(loc, transfer_methods)
			for(var/atom/A in loc)
				reagents.reaction(A, transfer_methods)
		qdel(src) // delete itself if it got blocked and can't move
		return
	if(life)
		addtimer(CALLBACK(src, PROC_REF(move_particle)), 2)

/obj/effect/particle_effect/water/Move(turf/newloc)
	if(life < 1)
		qdel(src)
		return FALSE
	life--
	if(reagents)
		reagents.reaction(newloc, transfer_methods)
		for(var/atom/A in newloc)
			reagents.reaction(A, transfer_methods)
	return ..()

/obj/effect/particle_effect/water/Bump(atom/A)
	if(reagents)
		reagents.reaction(A)
	return ..()


/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
 var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread() -- creates new system
steam.set_up(5, 0, mob.loc) -- sets up variables
OPTIONAL: steam.attach(mob)
steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effect/particle_effect/steam
	name = "steam"
	icon_state = "extinguish"
	density = FALSE

/obj/effect/particle_effect/steam/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 20)

/datum/effect_system/steam_spread
	effect_type = /obj/effect/particle_effect/steam
