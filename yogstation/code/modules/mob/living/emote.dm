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
		to_chat(user, "<span class='warning'>You don't have any free hands to high-five with.</span>")

/datum/emote/living/pose
	key = "pose"
	key_third_person = "poses"
	message = "strikes a pose!"
	restraint_check = TRUE

/datum/emote/living/mpose
	key = "mpose"
	key_third_person = "mposes"
	message = "strikes a menacing pose!"
	restraint_check = TRUE

/datum/emote/living/vpose
	key = "vpose"
	key_third_person = "vposes"
	message = "strikes a valiant pose!"
	restraint_check = TRUE

/datum/emote/living/wpose
	key = "wpose"
	key_third_person = "wposes"
	message = "strikes a triumphant pose!"
	restraint_check = TRUE

/datum/emote/living/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "whistles."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/iwhistle
	key = "iwhistle"
	key_third_person = "iwhistles"
	message = "innocently whistles."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/smirk
	key = "smirk"
	key_third_person = "smirks"
	message = "smirks."
