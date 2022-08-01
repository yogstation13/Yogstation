/atom/proc/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	return

/obj/item/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone)
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
	if(!drone)
		return
	if(stat == DEAD || IsStun() || IsImmobilized() || IsParalyzed() || IsUnconscious() || IsSleeping())
		to_chat(drone, span_warning("You attempt to disintegrate [src] into resources."))
		if(!do_mob(drone, src, 4 SECONDS))
			return
		if(QDELETED(src))
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

/mob/living/simple_animal/hostile/flockdrone/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(!drone)
		return
	if(drone.a_intent == INTENT_HARM && drone != src && stat == DEAD)
		to_chat(drone, span_warning("You begin to butcher [src] for it's resources."))  
		if(!do_mob(drone, src, 4 SECONDS))
			return
		if(QDELETED(src))
			return
		drone.change_resources(resources)
		change_resources(-resources, TRUE)
		qdel(src)
		return
	if(drone.a_intent == INTENT_HELP)
		if(health >= maxHealth)
			to_chat(user, span_notice("[drone == src ? "You are" : "[user] is"] already in good conditions."))
			return
		if(drone.resources < 10)
			to_chat(user, span_notice("You don't have enough resources to repair [drone == src ? "yourself" : src]."))
			return
		repair(drone)
		
/turf/open/floor/feather/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone.resources < 25)
		to_chat(user, span_notice("You don't have enough resources to build a barricade."))
		return
	new /obj/structure/flock_barricade (src)
	drone.change_resources(-25)
