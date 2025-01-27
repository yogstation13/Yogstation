/datum/symptom/drained
	name = "Drained Feeling"
	desc = "Gives the infected a drained sensation."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/drained/activate(mob/living/mob)
	to_chat(mob, span_warning("You feel drained."))
