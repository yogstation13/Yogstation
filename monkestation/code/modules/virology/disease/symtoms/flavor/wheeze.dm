/datum/symptom/wheeze
	name = "Wheezing"
	desc = "Inhibits the infected's ability to breathe slightly, causing them to wheeze."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/wheeze/activate(mob/living/mob)
	mob.emote("me",1,"wheezes.")
