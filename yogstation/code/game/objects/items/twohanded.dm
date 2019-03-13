/obj/item/twohanded/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		var/turf/T = get_turf(src)
		for(var/obj/structure/table/X in T)
			if(X)
				final_block_chance = 99
				owner.say(pick("IT'S OVER!!", "I HAVE THE HIGH GROUND!!"))
				return ..()
		return ..()
	else
		return 0
