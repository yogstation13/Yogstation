/datum/symptom/mind_restoration
	name = "Mind Restoration"
	desc = "The virus repairs the bonds between neurons, reversing some damage to the mind."
	stage = 3
	max_multiplier = 3
	badness = EFFECT_DANGER_HELPFUL
	severity = 0
	max_chance = 12

/datum/symptom/mind_restoration/activate(mob/living/carbon/mob)
	if(!iscarbon(mob))
		return

	mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -multiplier)
	if(prob(10))
		switch(round(multiplier, 1))
			if(2)
				mob.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
			if(3)
				mob.cure_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY)
