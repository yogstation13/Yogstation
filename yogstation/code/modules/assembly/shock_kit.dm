/obj/item/assembly/shock_kit/receive_signal()
	if(istype(loc, /obj/structure/bed/roller/e_roller))
		var/obj/structure/bed/roller/e_roller/E = loc
		E.shock()
	..()
