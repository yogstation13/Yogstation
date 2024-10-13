/datum/symptom/giggle
	name = "Uncontrolled Laughter Effect"
	desc = "Gives the infected a sense of humor."
	stage = 3
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/giggle/activate(mob/living/carbon/mob)
	mob.emote("giggle")
