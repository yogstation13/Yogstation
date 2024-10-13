/datum/symptom/mind
	name = "Lazy Mind Syndrome"
	desc = "Rots the infected's brain."
	stage = 3
	badness = EFFECT_DANGER_HARMFUL

/datum/symptom/mind/activate(mob/living/carbon/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 50)
	else
		mob.setToxLoss(50)
