

/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		..(user, 1)
		adjustBruteLoss(15)
		var/hitverb = "punched"
		if(mob_size < MOB_SIZE_LARGE)
			step_away(src,user,15)
			sleep(0.1 SECONDS)
			step_away(src,user,15)
			hitverb = "slammed"
		playsound(loc, "punch", 25, 1, -1)
		visible_message(span_danger("[user] has [hitverb] [src]!"), \
		span_userdanger("[user] has [hitverb] [src]!"), null, COMBAT_MESSAGE_RANGE)
		return 1

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if (INTENT_HARM)
				var/damage = rand(1, 9)
				if (prob(90))
					playsound(loc, "punch", 25, 1, -1)
					visible_message(span_danger("[M] has punched [src]!"), \
							span_userdanger("[M] has punched [src]!"), null, COMBAT_MESSAGE_RANGE)
					if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
						Unconscious(40)
						visible_message(span_danger("[M] has knocked [src] down!"), \
								span_userdanger("[M] has knocked [src] down!"))
					var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
					apply_damage(damage, BRUTE, affecting)
					log_combat(M, src, "attacked")
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message(span_userdanger("[M] has attempted to punch [src]!"), \
						span_userdanger("[M] has attempted to punch [src]!"), null, COMBAT_MESSAGE_RANGE)

			if (INTENT_DISARM)
				if (!(mobility_flags & MOBILITY_STAND))
					if (prob(5))
						Unconscious(40)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						log_combat(M, src, "pushed")
						visible_message(span_danger("[M] has pushed down [src]!"), \
							span_userdanger("[M] has pushed down [src]!"))
					else
						if (prob(50))
							dropItemToGround(get_active_held_item())
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message(span_danger("[M] has disarmed [src]!"), \
							span_userdanger("[M] has disarmed [src]!"), null, COMBAT_MESSAGE_RANGE)
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message(span_userdanger("[M] has attempted to disarm [src]!"),\
								span_userdanger("[M] has attempted to disarm [src]!"), null, COMBAT_MESSAGE_RANGE)



/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
