
/datum/symptom/killertoxins
	name = "Toxification Syndrome"
	desc = "A more advanced version of Hyperacidity, causing the infected to rapidly generate toxins."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	severity = 5
	multiplier = 3
	max_multiplier = 5

/datum/symptom/killertoxins/activate(mob/living/carbon/mob)
	mob.adjustToxLoss(5 * multiplier)
