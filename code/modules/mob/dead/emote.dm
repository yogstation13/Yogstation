
/* DEAD EMOTE DATUMS */
/datum/emote/dead
	mob_type_allowed_typecache = /mob/dead/observer

/datum/emote/dead/dab
	key = "dab"
	key_third_person = "dabs"
	message = "dabs."
	message_param = "dabs on %t."
	restraint_check = TRUE

/datum/emote/dead/dab/run_emote(mob/user, params)
	. = ..()
	var/mob/dead/observer/H = user
	var/light_dab_angle = rand(35,55)
	var/light_dab_speed = rand(3,7)
	H.DabAnimation(angle = light_dab_angle , speed = light_dab_speed)