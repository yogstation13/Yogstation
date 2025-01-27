/datum/symptom/dna
	name = "Reverse Pattern Syndrome"
	desc = "Attacks the infected's DNA, causing rapid spontaneous mutation, and inhibits the ability for the infected to be affected by cryogenics."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	severity = 5

/datum/symptom/dna/activate(mob/living/carbon/mob)
	mob.bodytemperature = max(mob.bodytemperature, 350)
	scramble_dna(mob, TRUE, TRUE, TRUE, rand(15,45))
	if(mob.toxloss <= 50)
		mob.adjustToxLoss(10)
