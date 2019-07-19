/obj/item/organ/heart/nanite
	name = "Nanite heart"
	desc = "Test"
	icon_state = "heart-c"
	synthetic = TRUE
	var/nanite_boost = 2

/obj/item/organ/heart/nanite/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	SEND_SIGNAL(owner, COMSIG_NANITE_ADJUST_VOLUME, -100)
	Stop()

/obj/item/organ/heart/cybernetic/on_life()
	. = ..()
	if(SEND_SIGNAL(owner, COMSIG_HAS_NANITES))
		SEND_SIGNAL(owner, COMSIG_NANITE_ADJUST_VOLUME, nanite_boost)
	else
		if prob(25)
			to_chat(owner, "<span class = 'userdanger'>Your heart flutters and stops...</span>")
		Stop()

/obj/item/organ/heart/nanite/Remove(mob/living/carbon/M, special = 0)
	SEND_SIGNAL(M, COMSIG_NANITE_SET_MAX_VOLUME, 800)

/obj/item/organ/heart/nanite/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	SEND_SIGNAL(M, COMSIG_NANITE_SET_MAX_VOLUME, 500)