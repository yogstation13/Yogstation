/obj/structure/bloody_orb
	name = "bloody orb"
	desc = "A magic orb, that emmits bright red light."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "extinguisher_closed"
	anchored = TRUE
	density = FALSE
	max_integrity = 200
	var/mob/living/simple_animal/hostile/hunter/demon 
	var/mob/living/carbon/human/target
	var/mob/living/carbon/human/master
	var/blood_pool_summary = 0
	var/sacrificed_blood = 0

/obj/structure/bloody_orb/attackby(obj/item/I, mob/user, params)
	var/mob/living/carbon/human/H = user
	if(!H)
		return
	if(istype(I, /obj/item/kitchen/knife) && H.a_intent != INTENT_HARM)
		if(!demon)
			if(!(NOBLOOD in H.dna.species.species_traits))
				visible_message(span_danger("[H] begins to spill his blood on the [src]!"), \
					span_userdanger("You begin to spill your blood on the [src], trying to summon a demon!"))
			else 
				visible_message(span_danger("[H] begins to stab himself with [I]!"), \
					span_userdanger("You begin to torture yourself, trying to summon a attract demons with your pain!"))
			if(do_after(H, 50, target = src))
				if(!(NOBLOOD in H.dna.species.species_traits))
					to_chat(H, "<span class='warning'>You finish spilling your blood on the [src].</span>")
					H.blood_volume -= ORB_BLOOD_SACAMOUNT / 2   
				else
					to_chat(H, "<span class='warning'>You finish torturing yourself.</span>")
					H.adjustBruteLoss(20)
				var/list/candidates = pollCandidatesForMob("Do you want to play as a hunter demon?", ROLE_ALIEN, null, ROLE_ALIEN, 150, src)
				if(!candidates.len)
					to_chat(H, "<span class='warning'>No demons did answer your call! Perhaps try again later...</span>")
					return
				var/mob/dead/selected = pick(candidates)
				var/datum/mind/player_mind = new /datum/mind(selected.key)
				var/mob/living/simple_animal/hostile/hunter/hd = new(get_turf(src))
				player_mind.transfer_to(hd)
				player_mind.assigned_role = "Hunter Demon"
				player_mind.special_role = "Hunter Demon"
				playsound(hd, 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
				message_admins("[ADMIN_LOOKUPFLW(hd)] has been summoned as a Hunter Demon by [H].")
				log_game("[key_name(hd)] has been summoned as a Hunter Demon by [H].")
				demon = hd
				master = H
				sacrificed_blood += ORB_BLOOD_SACAMOUNT
				blood_pool_summary += ORB_BLOOD_SACAMOUNT
		else
			if(!(NOBLOOD in H.dna.species.species_traits))
				visible_message(span_danger("[H] begins to spill his blood on the [src]!"), \
					span_userdanger("You begin to spill your blood on the [src], performing a bound rite!"))
			else 
				visible_message(span_danger("[H] begins to stab himself with [I]!"), \
					span_userdanger("You begin to torture yourself, performing a bound rite!"))
			if(do_after(H, 30, target = src))
				if(!(NOBLOOD in H.dna.species.species_traits))
					to_chat(H, "<span class='warning'>You finish spilling your blood on the [src].</span>")
					H.blood_volume -= ORB_BLOOD_SACAMOUNT / 2                                              ///dying from bloodloss is not cool
				else
					to_chat(H, "<span class='warning'>You finish torturing yourself.</span>")
			if(master != H)
				master = H
				to_chat(demon, "<span class='warning'>[H] is now your new master!</span>")
				

				
