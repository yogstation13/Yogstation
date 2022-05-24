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
	if(istype(I, /obj/item/kitchen/knife) && user.a_intent != INTENT_HARM)
		if(!demon)
			visible_message(span_danger("[user] begins to spill his blood on the [src]!"), \
				span_userdanger("You begin to spill your blood on the [src], trying to summon a demon!"))
			if(do_after(user, 30, target = src))
				to_chat(user, "<span class='warning'>You finish spilling your blood on the [src].</span>")
				var/list/candidates = pollCandidatesForMob("Do you want to play as a hunter demon?", ROLE_ALIEN, null, ROLE_ALIEN, 150, src)
				if(!candidates.len)
					to_chat(user, "<span class='warning'>No demons did answer your call! Perhaps try again later...</span>")
					return

				
