/datum/symptom/wendigo_vomit
	name = "Gastrointestinal Inflammation"
	desc = "Inflames the GI tract of the infected, causing relentless vomitting."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	chance = 6
	max_chance = 12

/datum/symptom/wendigo_vomit/activate(mob/living/mob)
	if(!ishuman(mob))
		return

	var/mob/living/carbon/human/victim = mob
	victim.vomit(stun = FALSE)
