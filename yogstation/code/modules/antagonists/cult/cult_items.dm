obj/item/shield/mirror/proc/break_mirror(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T) //make sure we're not in null or something
			T.visible_message("<span class='warning'>The sheer force from throwing the shield shatters it!</span>")
			new /obj/effect/temp_visual/cult/sparks(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
			qdel(src)