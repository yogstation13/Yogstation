/obj/effect/temp_visual/goliath_tentacle/darkspawn
	name = "darkspawn tendril"
	desc = "OOOOOOOOOOOOOOOO spooky"
	light_power = -1
	light_range = 1
	light_color = COLOR_VELVET
	light_system = MOVABLE_LIGHT //it's not movable, but the new system looks nicer for this purpose

/obj/effect/temp_visual/goliath_tentacle/darkspawn/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/effect/temp_visual/goliath_tentacle/darkspawn/original/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	var/list/turf/turfs = circle_range_turfs(get_turf(src), 2)
	for(var/i in 1 to 9)
		if(!LAZYLEN(turfs)) //sanity check
			break
		var/turf/T = pick_n_take(turfs)
		new /obj/effect/temp_visual/goliath_tentacle/darkspawn(T, spawner)
	
/obj/effect/temp_visual/goliath_tentacle/darkspawn/trip()
	var/latched = 0
	for(var/mob/living/L in loc)
		if(is_darkspawn_or_thrall(L) || L.stat == DEAD)
			continue
		visible_message(span_danger("[src] grabs hold of [L]!"))
		if(!L.IsStun())
			L.Stun(8 SECONDS)
		else
			L.AdjustStun(2 SECONDS)
		latched = L.AmountStun() //hold on until the stun applied by the tentacle ends
		L.adjustBruteLoss(rand(15,25))
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), latched, TIMER_STOPPABLE) 
