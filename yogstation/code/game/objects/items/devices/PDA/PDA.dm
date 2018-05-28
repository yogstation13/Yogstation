/obj/item/pda/CtrlClick()
	var/mob/M = usr
	if(usr.canUseTopic(src))
		return attack_self(M)
