/datum/symptom/metabolism
	name = "Metabolic Boost"
	desc = "The virus causes the host's metabolism to accelerate rapidly, making them process chemicals twice as fast,\
		but also causing increased hunger."
	max_multiplier = 10
	stage = 3
	badness = EFFECT_DANGER_HELPFUL

/datum/symptom/metabolism/activate(mob/living/carbon/mob)
	if(!iscarbon(mob))
		return

	mob.reagents.metabolize(mob, (multiplier * 0.5) * SSMOBS_DT, 0, can_overdose=TRUE) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	mob.overeatduration = max(mob.overeatduration - 4 SECONDS, 0)
	mob.adjust_nutrition(-(4 + multiplier) * HUNGER_FACTOR) //Hunger depletes at 10x the normal speed
	if(prob(2 * multiplier))
		to_chat(mob, span_notice("You feel an odd gurgle in your stomach, as if it was working much faster than normal."))
