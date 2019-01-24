/obj/machinery/power/hugbox_engine
	name = "hugbox engine"
	desc = "Turn up the love now, listen up now, turn up the <span style='color:#FF1493;font-style:italic'>love</span>..."
	icon = 'yogstation/icons/obj/hugbox_engine.dmi'
	icon_state = "hug_me"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE

	var/power_per_hug = 1000000
	var/crunching = FALSE

/obj/machinery/power/hugbox_engine/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>You crank up the love harvesting regulator to hardware maximum.</span>")

/obj/machinery/power/hugbox_engine/crowbar_act(mob/living/user, obj/item/I)
	if(crunching)
		to_chat(user, "<span class='notice'>You forcefully yank the emergency release.</span>")
		crunching = FALSE
	return TRUE

/obj/machinery/power/hugbox_engine/wrench_act(mob/living/user, obj/item/I)
	if(!anchored && !isinspace())
		connect_to_network()
		to_chat(user, "<span class='notice'>You secure [src] to the floor.</span>")
		anchored = TRUE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	else if(anchored)
		if(crunching)
			to_chat(user, "<span class='warning'>You can't detach [src] from the floor, it's holding on too tightly!</span>")
			return TRUE
		disconnect_from_network()
		to_chat(user, "<span class='notice'>You unsecure [src] from the floor.</span>")
		anchored = FALSE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	return TRUE

/obj/machinery/power/hugbox_engine/attack_hand(mob/user)
	if(!anchored)
		return
	var/mob/living/carbon/C = user
	if(!istype(C))
		return
	if(crunching)
		return
	if(obj_flags & EMAGGED)
		to_chat(C, "<span class='userdanger'>[src] grips you with its manipulators tightly!</span>")
		C.forceMove(get_turf(src))
		playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 50, 1)
		C.notransform = TRUE
		sleep(30) //better beg for help
		crunch(C)
		return
	to_chat(C, "<span class='notice'>You hug [src].</span>")
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
	add_avail(power_per_hug)
	return ..()

/obj/machinery/power/hugbox_engine/proc/crunch(mob/living/carbon/crunched)
	crunching = TRUE
	while(crunching && crunched.stat != DEAD)
		crunched.visible_message("<span class='danger'>[src] hugs [crunched]!</span>", "<span class='userdanger'>[src] hugs you!</span>")
		crunched.adjustBruteLoss(15)
		shake_camera(crunched, 3, 1)
		crunched.emote("scream")
		var/turf/location = get_turf(crunched)
		crunched.add_splatter_floor(location)
		playsound(src, "desceration", 60, 1)
		add_avail(power_per_hug*50) //5 MW
		sleep(20)
	crunching = FALSE
	crunched.notransform = FALSE
	visible_message("<span class='warning'>[src] lets go of [crunched].</span>")