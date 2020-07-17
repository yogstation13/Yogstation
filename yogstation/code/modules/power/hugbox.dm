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
	to_chat(user, "<span class='warning'>You crank up the love harvesting regulator to hardware maximum.</span>")

/obj/machinery/power/hugbox_engine/wrench_act(mob/living/user, obj/item/I)
	if(!anchored && !isinspace())
		connect_to_network()
		to_chat(user, "<span class='notice'>You secure [src] to the floor.</span>")
		anchored = TRUE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	else if(anchored)
		if(has_buckled_mobs())
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
	if(has_buckled_mobs())
		var/mob/living/carbon/H = buckled_mobs[1]
		to_chat(C, "<span class='notice'>You press the ermegency release button.</span>")
		unbuckle_mob(H)
		return
	if(obj_flags & EMAGGED)
		to_chat(C, "<span class='userdanger'>[src] grips you with its manipulators tightly!</span>")
		C.forceMove(get_turf(src))
		playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 50, 1)
		C.notransform = TRUE
		buckle_mob(C, TRUE, TRUE)
		C.Stun(30) //So they can't escape by themselves
		sleep(30) //better beg for help
		crunch(C)
		return
	to_chat(C, "<span class='notice'>You hug [src].</span>")
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
	add_avail(power_per_hug)
	return ..()

/obj/machinery/power/hugbox_engine/proc/crunch(mob/living/carbon/crunched)
	while(crunched.buckled)
		var/turf/location = get_turf(crunched)
		if(crunched.health > 25)
			crunched.visible_message("<span class='danger'>[src] hugs [crunched]!</span>", "<span class='userdanger'>[src] hugs you!</span>")
			crunched.adjustBruteLoss(15)
			playsound(src, "desceration", 60, 1)
			shake_camera(crunched, 3, 1)
			crunched.add_splatter_floor(location)
			add_avail(power_per_hug*50) //5 MW
			crunched.Stun(20)
			sleep(20)
		else
			crunched.visible_message("<span class='danger'>[src] hugs [crunched] tighter!</span>", "<span class='userdanger'>[src] starts hugging you tighter!</span>")
			crunched.Stun(30)
			crunched.adjustBruteLoss(5)
			sleep(30)
			if(crunched.buckled) //Are they still buckled?
				crunched.visible_message("<span class='danger'>[src] hugs [crunched] tighter!</span>", "<span class='userdanger'>WAY TOO TIGHT.</span>")
				crunched.Stun(40)
				crunched.adjustBruteLoss(5)
				sleep(40)
			if(crunched.buckled)
				crunched.visible_message("<span class='danger'>You hear a loud crunch coming from [crunched]!</span>", "<span class='colossus'>CRUNCH</span>")
				crunched.add_splatter_floor(location)
				crunched.emote("scream")
				crunched.adjustBruteLoss(5)
				add_avail(power_per_hug*50)
				shake_camera(crunched, 3, 1)
				playsound(src, "sound/magic/demon_consume.ogg", 60, 1)
				crunched.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_SURGERY)
				sleep(30)
			unbuckle_mob(crunched, TRUE)

	crunched.notransform = FALSE
	crunched.Knockdown(40)
	crunched.visible_message("<span class='warning'>[src] lets go of [crunched].</span>", "<span class='warning'>[src] lets you go.</span>")
