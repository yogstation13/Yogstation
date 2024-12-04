/mob/living/CanAllowThrough(atom/movable/mover, border_dir)
	if(SEND_SIGNAL(src, COMSIG_LIVING_CAN_ALLOW_THROUGH, mover, border_dir) & COMPONENT_LIVING_PASSABLE)
		return TRUE
	return ..()

/mob/living/proc/update_pull_movespeed_feeble()
	if(isliving(pulling))
		var/mob/living/L = pulling
		if (!slowed_by_drag)
			remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
			return
		if(L.body_position == STANDING_UP)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = PULL_PRONE_SLOWDOWN * 0.75)
			return
		if (L.buckled || grab_state >= GRAB_AGGRESSIVE)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = PULL_PRONE_SLOWDOWN * 1)
			return
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = PULL_PRONE_SLOWDOWN * 3)
		return
	if(isobj(pulling))
		var/obj/structure/S = pulling
		if(!slowed_by_drag || !S.drag_slowdown)
			if (S.has_buckled_mobs())
				add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = PULL_PRONE_SLOWDOWN * 0.75)
				return
			remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
			return
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/bulky_drag, multiplicative_slowdown = S.drag_slowdown * 3)
		return
	remove_movespeed_modifier(/datum/movespeed_modifier/bulky_drag)
