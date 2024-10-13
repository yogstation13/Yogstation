/*
/datum/symptom/species
	name = "Lizarditis"
	desc = "Turns you into a Lizard."
	badness = EFFECT_DANGER_HARMFUL
	stage = 4
	var/datum/species/old_species
	var/datum/species/new_species = /datum/species/lizard
	max_count = 1
	max_chance = 24

/datum/symptom/species/activate(mob/living/carbon/mob)
	var/mob/living/carbon/human/victim = mob
	if(!ishuman(victim))
		return
	old_species = mob.dna.species
	if(!old_species)
		return
	victim.set_species(new_species)

/datum/symptom/species/deactivate(mob/living/carbon/mob)
	var/mob/living/carbon/human/victim = mob
	if(!ishuman(victim))
		return
	if(!old_species)
		return
	victim.set_species(old_species)

/datum/symptom/species/moth
	name = "Mothification"
	desc = "Turns you into a Moth."
	new_species = /datum/species/moth
*/
