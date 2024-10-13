
/datum/symptom/drowsness
	name = "Automated Sleeping Syndrome"
	desc = "Makes the infected feel more drowsy."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	multiplier = 5
	max_multiplier = 10

/datum/symptom/drowsness/activate(mob/living/mob)
	mob.adjust_drowsiness_up_to(multiplier, 40 SECONDS)
