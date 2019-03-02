/mob/living/carbon/human/CanContractDisease(datum/disease/D)
	var/infectchance = dna.species ? dna.species.yogs_virus_infect_chance : 100 //will this compile? who knows
	if(prob(infectchance))
		return ..()