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

/obj/structure/grille/flock
	name = "barricade"
	desc = "A glowing mesh of metallic fibres."
	icon = 'icons/obj/flockobjects.dmi'
	icon_state = "barricade"
	obj_integrity = 50
	max_integrity = 50
	rods_amount = 0
	rods_broken = FALSE
	grille_type = /obj/structure/grille/flock
	broken_type = /obj/structure/grille/flock/broken
	broken = FALSE

/obj/structure/grille/flock/update_icon()
	var/percentage = obj_integrity/max_integrity * 100
	var/e = "-0"
	switch(percentage)
		if(-INFINITY to 25)
			e = "-3"
		if(26 to 50)
			e = "-2"
		if(51 to 75)
			e = "-1"
	icon_state = "[initial(icon_state)][e]"

/obj/structure/grille/flock/CanAllowThrough(atom/movable/O)
	. = ..()
	if(isflockdrone(O))
		return TRUE

/obj/structure/grille/flock/broken
	density = FALSE
	icon_state = "barricade-3"
	broken = TRUE
	grille_type = /obj/structure/grille/flock
	broken_type = null
	obj_integrity = 20
	max_integrity = 20

/obj/structure/grille/flock/broken/update_icon()
	return

/obj/structure/grille/flock/broken/examine(mob/user)
	. = ..()
	if(isflockdrone(user) || isflocktrace(user))
		. = span_swarmer("<span class='bold'>###=-</span> Ident confirmed, data packet received.")
		. += span_swarmer("<span class='bold'>ID:</span> [icon2html(src, user)] [broken ? "Broken" : "Reinforced"] Barricade")
		. += span_swarmer("<span class='bold'>System Integrity:</span> [(broken || obj_intergrity < 0)  ? "INTEGRITY FAILURE" : [round(obj_integrity/max_integrity * 100)]"%"]")
		. += span_swarmer("<span class='bold'>###=-</span>")