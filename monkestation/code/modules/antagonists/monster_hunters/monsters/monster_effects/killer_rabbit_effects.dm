/obj/effect/rabbit_hole
	name = "Rabbit Hole"
	icon = 'monkestation/icons/mob/rabbit.dmi'
	icon_state = "hole_effect"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE

/obj/effect/rabbit_hole/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(fell)), 1 SECONDS)
	QDEL_IN(src, 4 SECONDS)

/obj/effect/rabbit_hole/proc/fell()
	for(var/mob/living/carbon/human/man in loc)
		if(man.stat == DEAD)
			continue
		visible_message(span_danger("[man] falls into the rabbit hole!"))
		man.Knockdown(5 SECONDS)
		man.adjustBruteLoss(20)

/**
 * 'First' rabbit hole
 * Makes more rabbit holes near it
 */
/obj/effect/rabbit_hole/first/Initialize(mapload, new_spawner)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(generate_holes)), 0.5 SECONDS)

/obj/effect/rabbit_hole/first/proc/generate_holes()
	for(var/dir in GLOB.cardinals)
		var/turf/hole = get_step(src, dir)
		if(hole)
			new /obj/effect/rabbit_hole(hole)
