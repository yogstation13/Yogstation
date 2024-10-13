/obj/structure/spawner/ice_moon
	name = "cave entrance"
	desc = "A hole in the ground, filled with monsters ready to defend it."

	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"

	faction = list("mining")
	max_mobs = 3
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/wolf)
	max_integrity = 250

	move_resist = INFINITY
	anchored = TRUE
	resistance_flags = FIRE_PROOF | LAVA_PROOF 

/obj/structure/spawner/ice_moon/Initialize(mapload)
	. = ..()
	clear_rock()

/obj/structure/spawner/ice_moon/proc/clear_rock()
	for(var/turf/F in RANGE_TURFS(2, src))
		if(get_dist(src, F) >= 2)
			if(abs(src.x - F.x) + abs(src.y - F.y) > 3)
				continue
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/polarbear
	max_mobs = 1
	spawn_time = 600 //60 seconds
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/polarbear)

/obj/structure/spawner/ice_moon/polarbear/clear_rock()
	for(var/turf/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/ice_moon/snowlegion
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow)


/obj/structure/spawner/ice_moon/deconstruct(disassembled)
	new /obj/effect/cavein(loc)
	new /obj/structure/closet/crate/necropolis/tendril/icemoon(loc)
	return ..()


/obj/effect/cavein
	name = "collapsing cave entrance"
	desc = "Get clear!"
	layer = TABLE_LAYER
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"
	anchored = TRUE

/obj/effect/cavein/Initialize(mapload)
	. = ..()
	visible_message(span_boldannounce("You hear the screams of creatures as the entrance to the cave crumbles and begins to cave in! Get back!"))
	visible_message(span_warning("Something is shoved out of the cave by debris!"))
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, 1, 1)
	addtimer(CALLBACK(src, PROC_REF(cavein)), 50)

/obj/effect/cavein/proc/cavein()
	for(var/mob/M in range(7,src))
		shake_camera(M, 15, 1)
	playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, 1)
	visible_message(span_boldannounce("The entrance to the cave falls inward, the ground around it widening into a yawning chasm!"))
	for(var/turf/T in range(2,src))
		if(!T.density)
			T.TerraformTurf(/turf/open/chasm/icemoon, /turf/open/chasm/icemoon, flags = CHANGETURF_INHERIT_AIR)
	qdel(src)
