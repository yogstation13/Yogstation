/datum/symptom/choking
	name = "Choking"
	desc = "The virus causes inflammation of the host's air conduits, leading to intermittent choking."
	max_multiplier = 10
	multiplier = 1
	badness = EFFECT_DANGER_HINDRANCE
	max_chance = 20
	stage = 2

/datum/symptom/choking/activate(mob/living/carbon/mob)
	mob.emote("gasp")
	if(prob(25))
		to_chat(mob, span_warning("[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]"))
	mob.adjustOxyLoss(rand(2, 3) * multiplier)
