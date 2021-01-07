/mob/living/carbon/human/onTransitZ(old_z,new_z)
	.=..()
	if(is_mining_level(new_z) || is_mining_level(old_z))
		update_move_intent_slowdown()
		update_movespeed()

/mob/living/carbon/human/update_move_intent_slowdown()
	var/turf/T = get_turf(src)
	if(T && !is_mining_level(T.z))
		return ..()

	var/mod = 0
	if(m_intent == MOVE_INTENT_WALK)
		mod = 4
	else
		mod = 1.5
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, multiplicative_slowdown = mod)
