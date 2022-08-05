/atom/proc/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	return

/obj/item/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(!drone)
		return
	var/resource_gain = integrate_amount()
	if(resources + resource_gain > max_resources)
		to_chat(drone, span_warning("You cannot hold more materials!"))
		return
	if(!resource_gain)
		resource_gain = 4
	drone.do_attack_animation(src)
	drone.changeNext_move(CLICK_CD_RAPID)
	var/obj/effect/temp_visual/swarmer/integrate/I = new /obj/effect/temp_visual/swarmer/integrate(get_turf(src))
	I.pixel_x = pixel_x
	I.pixel_y = pixel_y
	I.pixel_z = pixel_z
	if(istype(src, /obj/item/stack))
		var/obj/item/stack/S = src
		if(do_after(drone, src, max(1, round(S.amount/20))))
			resource_gain = S.amount
			S.use(S.amount)
			drone.change_resources(resource_gain)
			return
	drone.change_resources(resource_gain)
	qdel(src)
	return TRUE

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
		to_chat(drone, span_warning("You sucessfully transform [src] into your resources."))
		drone.change_resources(maxHealth/2)
		gib()
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
		gib()
		return
	if(drone.a_intent == INTENT_HELP)
		if(health >= maxHealth)
			to_chat(drone, span_notice("[drone == src ? "You are" : "[drone] is"] already in good conditions."))
			return
		if(drone.resources < 10)
			to_chat(drone, span_notice("You don't have enough resources to repair [drone == src ? "yourself" : src]."))
			return
		repair(drone)
		
/turf/open/floor/feather/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone.resources < 25)
		to_chat(drone, span_notice("You don't have enough resources to build a barricade."))
		return
	if(locate(/obj/structure/grille/flock) in src)
		to_chat(src, span_warning("There is already a barricade here."))
		return
	new /obj/structure/grille/flock (src)
	drone.change_resources(-25)

/obj/structure/grille/flock/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(broken)
		to_chat(drone, span_warning("[src] Is to damaged to extract any resources!"))
	to_chat(drone, span_notice("You begin deconstructing [src]..."))
	if(!do_after(drone, src, 3 SECONDS))
		return
	if(QDELETED(src))
		return
	if(!obj_integrity)
		return
	to_chat(drone, span_notice("You deconstruct [src]."))
	drone.change_resources(obj_integrity/2)
	qdel(src)

/obj/structure/grille/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone && istype(drone))
		if(drone.resources < broken ? 10 : 5)
			to_chat(drone, span_warning("Not enough resources!"))
			return
		drone.change_resources(broken ? 10 : 5)
	if(!broken)
		new /obj/structure/grille/flock (loc)
	else
		new /obj/structure/grille/flock/broken (loc)
	qdel(src)

/turf/closed/wall/feather/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	to_chat(drone, span_notice("You begin deconstructing [src]..."))
	if(!do_after(drone, src, 5 SECONDS))
		return
	if(QDELETED(src) || istype(/turf/closed/wall/feather, src) || !src)
		return
	to_chat(drone, span_notice("You deconstruct [src]."))
	TerraformTurf(/turf/open/floor/feather)

/mob/living/carbon/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(!drone)
		return
	if(HAS_TRAIT(src, TRAIT_HUSK))
		to_chat(drone, span_notice("[src] is to damaged to extract any resources from them."))
		return
	if((getBruteLoss()/3 + getFireLoss()/2 + getCloneLoss()) > 200)
		to_chat(drone, span_notice("[src] is to damaged to extract any resources from them."))
		return	
	if(buckled)
		return
	to_chat(drone, span_notice("You attempt to encage [src]..."))
	if(!do_mob(drone, src, 4 SECONDS))
		return
	var/obj/structure/destructible/flock/cage/C = new /obj/structure/destructible/flock/cage (get_turf(src))
	C.buckle_mob(src, TRUE)
	return