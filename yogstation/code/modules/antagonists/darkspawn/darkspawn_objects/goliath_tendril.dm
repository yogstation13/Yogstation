/obj/effect/temp_visual/goliath_tentacle/darkspawn
	name = "darkspawn tendril"
	desc = "OOOOOOOOOOOOOOOO spooky"
	light_power = -1
	light_color = COLOR_VELVET
	light_system = MOVABLE_LIGHT //it's not movable, but the new system looks nicer for this purpose

/obj/effect/temp_visual/goliath_tentacle/darkspawn/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/effect/temp_visual/goliath_tentacle/darkspawn/original/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	var/list/turf/turfs = circle_range_turfs(get_turf(src), 2)
	for(var/i in 1 to rand(4, 10))
		var/turf/T = pick_n_take(turfs)
		new /obj/effect/temp_visual/goliath_tentacle/darkspawn(T, spawner)
	
/obj/effect/temp_visual/goliath_tentacle/darkspawn/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if(is_darkspawn_or_veil(L) || L.stat == DEAD)
			continue
		visible_message(span_danger("[src] grabs hold of [L]!"))
		if(!L.IsStun())
			L.Stun(8 SECONDS)
		else
			L.AdjustStun(2 SECONDS)
		L.adjustBruteLoss(rand(10,15))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), 10, TIMER_STOPPABLE)
