/datum/symptom/headache
	name = "Headache"
	desc = "Gives the infected a light headache."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/headache/activate(mob/living/mob)
	to_chat(mob, span_notice("Your head hurts a bit."))
