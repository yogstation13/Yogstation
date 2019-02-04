/datum/emote/living/raisehand
	key = "highfive"
	key_third_person = "highfives"
	restraint_check = TRUE

/datum/emote/living/raisehand/run_emote(mob/user, params)
	. = ..()
	var/obj/item/highfive/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>You raise your hand for a high-five.</span>")
	else
		qdel(N)
		to_chat(user, "<span class='warning'>You don't have any free hands high-five with.</span>")