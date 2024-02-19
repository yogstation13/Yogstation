/datum/emote/living/raisehand
	key = "highfive"
	key_third_person = "highfives"
	hands_use_check = TRUE

/datum/emote/living/raisehand/run_emote(mob/user, params)
	. = ..()
	var/obj/item/highfive/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, span_notice("You raise your hand for a high-five."))
	else
		qdel(N)
		to_chat(user, span_warning("You don't have any free hands to high-five with."))

/datum/emote/living/handhold
	key = "handhold"
	key_third_person = "handholds"
	hands_use_check = TRUE

/datum/emote/living/handhold/run_emote(mob/user, params)
	. = ..()
	var/obj/item/handholding/HH = new(user)
	if(user.put_in_hands(HH))
		to_chat(user, span_notice("You prepare to hold hands..."))
	else
		qdel(HH)
		to_chat(user, span_warning("You don't have any free hands to hold with."))

/datum/emote/living/pose
	key = "pose"
	key_third_person = "poses"
	message = "strikes a pose!"
	hands_use_check = TRUE

/datum/emote/living/mpose
	key = "mpose"
	key_third_person = "mposes"
	message = "strikes a menacing pose!"
	hands_use_check = TRUE

/datum/emote/living/vpose
	key = "vpose"
	key_third_person = "vposes"
	message = "strikes a valiant pose!"
	hands_use_check = TRUE

/datum/emote/living/wpose
	key = "wpose"
	key_third_person = "wposes"
	message = "strikes a triumphant pose!"
	hands_use_check = TRUE

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

/datum/emote/living/dab
	key = "dab"
	key_third_person = "dabs"
	message = "dabs."
	message_param = "dabs on %t."
	hands_use_check = TRUE

/datum/emote/living/dab/run_emote(mob/user, params)
	. = ..()
	if(. && ishuman(user))
		var/mob/living/carbon/human/dabber = user
		var/light_dab_angle = rand(35,55)
		var/light_dab_speed = rand(3,7)
		INVOKE_ASYNC(dabber, TYPE_PROC_REF(/atom, DabAnimation), light_dab_speed, 0, 0, 0, light_dab_angle)
		SSachievements.unlock_achievement(/datum/achievement/dab, dabber.client)
