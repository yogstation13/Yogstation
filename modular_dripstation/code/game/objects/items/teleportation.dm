/obj/item/hand_tele
	icon = 'modular_dripstation/icons/obj/device.dmi'

/obj/item/hand_tele/try_dispel_portal(atom/target, mob/user)
	if(is_parent_of_portal(target)) //dispel me from this horrid realm
		var/dispel_time = 2 - (manipulator.rating/2)
		if(dispel_time == 0)
			qdel(target)
			to_chat(user, span_notice("You dispel [target] with \the [src]!"))
			return
		balloon_alert(user, "Dispelling portal...")
		if(do_after(user, dispel_time SECONDS, target))
			qdel(target)
			to_chat(user, span_notice("You dispel [target] with \the [src]!"))