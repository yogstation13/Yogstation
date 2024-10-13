/datum/symptom/thick_blood
	name = "Hyper-Fibrinogenesis"
	desc = "Causes the infected to oversynthesize coagulant, as well as rapidly restore lost blood."
	stage = 3
	badness = EFFECT_DANGER_HELPFUL

/datum/symptom/thick_blood/activate(mob/living/carbon/mob)
	var/mob/living/carbon/human/victim = mob
	if (ishuman(victim))
		if(victim.is_bleeding())
			victim.restore_blood()
			to_chat(victim, span_notice("You feel your blood regenerate, and your bleeding to stop!"))
