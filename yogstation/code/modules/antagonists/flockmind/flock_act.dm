/atom/proc/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	return

/obj/item/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	drone.Eat(src)

/obj/item/disk/nuclear/flock_act(mob/living/simple_animal/hostile/flockdrone/drone) //We don't eat the disc!
		return

/turf/open/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone && istype(drone))
		if(drone.resources < 15) //No money?
			to_chat(drone, span_warning("Not enough resources!"))
			return
		drone.change_resources(-15)
	TerraformTurf(/turf/open/floor/feather)

/turf/closed/wall/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone && istype(drone))
		if(drone.resources < 20)
			to_chat(drone, span_warning("Not enough resources!"))
			return
		drone.change_resources(-20)
	TerraformTurf(/turf/closed/wall/feather)

/mob/living/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(stat == DEAD || IsStun() || IsImmobilized() || IsParalyzed() || IsUnconscious() || IsSleeping())
		to_chat(drone, span_warning("You attempt to disintegrate [src] into resources."))
		if(!do_mob(drone, src, 4 SECONDS))
			return
		if(drone.resources >= drone.max_resources)
			to_chat(drone, span_warning("You disintegrate [src], but your storage is full!"))
			gib()
		else
			to_chat(drone, span_warning("You sucessfully transform [src] into your resources."))
			drone.change_resources(maxHealth/2)
			dust()
	else
		return
