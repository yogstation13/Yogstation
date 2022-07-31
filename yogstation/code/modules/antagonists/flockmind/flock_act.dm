/atom/proc/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	return

/obj/item/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	drone.Eat(src)

/turf/open/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone.resources < 15) //No money?
		to_chat(drone, span_warning("Not enough resources!"))
		return
	drone.resources -= 20
	TerraformTurf(/turf/open/floor/feather)

/turf/closed/wall/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone.resources < 20)
		to_chat(drone, span_warning("Not enough resources!"))
		return
	drone.resources -= 20
	TerraformTurf(/turf/closed/wall/feather)

