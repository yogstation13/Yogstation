/obj/item/organ/heart/nanite
	name = "Nanite heart"
	desc = "Test"
	icon_state = "heart-c"
	synthetic = TRUE
	var/energy = 50
	var/nanite_boost = 2

/obj/item/organ/heart/nanite/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	Stop()

/obj/item/organ/heart/cybernetic/on_life()
	. = ..()
	if(SEND_SIGNAL(M, COMSIG_HAS_NANITES))
		SEND_SIGNAL(M, COMSIG_REGEN
