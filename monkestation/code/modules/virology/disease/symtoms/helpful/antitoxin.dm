/datum/symptom/antitox
	name = "Antioxidantisation Syndrome"
	desc = "A very real syndrome beloved by Super-Food Fans and Essential Oil Enthusiasts; encourages the production of anti-toxin within the body."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL
	severity = 0

/datum/symptom/antitox/activate(mob/living/mob)
	to_chat(mob, span_notice("You feel your toxins being purged!"))
	mob?.adjustToxLoss(-4)
