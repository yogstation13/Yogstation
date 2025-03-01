/datum/symptom/delightful
	name = "Delightful Effect"
	desc = "A more powerful version of Full Glass. Makes the infected feel delightful."
	stage = 4
	badness = EFFECT_DANGER_HELPFUL
	severity = 0

/datum/symptom/delightful/activate(mob/living/carbon/mob)
	if(!mob.mob_mood?.has_mood_of_category(REF(src)))
		to_chat(mob, span_hypnophrase("You feel delightful!"))
	mob.add_mood_event(REF(src), /datum/mood_event/delightful_symptom)

/datum/symptom/delightful/deactivate(mob/living/carbon/mob, datum/disease/acute/disease)
	mob?.clear_mood_event(REF(src))
	to_chat("You aren't quite sure what you were so happy about.")
