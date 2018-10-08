/datum/species/human/felinid
	var/peed = FALSE
	var/degenerate = FALSE

/datum/species/human/felinid/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(prob(1))
		degenerate = TRUE

/obj/item/reagent_containers/glass/attack(mob/M, mob/user, def_zone)
	if(M == user && user.a_intent != INTENT_HARM && ishuman(M))
		var/mob/living/carbon/human/H = user
		var/going = FALSE
		if(iscatperson(H) && H.gender == FEMALE && H.zone_selected == BODY_ZONE_PRECISE_GROIN)
			var/datum/species/human/felinid.cat = H.dna.species
			if(going)
				return
			if(H.wear_suit)
				to_chat(H, "<span class='warning'>I-I need to s-strip...</span>")
				return
			for(var/mob/living/watchers in view(world.view,H))
				if(cat.degenerate || watchers == H)
					continue
				else
					to_chat(H, "<span class='boldwarning'>S-Someone is w-watching!</span>")
					return
			if(cat.peed)
				to_chat(H, "<span class='warning'>I-I already w-went today...</span>")
				return
			to_chat(H, "<span class='rose'>You slowly release into [src]...</span>")
			H.visible_message("<span class='warning'[H] starts releasing into [src]!</span")
			cat.peed = TRUE
			going = TRUE
			var/t_himself = "itself"
			if(H.gender == MALE)
				t_himself = "himself"
			else if(H.gender == FEMALE)
				t_himself = "herself"
			if(!do_after(H, 50, target = src))
				to_chat(H, "<span class='boldwarning'>A-Ah! I didn't go p-properly!</span>")
				H.visible_message("<span class='alert'>[H] messes [t_himself]!</span>")
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "messed", /datum/mood_event/peemess)
				return
			if(!src.is_refillable())
				to_chat(H, "<span class='boldwarning'>O-Oh no! M-My fluids c-can't even go i-into this!</span>")
				H.visible_message("<span class='alert'>[H] messes up [t_himself] and [src]!</span>")
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "messedup", /datum/mood_event/peemessup)
				return
			to_chat(H, "<span class='rose'>Your fluids go into [src].</span>")
			H.visible_message("<span class='warning'>[H] pisses into [src]. What a degenerate.</span>")
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "peed", /datum/mood_event/peed)
			src.reagents.add_reagent("gamergirlpee", 5)
			return
	..()