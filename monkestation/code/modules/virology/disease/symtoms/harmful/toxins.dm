/datum/symptom/toxins
	name = "Hyperacidity"
	desc = "Inhibits the infected's ability to process natural toxins, producing a buildup of said toxins."
	stage = 3
	max_multiplier = 3
	badness = EFFECT_DANGER_HARMFUL
	severity = 3

/datum/symptom/toxins/activate(mob/living/carbon/mob)
	mob.adjustToxLoss((2*multiplier))
