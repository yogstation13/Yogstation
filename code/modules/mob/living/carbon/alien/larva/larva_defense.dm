

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M)
	if(..())
		var/damage = rand(1, 9)
		if (prob(90))
			playsound(loc, "punch", 25, 1, -1)
			log_combat(M, src, "attacked")
			visible_message(span_danger("[M] has kicked [src]!"), \
					span_userdanger("[M] has kicked [src]!"), null, COMBAT_MESSAGE_RANGE)
			if ((stat != DEAD) && (damage > 4.9))
				Unconscious(rand(100,200))

			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
			apply_damage(damage, BRUTE, affecting)
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message(span_danger("[M] has attempted to kick [src]!"), \
					span_userdanger("[M] has attempted to kick [src]!"), null, COMBAT_MESSAGE_RANGE)

/mob/living/carbon/alien/larva/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	user.AddComponent(/datum/component/force_move, get_step_away(user,src, 30))

/mob/living/carbon/alien/larva/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()
