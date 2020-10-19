/obj/item/pda/CtrlClick()
	var/mob/M = usr
	if(usr.CanReach(src) && usr.canUseTopic(src))
		return attack_self(M)

/obj/item/pda
	light_color = "#ffffff"
