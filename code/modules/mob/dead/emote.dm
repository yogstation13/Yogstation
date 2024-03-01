
/* DEAD EMOTE DATUMS */
/datum/emote/dead
	mob_type_allowed_typecache = /mob/dead/observer

/datum/emote/dead/dab
	key = "dab"
	key_third_person = "dabs"
	message = "dabs."
	message_param = "dabs on %t."
	hands_use_check = TRUE

/datum/emote/dead/dab/run_emote(mob/user, params)
	. = ..()
	var/mob/dead/observer/dabber = user
	var/light_dab_angle = rand(35,55)
	var/light_dab_speed = rand(3,7)
	INVOKE_ASYNC(dabber, TYPE_PROC_REF(/atom, DabAnimation), light_dab_speed, 0, 0, 0, light_dab_angle)
