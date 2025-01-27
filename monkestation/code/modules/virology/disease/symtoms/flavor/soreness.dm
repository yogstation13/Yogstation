/datum/symptom/soreness
	name = "Myalgia Syndrome"
	desc = "Makes the infected more perceptive of their aches and pains."
	stage = 1
	chance = 5
	max_chance = 30
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/soreness/activate(mob/living/mob)
	to_chat(mob, span_notice("You feel a little sore."))
	if(iscarbon(mob))
		var/mob/living/carbon/host = mob
		host.stamina.adjust(-10)
