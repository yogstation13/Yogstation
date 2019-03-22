/mob/living/carbon/human/onTransitZ(old_z,new_z)
	.=..()
	if(is_mining_level(new_z) || is_mining_level(old_z))
		update_move_intent_slowdown()
		update_movespeed()

/mob/living/carbon/human/update_move_intent_slowdown()
	if(!is_mining_level(z))
		return ..()

	var/mod = 0
	if(m_intent == MOVE_INTENT_WALK)
		mod = 4
	else
		mod = 1.5
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, multiplicative_slowdown = mod)
	
/mob/living/carbon/human/slip(knockdown_amount, obj/O, lube)
	if(has_trait(TRAIT_NOSLIPALL))
		return 0
	if (!(lube&GALOSHES_DONT_HELP))
		if(has_trait(TRAIT_NOSLIPWATER))
			return 0
		if(shoes && istype(shoes, /obj/item/clothing))
			var/obj/item/clothing/CS = shoes
			if (CS.clothing_flags & NOSLIP)
				return 0
	return ..()
