/datum/symptom/sensory_restoration
	name = "Sesnory Restoration"
	desc = "The virus adjusts how light is absorbed in the eyes, leading to enhanced vision at high strength."
	stage = 3
	max_multiplier = 3
	badness = EFFECT_DANGER_HELPFUL
	severity = 0
	max_chance = 12
	var/squinting = TRUE
	var/darkness = FALSE

/datum/symptom/sensory_restoration/activate(mob/living/carbon/mob)
	if(!iscarbon(mob))
		return

	mob.adjustOrganLoss(ORGAN_SLOT_EYES, -2 * multiplier)

	if(prob(10))
		switch(round(multiplier, 1))
			if(2)
				if(squinting)
					ADD_TRAIT(mob, TRAIT_NEARSIGHTED_CORRECTED, DISEASE_TRAIT)
					darkness = TRUE
					mob.update_sight()
				if(prob(2.5))
					to_chat(mob, span_notice("[pick("Your eyes feel great.", "You are able to make out finer details at a distance.", "You don't feel the need to squint.")]"))

			if(3)
				if(!darkness)
					ADD_TRAIT(mob, TRAIT_NEARSIGHTED_CORRECTED, DISEASE_TRAIT)
					squinting = FALSE
					ADD_TRAIT(mob, TRAIT_TRUE_NIGHT_VISION, DISEASE_TRAIT)
					darkness = TRUE
					mob.update_sight()
				if(prob(2.5))
					to_chat(mob, span_notice("[pick("Your eyes feel amazing.", "You are able to make out the details in the darkness.", "You don't feel the need to squint.")]"))

/datum/symptom/sensory_restoration/deactivate(mob/living/carbon/mob, datum/disease/acute/disease)
	if(!squinting)
		squinting = TRUE
		REMOVE_TRAIT(mob, TRAIT_NEARSIGHTED_CORRECTED, DISEASE_TRAIT)
		mob.emote("blinks")
		to_chat(mob, span_notice("You feel the need to squint again."))
	if(darkness)
		darkness = FALSE
		REMOVE_TRAIT(mob, TRAIT_TRUE_NIGHT_VISION, DISEASE_TRAIT)
		to_chat(mob, span_notice("Your eyes are no longer are able to pierce through the darkness."))
	mob.update_sight()


