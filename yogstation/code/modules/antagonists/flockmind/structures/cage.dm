/obj/structure/destructible/flock/cage
	name = "weird energy cage"
	desc = "You can see the person inside being rapidly taken apart by fibrous mechanisms."
	flock_desc = "Spins living matter into resources. Painfully."
	flock_id = "matter reprocessor"
	icon_state = "cage"
	anchored = TRUE
	can_buckle = TRUE
	density = FALSE
	can_be_unanchored = FALSE
	canSmoothWith = null
	flags_1 = NODECONSTRUCT_1
	var/processing = FALSE
	var/resources = 0

/obj/structure/destructible/flock/cage/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(has_buckled_mobs())
		for(var/buck in buckled_mobs) //breaking a nest releases all the buckled mobs, because the nest isn't holding them down anymore
			var/mob/living/M = buck
			if(M != user)
				M.visible_message(\
					"[user.name] pulls [M.name] free from the cage!",\
					span_notice("[user.name] pulls you free from the cage."))
			else if(isflockdrone(M))
				unbuckle_mob(M)
				return
			else
				M.visible_message(\
					span_warning("[M.name] struggles to break free from the cage!"),\
					span_notice("You struggle to break free from the cage... (Stay still for 45 seconds.)"))
				if(!do_after(M, 45 SECONDS, src))
					if(M && M.buckled)
						to_chat(M, span_warning("You fail to unbuckle yourself!"))
					return
				if(!M.buckled)
					return
				M.visible_message(\
					span_warning("[M.name] breaks free from the cage!"),\
					span_notice("You break free from the cage!"))

			unbuckle_mob(M)
			add_fingerprint(user)

/obj/structure/destructible/flock/cage/post_buckle_mob(mob/living/M)
	M.faction |= "flock" //So drones don't shoot already buckled dudes
	if(!processing)
		START_PROCESSING(SSobj, src)
		processing = TRUE

/obj/structure/destructible/flock/cage/post_unbuckle_mob(mob/living/M)
	M.faction -= "flock"
	unbuckle_all_mobs()

/obj/structure/destructible/flock/cage/Destroy()
	. = ..()
	if(processing)
		STOP_PROCESSING(SSobj, src)

/obj/structure/destructible/flock/cage/process()
	var/valid_dudes = 0
	if(has_buckled_mobs())
		for(var/buck in buckled_mobs)
			var/mob/living/carbon/C = buck
			if(!istype(C))
				continue
			if(isflockdrone(C))
				continue
			if(HAS_TRAIT(C, TRAIT_HUSK))
				continue
			if(get_suitable_damage(C) > 200)
				unbuckle_mob(C)
				C.become_husk()
				continue
			valid_dudes++
			C.adjustCloneLoss(2)
			if(prob(20))
				C.emote("scream")
			if(prob(25))
				to_chat(C, span_warning("You feel your body getting taken apart..."))
			resources += 4
			if(resources >= 40)
				new /obj/item/flockcache (get_turf(src), resources)
				resources = 0
	if(!valid_dudes)
		unbuckle_all_mobs()
		qdel(src)

/obj/structure/destructible/flock/cage/proc/get_suitable_damage(mob/living/L)
	return L.getBruteLoss()/3 + L.getFireLoss()/2 + L.getCloneLoss()