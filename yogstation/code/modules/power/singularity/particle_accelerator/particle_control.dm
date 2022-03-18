/obj/machinery/particle_accelerator/control_box
	active_power_usage = 5000 // The power usage when at lvl 0

/obj/machinery/particle_accelerator/control_box/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, span_danger("The laws of physics no longer apply in the future, god help you..."))
	locked = FALSE
	area_restricted = FALSE
	SSachievements.unlock_achievement(/datum/achievement/engineering/pa_emag, user.client)
	do_sparks(5, 0, src)
	obj_flags |= EMAGGED

	strength = 4 // Set the new strength to lvl 4
	strength_change() // Update the emitter

	if(!active)
		toggle_power()
	update_icon()
