/datum/symptom/adaptation
	name = "Inorganic Biology"
	desc = "The virus can survive and replicate even in an inorganic environment, increasing its resistance and infection rate."
	max_count = 1
	stage = 4
	badness = EFFECT_DANGER_FLAVOR
	severity = 0
	var/biotypes = MOB_MINERAL | MOB_ROBOTIC

/datum/symptom/adaptation/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	disease.infectable_biotypes |= biotypes

/datum/symptom/adaptation/deactivate(mob/living/carbon/mob, datum/disease/acute/disease)
	disease.infectable_biotypes &= ~(biotypes)

/datum/symptom/adaptation/undead
	name = "Necrotic Metabolism"
	desc = "The virus is able to thrive and act even within dead hosts."
	biotypes = MOB_UNDEAD
	severity = 1

/datum/symptom/adaptation/undead/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	.=..()
	disease.process_dead = TRUE

/datum/symptom/adaptation/undead/deactivate(mob/living/carbon/mob, datum/disease/acute/disease)
	.=..()
