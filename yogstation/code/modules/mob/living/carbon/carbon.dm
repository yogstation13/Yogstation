/mob/living/carbon/update_sight()
	. = ..()
	if(mind)
		var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
		if(V)
			if(V.get_ability(/datum/vampire_passive/full))
				sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
				see_in_dark = max(see_in_dark, 8)
			else if(V.get_ability(/datum/vampire_passive/vision))
				sight |= (SEE_MOBS)

/mob/living/carbon/relaymove(mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			if(prob(25))
				audible_message("<span class='warning'>You hear something rumbling inside [src]'s stomach...</span>", \
							 "<span class='warning'>You hear something rumbling.</span>", 4,\
							  "<span class='userdanger'>Something is rumbling inside your stomach!</span>")
			var/obj/item/I = user.get_active_held_item()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				var/obj/item/bodypart/BP = get_bodypart(BODY_ZONE_CHEST)
				if(BP.receive_damage(d, 0))
					update_damage_overlays()
				visible_message("<span class='danger'>[user] attacks [src]'s stomach wall with the [I.name]!</span>", "<span class='userdanger'>[user] attacks your stomach wall with the [I.name]!</span>")
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)
				if(prob(getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.forceMove(drop_location())
						stomach_contents.Remove(A)
					src.gib()


/mob/living/carbon/proc/devour_mob(mob/living/carbon/C, devour_time = 130)
	C.visible_message("<span class='danger'>[src] is attempting to devour [C]!</span>", \
					"<span class='userdanger'>[src] is attempting to devour you!</span>")
	if(!do_mob(src, C, devour_time))
		return
	if(pulling && pulling == C && grab_state >= GRAB_AGGRESSIVE && a_intent == INTENT_GRAB)
		C.visible_message("<span class='danger'>[src] devours [C]!</span>", \
						"<span class='userdanger'>[src] devours you!</span>")
		C.forceMove(src)
		stomach_contents.Add(C)
		log_combat(src, C, "devoured")