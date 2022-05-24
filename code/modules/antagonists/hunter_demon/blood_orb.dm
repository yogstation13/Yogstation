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
	var/mob/living/carbon/human/usr = user
	if(!usr)
		return
	if(istype(I, /obj/item/kitchen/knife) && usr.a_intent != INTENT_HARM)
		if(!demon)
			if(!HAS_TRAIT(usr, TRAIT_NOBLOOD))
				visible_message(span_danger("[usr] begins to spill his blood on the [src]!"), \
					span_userdanger("You begin to spill your blood on the [src], trying to summon a demon!"))
			else 
				visible_message(span_danger("[usr] begins to stab himself with [I]!"), \
					span_userdanger("You begin to torture yourself, trying to summon a attract demons with your pain!"))
			if(do_after(usr, 30, target = src))
				if(!HAS_TRAIT(usr, TRAIT_NOBLOOD))
					to_chat(usr, "<span class='warning'>You finish spilling your blood on the [src].</span>")
					usr.blood_volume -= 50
				else
					to_chat(usr, "<span class='warning'>You finish torturing yourself.</span>")
					usr.AdjustBruteLoss(20)
				var/list/candidates = pollCandidatesForMob("Do you want to play as a hunter demon?", ROLE_ALIEN, null, ROLE_ALIEN, 150, src)
				if(!candidates.len)
					to_chat(usr, "<span class='warning'>No demons did answer your call! Perhaps try again later...</span>")
					return
				var/mob/dead/selected = pick(candidates)
				var/datum/mind/player_mind = new /datum/mind(selected.key)
				var/mob/living/simple_animal/hostile/hunter/hd = new(get_turf(src))
				player_mind.transfer_to(hd)
				player_mind.assigned_role = "Hunter Demon"
				player_mind.special_role = "Hunter Demon"
				playsound(hd, 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
				message_admins("[ADMIN_LOOKUPFLW(hd)] has been summoned as a Hunter Demon by [usr].")
				log_game("[key_name(hd)] has been summoned as a Hunter Demon by [usr].")
				demon = hd
				master = usr
				sacrificed_blood += 100
				blood_pool_summary += 200
				

				
