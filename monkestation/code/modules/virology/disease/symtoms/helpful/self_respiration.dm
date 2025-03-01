/datum/symptom/oxygen
	name = "Self-Respiration"
	desc = "The virus synthesizes oxygen, which can remove the need for breathing at high symptom strength."
	stage = 4
	max_multiplier = 5
	badness = EFFECT_DANGER_HELPFUL
	severity = 0
	var/breathing = TRUE

/datum/symptom/oxygen/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	mob.losebreath = max(0, mob.losebreath - multiplier)
	mob.adjustOxyLoss(-2 * multiplier)
	if(multiplier >= 4)
		if(prob(2.5))
			to_chat(mob, span_notice("[pick("Your lungs feel great.", "You realize you haven't been breathing.", "You don't feel the need to breathe.")]"))
		if(breathing)
			breathing = FALSE
			ADD_TRAIT(mob, TRAIT_NOBREATH, DISEASE_TRAIT)

/datum/symptom/oxygen/deactivate(mob/living/carbon/mob, datum/disease/acute/disease)
	if(!breathing)
		breathing = TRUE
		REMOVE_TRAIT(mob, TRAIT_NOBREATH, DISEASE_TRAIT)
		mob.emote("gasp")
		to_chat(mob, span_notice("You feel the need to breathe again."))
