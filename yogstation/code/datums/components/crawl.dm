/obj/effect/dummy/crawling
	name = "THESE WOUNDS, THEY WILL NOT HEAL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/crawling/relaymove(mob/user, direction)
	forceMove(get_step(src,direction))

/obj/effect/dummy/crawling/ex_act()
	return
/obj/effect/dummy/crawling/bullet_act()
	return
/obj/effect/dummy/crawling/singularity_act()
	return

/datum/component/crawl
	var/list/crawling_types //the types of objects we use to get in and out of crawling
	var/obj/effect/dummy/crawling/holder

/datum/component/crawl/Initialize()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ALT_CLICK_ON, .proc/try_crawl)

/datum/component/crawl/proc/try_crawl(atom/target)
	var/can_crawl = FALSE
	for(var/type in crawling_types)
		if(istype(target, type))
			can_crawl = TRUE
			break
	if(!can_crawl)
		return FALSE
	var/mob/living/M = parent
	if(M.incapacitated())
		return FALSE

	if(holder && can_stop_crawling(target, M))
		stop_crawling(target, M)
	else if(!istype(M.loc, /obj/effect/dummy/crawling) && can_start_crawling(target, M)) //no crawling while crawling
		start_crawling(target, M)
	return TRUE

/datum/component/crawl/proc/can_start_crawling(atom/target, mob/living/user)
	if(!user.Adjacent(target))
		return FALSE
	return TRUE

/datum/component/crawl/proc/can_stop_crawling(atom/target, mob/living/user)
	return TRUE

/datum/component/crawl/proc/start_crawling(atom/target, mob/living/user)
	holder = new(get_turf(user))
	user.forceMove(holder)

/datum/component/crawl/proc/stop_crawling(atom/target, mob/living/user)
	user.forceMove(get_turf(target))
	qdel(holder)
	holder = null

/datum/component/crawl/RemoveComponent()
	if(holder)
		var/mob/living/M = parent
		M.forceMove(get_turf(holder))
		qdel(holder)
	return ..()

////////////BLOODCRAWL
/datum/component/crawl/blood
	crawling_types = list(/obj/effect/decal/cleanable/blood, /obj/effect/decal/cleanable/xenoblood)

/datum/component/crawl/blood/start_crawling(atom/target, mob/living/user)
	user.visible_message("<span class='warning'>[user] sinks into the pool of blood!</span>")
	playsound(get_turf(target), 'sound/magic/enter_blood.ogg', 100, 1, -1)
	..()

/datum/component/crawl/blood/stop_crawling(atom/target, mob/living/user)
	target.visible_message("<span class='warning'>[target] starts to bubble...</span>")
	if(!do_after(user, 20, target = target))
		return
	if(!target)
		return
	..()
	user.visible_message("<span class='warning'><B>[user] rises out of the pool of blood!</B></span>")
	playsound(get_turf(target), 'sound/magic/exit_blood.ogg', 100, 1, -1)