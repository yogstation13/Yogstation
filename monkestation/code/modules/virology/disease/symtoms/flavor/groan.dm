/datum/symptom/groan
	name = "Groaning Syndrome"
	desc = "Causes the infected to groan randomly."
	stage = 3
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/groan/activate(mob/living/carbon/mob)
	mob.emote("groan")
