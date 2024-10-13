/datum/symptom/fizzle
	name = "Fizzle Effect"
	desc = "Causes an ill, though harmless, sensation in the infected's throat."
	stage = 4
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/fizzle/activate(mob/living/carbon/mob)
	mob.emote("me", 1, pick("sniffles...", "clears their throat..."))
