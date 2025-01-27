/datum/symptom/gunck
	name = "Flemmingtons"
	desc = "Causes a sensation of mucous running down the infected's throat."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/gunck/activate(mob/living/mob)
	to_chat(mob, span_notice("Mucus runs down the back of your throat"))
