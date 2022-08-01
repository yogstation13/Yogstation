/turf/closed/wall/feather
	name = "feather wall"
	desc = "A strange glovy wall"
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	canSmoothWith = null
	smooth = SMOOTH_MORE
	sheet_type = null
	sheet_amount = 0
	girder_type = null

/turf/closed/wall/feather/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(isflockdrone(AM)) 
		var/mob/living/simple_animal/hostile/flockdrone/F = AM
		var/atom/movable/stored_pulling = F.pulling
		if(stored_pulling)
			stored_pulling.setDir(get_dir(stored_pulling.loc, newloc))
			stored_pulling.forceMove(src)
			F.start_pulling(stored_pulling, supress_message = TRUE)

/turf/open/floor/feather
	name = "feather floor"
	desc = "A strange glovy floor"
	icon_state = "plating"
	baseturfs = /turf/open/floor/feather
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/obj/structure/flock_barricade
	name = "barricade"
	desc = "An energy blockade. Only flockdrones can pass through it."
	icon_state = "barricade"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	max_integrity = 50
	density = TRUE

/obj/structure/flock_barricade/CanAllowThrough(atom/movable/O)
	. = ..()
	if(isflockdrone(O))
		return TRUE