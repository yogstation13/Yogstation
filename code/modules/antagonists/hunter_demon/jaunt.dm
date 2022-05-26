/mob/living/simple_animal/hostile/hunter/phaseout()
	src.notransform = TRUE
	spawn(0)
		bloodpool_sink()
		src.notransform = FALSE
	phased = TRUE
	return 1

/mob/living/simple_animal/hostile/hunter/bloodpool_sink()
	var/turf/mobloc = get_turf(src.loc)
	src.visible_message(span_warning("[src] warps out of the reality!"))
	playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 50, 1, -1)
	var/obj/effect/dummy/phased_mob/holder = new /obj/effect/dummy/phased_mob(mobloc)
	src.ExtinguishMob()
	src.holder = holder
	src.forceMove(holder)
	return 1

/mob/living/simple_animal/hostile/hunter/exit_blood_effect()
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 50, 1, -1)

/mob/living/simple_animal/hostile/hunter/phasein()
	if(src.notransform)
		return 0
	var/turf/turfo = get_turf(src)
	visible_message(span_warning("The reality begins to shatter around you!"))
	if(!do_after(src, 3 SECONDS, target = turfo))
		return
	forceMove(turfo)
	src.client.eye = src
	src.visible_message(span_warning("<B>[src] warps into reality!</B>"))
	exit_blood_effect()
	qdel(src.holder)
	src.holder = null
	phased = FALSE
	return 1

/mob/living/simple_animal/hostile/hunter/instaphasein()
	var/turf/turfo = get_turf(src)
	forceMove(turfo)
	src.client.eye = src
	src.visible_message(span_warning("<B>[src] warps into reality!</B>"))
	exit_blood_effect()
	qdel(src.holder)
	src.holder = null
	phased = FALSE
	return 1
