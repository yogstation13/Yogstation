/datum/symptom/confusion
	name = "Topographical Cretinism"
	desc = "Attacks the infected's ability to differentiate left and right."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	max_multiplier = 5
	symptom_delay_min = 1
	symptom_delay_max = 5

/datum/symptom/confusion/activate(mob/living/carbon/mob)
	to_chat(mob, span_warning("You have trouble telling right and left apart all of a sudden!"))
	mob.adjust_confusion_up_to(1 SECONDS * multiplier, 20 SECONDS)
