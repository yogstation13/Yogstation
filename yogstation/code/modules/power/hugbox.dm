/obj/machinery/power/hugbox_engine
	name = "hugbox engine"
	desc = "Turn up the love now, listen up now, turn up the <span style='color:#FF1493;font-style:italic'>love</span>..."
	icon = 'yogstation/icons/obj/hugbox_engine.dmi'
	icon_state = "hug_me"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	can_buckle = TRUE
	buckle_lying = FALSE

	var/power_per_hug = 1000000

/obj/machinery/power/hugbox_engine/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, span_warning("You crank up the love harvesting regulator to hardware maximum."))

/obj/machinery/power/hugbox_engine/wrench_act(mob/living/user, obj/item/I)
	if(!anchored && !isinspace())
		connect_to_network()
		to_chat(user, span_notice("You secure [src] to the floor."))
		anchored = TRUE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	else if(anchored)
		if(has_buckled_mobs())
			to_chat(user, span_warning("You can't detach [src] from the floor, it's holding on too tightly!"))
			return TRUE
		disconnect_from_network()
		to_chat(user, span_notice("You unsecure [src] from the floor."))
		anchored = FALSE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	return TRUE

/obj/machinery/power/hugbox_engine/attack_hand(mob/user)
	if(!anchored)
		return
	var/mob/living/carbon/C = user
	if(!istype(C))
		return
	if(has_buckled_mobs())
		var/mob/living/carbon/H = buckled_mobs[1]
		to_chat(C, span_notice("You press the emergency release button."))
		unbuckle_mob(H)
		return
	if(obj_flags & EMAGGED)
		to_chat(C, span_userdanger("[src] grips you with its manipulators tightly!"))
		C.forceMove(get_turf(src))
		playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 50, 1)
		C.notransform = TRUE
		buckle_mob(C, TRUE, TRUE)
		C.Stun(3 SECONDS) //So they can't escape by themselves
		sleep(3 SECONDS) //better beg for help
		crunch(C)
		return
	to_chat(C, span_notice("You hug [src]."))
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
	add_avail(power_per_hug)
	return ..()

/obj/machinery/power/hugbox_engine/proc/crunch(mob/living/carbon/crunched)
	while(crunched.buckled)
		var/turf/location = get_turf(crunched)
		if(crunched.health > 25)
			crunched.visible_message(span_danger("[src] hugs [crunched]!"), span_userdanger("[src] hugs you!"))
			crunched.adjustBruteLoss(15)
			playsound(src, "desceration", 60, 1)
			shake_camera(crunched, 3, 1)
			crunched.add_splatter_floor(location)
			add_avail(power_per_hug*50) //5 MW
			crunched.Stun(2 SECONDS)
			sleep(2 SECONDS)
		else
			crunched.visible_message(span_danger("[src] hugs [crunched] tighter!"), span_userdanger("[src] starts hugging you tighter!"))
			crunched.Stun(3 SECONDS)
			crunched.adjustBruteLoss(5)
			sleep(3 SECONDS)
			if(crunched.buckled) //Are they still buckled?
				crunched.visible_message(span_danger("[src] hugs [crunched] tighter!"), span_userdanger("WAY TOO TIGHT."))
				crunched.Stun(4 SECONDS)
				crunched.adjustBruteLoss(5)
				sleep(4 SECONDS)
			if(crunched.buckled)
				crunched.visible_message(span_danger("You hear a loud crunch coming from [crunched]!"), span_colossus("CRUNCH"))
				crunched.add_splatter_floor(location)
				crunched.emote("scream")
				crunched.adjustBruteLoss(5)
				add_avail(power_per_hug*50)
				shake_camera(crunched, 3, 1)
				playsound(src, "sound/magic/demon_consume.ogg", 60, 1)
				crunched.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_SURGERY)
				sleep(3 SECONDS)
			unbuckle_mob(crunched, TRUE)

	crunched.notransform = FALSE
	crunched.Knockdown(4 SECONDS)
	crunched.visible_message(span_warning("[src] lets go of [crunched]."), span_warning("[src] lets you go."))
