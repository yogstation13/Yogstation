/datum/symptom/eyewater
	name = "Watery Eyes"
	desc = "Causes the infected's tear ducts to overact."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/eyewater/activate(mob/living/mob)
	to_chat(mob, span_warning("Your eyes sting and water!"))
	mob.emote("cry")
