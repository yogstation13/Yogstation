/mob/living/carbon/human/species/gorilla
	race = /datum/species/gorilla

/mob/living/carbon/human/species/egg
	race = /datum/species/egg

/mob/living/carbon/human/get_blood_state()
	if(NOBLOOD in dna.species.species_traits) //Can't have blood problems if your species doesn't have any blood, innit?
		return BLOOD_SAFE
	. = ..()