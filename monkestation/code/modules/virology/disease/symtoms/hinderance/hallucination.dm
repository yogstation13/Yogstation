/datum/symptom/hallucinations
	name = "Hallucinational Syndrome"
	desc = "Induces hallucination in the infected."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	severity = 2

/datum/symptom/hallucinations/activate(mob/living/carbon/mob)
	mob.adjust_hallucinations(5 SECONDS)
