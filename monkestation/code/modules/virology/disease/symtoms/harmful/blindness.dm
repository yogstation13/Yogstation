

/datum/symptom/blindness
	name = "Hyphema"
	desc = "Sufferers exhibit dangerously low levels of frames per second in the eyes, leading to damage and eventually blindness."
	max_multiplier = 4
	stage = 2
	badness = EFFECT_DANGER_HARMFUL
	severity = 3

/datum/symptom/blindness/activate(mob/living/carbon/mob)
	if(!iscarbon(mob))
		return

	var/obj/item/organ/internal/eyes/eyes = mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return // can't do much

	switch(round(multiplier))
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(mob, span_warning("Your eyes itch."))

		if(3, 4)
			to_chat(mob, span_boldwarning("Your eyes burn!"))
			mob.set_eye_blur_if_lower(10 SECONDS)
			eyes.apply_organ_damage(1)

		else
			mob.set_eye_blur_if_lower(20 SECONDS)
			eyes.apply_organ_damage(5)

			// Applies nearsighted at minimum
			if(!mob.is_nearsighted_from(EYE_DAMAGE) && eyes.damage <= eyes.low_threshold)
				eyes.set_organ_damage(eyes.low_threshold)

			if(prob(eyes.damage - eyes.low_threshold + 1))
				if(!mob.is_blind_from(EYE_DAMAGE))
					to_chat(mob, span_userdanger("You go blind!"))
					eyes.apply_organ_damage(eyes.maxHealth)
			else
				to_chat(mob, span_userdanger("Your eyes burn horrifically!"))
