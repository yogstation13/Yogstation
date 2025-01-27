/datum/symptom/drool
	name = "Saliva Effect"
	desc = "Causes the infected to drool."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/drool/activate(mob/living/mob)
	mob.emote("drool")

