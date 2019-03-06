/obj/machinery/button/door/metro
	name = "door button"
	desc = "A door remote control switch."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/machinery/button/door/metro/attack_hand(mob/user)
	var/gen_count = 0
	for(var/obj/machinery/power/port_gen/pacman/super/metro/gen in orange(5, src))
		gen_count++
		if(!gen.HasFuel() && !gen.active)
			to_chat(user, "<span class='danger'>Button not powered. Start nearby generator.</span>")
			flick("[skin]-denied", src)
			return
	if(gen_count == 0)
		to_chat(user, "<span class='danger'>No generators detected nearby.</span>")
		flick("[skin]-denied", src)
		return
	..()