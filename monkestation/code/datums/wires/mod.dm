/datum/wires/mod/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		return TRUE

	return ..()
